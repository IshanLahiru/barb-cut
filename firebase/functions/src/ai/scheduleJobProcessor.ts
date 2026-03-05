import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenAI, Modality } from "@google/genai";

const db = admin.firestore();
const storage = admin.storage();

const vertexProject = process.env.GCLOUD_PROJECT;
const vertexLocation = process.env.VERTEX_LOCATION || "global";
const GEMINI_IMAGE_MODEL = process.env.GEMINI_IMAGE_MODEL || "gemini-2.5-flash-image";

const DEFAULT_COST_PER_ANGLE = 1;
const DEFAULT_RETRY_COST_PER_ATTEMPT = 1;
const DEFAULT_MAX_PAID_RETRIES_PER_ANGLE = 2;
const MAX_GENERATION_ATTEMPTS = 5;

type StorageObjectRef = {
  bucket: string;
  path: string;
};

type BillingConfig = {
  costPerAngle: number;
  retryCostPerAttempt: number;
  maxPaidRetriesPerAngle: number;
  baseChargedPoints: number;
  retryChargedPoints: number;
  totalChargedPoints: number;
  refundedPoints?: number;
  refundPolicy?: {
    allFailedPercent?: number;
    partialRefundFailedAnglesOnly?: boolean;
    chargeAtJobCreation?: boolean;
    chargePerRetry?: boolean;
  };
};

type GenerationJob = {
  userId: string;
  prompt?: string;
  haircutName?: string | null;
  beardName?: string | null;
  referenceImages?: Record<string, string | null>;
  billing?: BillingConfig;
  generationConfig?: {
    targetOutput?: string;
  };
};

type AttemptResult = {
  gsUrl: string;
  retriesCharged: number;
  chargedRetryPoints: number;
};

function parseStorageReference(value: string): StorageObjectRef | null {
  if (value.startsWith("gs://")) {
    const withoutScheme = value.replace("gs://", "");
    const slashIndex = withoutScheme.indexOf("/");
    if (slashIndex === -1) {
      return null;
    }
    return {
      bucket: withoutScheme.substring(0, slashIndex),
      path: withoutScheme.substring(slashIndex + 1),
    };
  }

  if (!value.startsWith("http")) {
    return null;
  }

  try {
    const url = new URL(value);

    if (url.host.includes("firebasestorage.googleapis.com")) {
      const segments = url.pathname.split("/").filter(Boolean);
      const bucketIndex = segments.indexOf("b");
      const objectIndex = segments.indexOf("o");
      if (bucketIndex !== -1 && objectIndex !== -1) {
        const bucket = segments[bucketIndex + 1];
        const encodedPath = segments[objectIndex + 1];
        if (bucket && encodedPath) {
          return {
            bucket,
            path: decodeURIComponent(encodedPath),
          };
        }
      }
    }

    if (url.host.includes("storage.googleapis.com")) {
      const segments = url.pathname.split("/").filter(Boolean);
      if (segments.length >= 2) {
        return {
          bucket: segments[0],
          path: segments.slice(1).join("/"),
        };
      }
    }
  } catch (error) {
    console.warn("Failed to parse storage reference:", error);
  }

  return null;
}

function inferContentType(path: string): string {
  const lower = path.toLowerCase();
  if (lower.endsWith(".png")) {
    return "image/png";
  }
  if (lower.endsWith(".webp")) {
    return "image/webp";
  }
  return "image/jpeg";
}

function normalizeContentType(contentType: string | undefined, path: string): string {
  if (contentType && contentType.startsWith("image/")) {
    return contentType;
  }
  return inferContentType(path);
}

function extensionForContentType(contentType: string): string {
  if (contentType.includes("png")) {
    return "png";
  }
  if (contentType.includes("webp")) {
    return "webp";
  }
  return "jpg";
}

async function downloadImageAsInlineData(
  bucketName: string,
  path: string
): Promise<{ base64: string; contentType: string }> {
  const bucketRef = storage.bucket(bucketName);
  const fileRef = bucketRef.file(path);
  const [buffer] = await fileRef.download();
  const [metadata] = await fileRef.getMetadata();
  const contentType = normalizeContentType(metadata.contentType, path);

  return {
    base64: buffer.toString("base64"),
    contentType,
  };
}

function getBillingConfig(job: GenerationJob): BillingConfig {
  const costPerAngle = Math.max(1, Number(job.billing?.costPerAngle ?? DEFAULT_COST_PER_ANGLE));
  const retryCostPerAttempt = Math.max(
    1,
    Number(job.billing?.retryCostPerAttempt ?? DEFAULT_RETRY_COST_PER_ATTEMPT)
  );
  const maxPaidRetriesPerAngle = Math.max(
    0,
    Number(job.billing?.maxPaidRetriesPerAngle ?? DEFAULT_MAX_PAID_RETRIES_PER_ANGLE)
  );

  return {
    costPerAngle,
    retryCostPerAttempt,
    maxPaidRetriesPerAngle,
    baseChargedPoints: Number(job.billing?.baseChargedPoints ?? 0),
    retryChargedPoints: Number(job.billing?.retryChargedPoints ?? 0),
    totalChargedPoints: Number(job.billing?.totalChargedPoints ?? 0),
    refundedPoints: Number(job.billing?.refundedPoints ?? 0),
    refundPolicy: job.billing?.refundPolicy,
  };
}

function isRetryableError(error: unknown): boolean {
  const message = `${error}`.toLowerCase();
  return (
    message.includes("text only") ||
    message.includes("no image") ||
    message.includes("deadline") ||
    message.includes("timeout") ||
    message.includes("unavailable") ||
    message.includes("rate") ||
    message.includes("internal") ||
    message.includes("resource exhausted")
  );
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function extractImageFromResponse(response: unknown): { buffer: Buffer; contentType: string } | null {
  const candidates = (response as { candidates?: unknown[] })?.candidates;
  if (!Array.isArray(candidates)) {
    return null;
  }

  for (const candidate of candidates) {
    const parts = (candidate as { content?: { parts?: unknown[] } })?.content?.parts;
    if (!Array.isArray(parts)) {
      continue;
    }

    for (const part of parts) {
      const inlineData = (part as { inlineData?: { data?: string; mimeType?: string } })
        ?.inlineData;

      if (inlineData?.data) {
        return {
          buffer: Buffer.from(inlineData.data, "base64"),
          contentType: inlineData.mimeType || "image/png",
        };
      }
    }
  }

  return null;
}

async function chargeRetryPoints(
  userId: string,
  jobRef: admin.firestore.DocumentReference,
  retryCost: number,
  position: string,
  attempt: number
): Promise<void> {
  const userRef = db.collection("users").doc(userId);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.runTransaction(async (tx) => {
    const [userSnap, jobSnap] = await Promise.all([tx.get(userRef), tx.get(jobRef)]);

    if (!jobSnap.exists) {
      throw new Error("Job not found while charging retry points.");
    }

    const currentPoints = Number(userSnap.data()?.points ?? 0);
    if (currentPoints < retryCost) {
      throw new Error(
        `Insufficient points for retry billing at ${position} attempt ${attempt}. Needed ${retryCost}, available ${currentPoints}.`
      );
    }

    const jobBilling = (jobSnap.data()?.billing ?? {}) as Partial<BillingConfig>;
    const retryChargedPoints = Number(jobBilling.retryChargedPoints ?? 0) + retryCost;
    const totalChargedPoints = Number(jobBilling.totalChargedPoints ?? 0) + retryCost;

    tx.update(userRef, {
      points: currentPoints - retryCost,
      updatedAt: now,
    });

    tx.update(jobRef, {
      "billing.retryChargedPoints": retryChargedPoints,
      "billing.totalChargedPoints": totalChargedPoints,
      updatedAt: now,
    });
  });
}

async function applyRefund(
  userId: string,
  jobRef: admin.firestore.DocumentReference,
  refundPoints: number
): Promise<void> {
  if (refundPoints <= 0) {
    return;
  }

  const userRef = db.collection("users").doc(userId);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.runTransaction(async (tx) => {
    const [userSnap, jobSnap] = await Promise.all([tx.get(userRef), tx.get(jobRef)]);
    if (!jobSnap.exists) {
      return;
    }

    const refundedAlready = Number(jobSnap.data()?.billing?.refundedPoints ?? 0);
    if (refundedAlready > 0) {
      return;
    }

    const currentPoints = Number(userSnap.data()?.points ?? 0);

    tx.update(userRef, {
      points: currentPoints + refundPoints,
      updatedAt: now,
    });

    tx.update(jobRef, {
      "billing.refundedPoints": refundPoints,
      updatedAt: now,
    });
  });
}

async function generateForPosition(
  genAi: GoogleGenAI,
  jobRef: admin.firestore.DocumentReference,
  jobId: string,
  job: GenerationJob,
  prompt: string,
  position: string,
  referenceImageUrl: string,
  billing: BillingConfig
): Promise<AttemptResult> {
  const storageRef = parseStorageReference(referenceImageUrl);
  if (!storageRef) {
    throw new Error(`Unsupported reference image URL: ${referenceImageUrl}`);
  }

  const { base64, contentType } = await downloadImageAsInlineData(storageRef.bucket, storageRef.path);
  const bucket = storage.bucket();

  let paidRetriesUsed = 0;
  let chargedRetryPoints = 0;

  for (let attempt = 1; attempt <= MAX_GENERATION_ATTEMPTS; attempt++) {
    try {
      if (attempt > 1) {
        const delayMs = Math.min(2000 * 2 ** (attempt - 2), 12000);
        await sleep(delayMs);

        if (paidRetriesUsed < billing.maxPaidRetriesPerAngle) {
          await chargeRetryPoints(
            job.userId,
            jobRef,
            billing.retryCostPerAttempt,
            position,
            attempt
          );
          paidRetriesUsed += 1;
          chargedRetryPoints += billing.retryCostPerAttempt;
        }
      }

      const generationPrompt = [
        prompt,
        `The input photo is the ${position} angle. Edit this exact photo with the requested style.`,
        "Preserve the person identity and face structure exactly.",
        "Keep framing and aspect ratio consistent with the reference image.",
        "Output a realistic professional photograph.",
      ].join(" ");

      const response = await genAi.models.generateContent({
        model: GEMINI_IMAGE_MODEL,
        contents: [
          {
            role: "user",
            parts: [
              { text: generationPrompt },
              {
                inlineData: {
                  mimeType: contentType,
                  data: base64,
                },
              },
            ],
          },
        ],
        config: {
          responseModalities: [Modality.TEXT, Modality.IMAGE],
        },
      });

      const image = extractImageFromResponse(response);
      if (!image) {
        throw new Error("Gemini returned text only or no image output.");
      }

      const extension = extensionForContentType(image.contentType);
      const imagePath = `generated/${job.userId}/${jobId}_${position}.${extension}`;
      const file = bucket.file(imagePath);

      await file.save(image.buffer, {
        contentType: image.contentType,
        resumable: false,
      });

      const gsUrl = `gs://${bucket.name}/${imagePath}`;

      await db.collection("history").add({
        userId: job.userId,
        imageUrl: gsUrl,
        haircut: job.haircutName ?? "N/A",
        beard: job.beardName ?? "N/A",
        position,
        jobId,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        gsUrl,
        retriesCharged: paidRetriesUsed,
        chargedRetryPoints,
      };
    } catch (error) {
      const shouldRetry = attempt < MAX_GENERATION_ATTEMPTS && isRetryableError(error);
      console.error(`Generation failed at ${position} attempt ${attempt}:`, error);
      if (!shouldRetry) {
        throw error;
      }
    }
  }

  throw new Error(`Failed to generate image for ${position}.`);
}

export const scheduleJobProcessor = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    if (!vertexProject) {
      console.error("Vertex AI configuration missing. Project ID not found.");
      return null;
    }

    const genAi = new GoogleGenAI({
      vertexai: true,
      project: vertexProject,
      location: vertexLocation,
    });

    const snapshot = await db
      .collection("aiJobs")
      .where("status", "==", "queued")
      .orderBy("createdAt", "asc")
      .limit(3)
      .get();

    if (snapshot.empty) {
      return null;
    }

    for (const doc of snapshot.docs) {
      const jobRef = doc.ref;
      const job = doc.data() as GenerationJob;

      try {
        await db.runTransaction(async (tx) => {
          const fresh = await tx.get(jobRef);
          if (!fresh.exists || fresh.data()?.status !== "queued") {
            return;
          }

          tx.update(jobRef, {
            status: "processing",
            processingStartedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        });

        const prompt = job.prompt?.toString() ?? "";
        if (!prompt) {
          throw new Error("Missing prompt");
        }

        const referenceImages = job.referenceImages || {
          front: null,
          left: null,
          right: null,
          back: null,
        };

        const positions = ["front", "left", "right", "back"] as const;
        const validPositions = positions.filter((position) => {
          const value = referenceImages[position];
          return typeof value === "string" && value.trim().length > 0;
        });

        if (validPositions.length === 0) {
          throw new Error("No reference images found");
        }

        const billing = getBillingConfig(job);
        const generatedImages: string[] = [];
        const failedPositions: string[] = [];
        const perPositionErrors: Record<string, string> = {};
        let totalRetryChargedPoints = 0;

        for (const position of validPositions) {
          const referenceImageUrl = referenceImages[position];
          if (!referenceImageUrl) {
            failedPositions.push(position);
            perPositionErrors[position] = `Missing reference image for ${position}`;
            continue;
          }

          try {
            const result = await generateForPosition(
              genAi,
              jobRef,
              doc.id,
              job,
              prompt,
              position,
              referenceImageUrl,
              billing
            );

            generatedImages.push(result.gsUrl);
            totalRetryChargedPoints += result.chargedRetryPoints;
          } catch (error) {
            failedPositions.push(position);
            perPositionErrors[position] = `${error}`;
          }
        }

        const allFailed = generatedImages.length === 0;
        const partialFailure = generatedImages.length > 0 && failedPositions.length > 0;

        const currentTotalCharged =
          Number(billing.baseChargedPoints) +
          Number(billing.retryChargedPoints) +
          Number(totalRetryChargedPoints);

        let refundPoints = 0;
        if (allFailed) {
          refundPoints = Math.floor(currentTotalCharged * 0.9);
        } else if (partialFailure) {
          refundPoints = failedPositions.length * billing.costPerAngle;
        }

        if (refundPoints > 0) {
          await applyRefund(job.userId, jobRef, refundPoints);
        }

        if (allFailed) {
          await jobRef.update({
            status: "error",
            generatedImages: [],
            imageCount: 0,
            failedPositions,
            perPositionErrors,
            errorMessage: "Failed to generate any images.",
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          continue;
        }

        await jobRef.update({
          status: "completed",
          generatedImages,
          imageCount: generatedImages.length,
          failedPositions,
          perPositionErrors,
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (error) {
        console.error("Generation job failed:", error);
        await jobRef.update({
          status: "error",
          errorMessage: `${error}`,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    return null;
  });
