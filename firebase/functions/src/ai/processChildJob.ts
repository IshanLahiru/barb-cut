import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenAI, Modality } from "@google/genai";

const db = admin.firestore();
const storage = admin.storage();

const vertexProject = process.env.GCLOUD_PROJECT;
const vertexLocation = process.env.VERTEX_LOCATION || "global";
const GEMINI_IMAGE_MODEL = process.env.GEMINI_IMAGE_MODEL || "gemini-2.5-flash-image";

const MAX_GENERATION_ATTEMPTS = 5;

type ChildJob = {
  parentJobId: string;
  angle: string;
  status: "blocked" | "pending" | "processing" | "completed" | "error";
  referenceImage: string;
  generatedImage: string | null;
  errorMessage: string | null;
  prompt: string;
  retryCount: number;
  costCharged: number;
  createdAt: any;
  updatedAt: any;
};

type ParentJob = {
  userId: string;
  status: string;
  hasBeardStyle: boolean;
  childJobIds: string[];
  totalCost: number;
  [key: string]: any;
};

function parseStorageReference(value: string): { bucket: string; path: string } | null {
  if (value.startsWith("gs://")) {
    const withoutScheme = value.replace("gs://", "");
    const slashIndex = withoutScheme.indexOf("/");
    if (slashIndex === -1) return null;
    return {
      bucket: withoutScheme.substring(0, slashIndex),
      path: withoutScheme.substring(slashIndex + 1),
    };
  }

  if (!value.startsWith("http")) return null;

  try {
    const url = new URL(value);
    if (url.host.includes("firebasestorage.googleapis.com")) {
      const segments = url.pathname.split("/").filter(Boolean);
      const bucketIndex = segments.indexOf("b");
      const objectIndex = segments.indexOf("o");
      if (bucketIndex !== -1 && objectIndex !== -1) {
        return {
          bucket: segments[bucketIndex + 1],
          path: decodeURIComponent(segments[objectIndex + 1]),
        };
      }
    }
  } catch (error) {
    console.warn("Failed to parse storage reference:", error);
  }

  return null;
}

async function downloadImageAsInlineData(
  bucketName: string,
  path: string
): Promise<{ base64: string; contentType: string }> {
  const bucketRef = storage.bucket(bucketName);
  const fileRef = bucketRef.file(path);
  const [buffer] = await fileRef.download();
  const [metadata] = await fileRef.getMetadata();

  const contentType = metadata.contentType || "image/jpeg";
  return {
    base64: buffer.toString("base64"),
    contentType,
  };
}

function extractImageFromResponse(response: any): Buffer | null {
  const candidates = response?.candidates;
  if (!Array.isArray(candidates)) return null;

  for (const candidate of candidates) {
    const parts = candidate?.content?.parts;
    if (!Array.isArray(parts)) continue;

    for (const part of parts) {
      const inlineData = part?.inlineData;
      if (inlineData?.data) {
        return Buffer.from(inlineData.data, "base64");
      }
    }
  }

  return null;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isRetryableError(error: unknown): boolean {
  const message = `${error}`.toLowerCase();
  return (
    message.includes("deadline") ||
    message.includes("timeout") ||
    message.includes("unavailable") ||
    message.includes("rate") ||
    message.includes("internal") ||
    message.includes("resource exhausted") ||
    message.includes("429") ||
    message.includes("quota exceeded")
  );
}

function is429Error(error: unknown): boolean {
  const message = `${error}`.toLowerCase();
  const errorStr = `${error}`;
  return (
    message.includes("resource exhausted") ||
    message.includes("429") ||
    message.includes("too many requests") ||
    errorStr.includes('"code":429') ||
    message.includes("quota exceeded")
  );
}

function calculateBackoffMs(attempt: number, is429: boolean): number {
  if (is429) {
    // For 429 errors, use longer exponential backoff: 2s, 8s, 32s, 128s, 512s
    const baseMs = 2000 * Math.pow(4, attempt - 2);
    const maxMs = 300000; // 5 minutes max for 429
    return Math.min(baseMs, maxMs);
  } else {
    // For other retryable errors: 1s, 2s, 4s, 8s, 16s
    const baseMs = 1000 * Math.pow(2, attempt - 2);
    const maxMs = 30000; // 30s max for other errors
    return Math.min(baseMs, maxMs);
  }
}

function addJitter(delayMs: number): number {
  // Add random jitter up to 10% to prevent thundering herd
  const jitter = Math.random() * delayMs * 0.1;
  return Math.floor(delayMs + jitter);
}

export const processChildJob = functions.firestore
  .document("aiJobs/{parentJobId}/childJobs/{childJobId}")
  .onWrite(async (change, context) => {
    const newData = change.after.exists ? (change.after.data() as ChildJob) : null;
    const oldData = change.before.exists ? (change.before.data() as ChildJob) : null;

    // Only process when status transitions to "pending" (newly created)
    if (!newData || newData.status !== "pending") {
      return null;
    }

    if (oldData && oldData.status === "pending") {
      return null; // Already started processing
    }

    if (!vertexProject) {
      console.error("Vertex AI configuration missing. Project ID not found.");
      return null;
    }

    const { parentJobId, childJobId } = context.params;
    const childJobRef = db
      .collection("aiJobs")
      .doc(parentJobId)
      .collection("childJobs")
      .doc(childJobId);

    try {
      const genAi = new GoogleGenAI({
        vertexai: true,
        project: vertexProject,
        location: vertexLocation,
      });

      // Update status to "processing"
      await childJobRef.update({
        status: "processing",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const { referenceImage, prompt, angle } = newData;

      if (!referenceImage) {
        throw new Error(`No reference image for angle ${angle}`);
      }

      const storageRef = parseStorageReference(referenceImage);
      if (!storageRef) {
        throw new Error(`Unsupported reference image URL: ${referenceImage}`);
      }

      // Download reference image
      const { base64, contentType } = await downloadImageAsInlineData(
        storageRef.bucket,
        storageRef.path
      );

      // Generate image with retries
      let generatedImageBuffer: Buffer | null = null;
      let lastError: Error | null = null;

      for (let attempt = 1; attempt <= MAX_GENERATION_ATTEMPTS; attempt++) {
        try {
          if (attempt > 1) {
            const is429 = is429Error(lastError);
            const delayMs = calculateBackoffMs(attempt, is429);
            const delayWithJitter = addJitter(delayMs);
            
            if (is429) {
              console.warn(
                `[429 RATE LIMIT] Angle ${angle}: Retrying after ${delayWithJitter}ms (attempt ${attempt}/${MAX_GENERATION_ATTEMPTS}). ` +
                `Consider using Provisioned Throughput for consistent service.`
              );
            } else {
              console.warn(
                `[RETRY] Angle ${angle}: Retrying after ${delayWithJitter}ms (attempt ${attempt}/${MAX_GENERATION_ATTEMPTS})`
              );
            }
            
            await sleep(delayWithJitter);
          }

          const generationPrompt = [
            prompt,
            `The input photo is the ${angle.toLowerCase()} angle. Edit this exact photo with the requested style.`,
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

          generatedImageBuffer = extractImageFromResponse(response);
          if (!generatedImageBuffer) {
            throw new Error("Gemini returned text only or no image output.");
          }

          break; // Success, exit retry loop
        } catch (error) {
          lastError = error as Error;
          const shouldRetry = attempt < MAX_GENERATION_ATTEMPTS && isRetryableError(error);
          const is429 = is429Error(error);
          
          if (is429) {
            console.error(
              `[429 RATE LIMIT] Generation failed at ${angle} attempt ${attempt}/${MAX_GENERATION_ATTEMPTS}:`,
              error
            );
          } else {
            console.error(`Generation failed at ${angle} attempt ${attempt}/${MAX_GENERATION_ATTEMPTS}:`, error);
          }

          if (!shouldRetry) {
            break;
          }
        }
      }

      if (!generatedImageBuffer) {
        let finalError = lastError || new Error("Failed to generate image.");
        
        if (is429Error(finalError)) {
          console.error(
            `[SUCCESS REQUIRED] Angle ${angle} exhausted retries due to 429 rate limiting. ` +
            `Project barb-cut is hitting Vertex AI quota limits. ` +
            `Recommendations: 1) Use Provisioned Throughput for guaranteed capacity, ` +
            `2) Use global endpoint (already configured), 3) Implement request queuing client-side.`
          );
          finalError = new Error(
            `Rate limit exceeded (429). Max ${MAX_GENERATION_ATTEMPTS} retries exhausted. ` +
            `Please try again later or contact support.`
          );
        }
        
        throw finalError;
      }

      // Upload to Firebase Storage
      const bucket = storage.bucket();
      const ext = contentType === "image/png" ? "png" : "jpg";
      const imagePath = `generated/${parentJobId}/${childJobId}_${angle}.${ext}`;
      const file = bucket.file(imagePath);

      await file.save(generatedImageBuffer, {
        contentType,
        resumable: false,
      });

      const generatedImageUrl = `gs://${bucket.name}/${imagePath}`;

      // Update child job as completed
      await childJobRef.update({
        status: "completed",
        generatedImage: generatedImageUrl,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Check if all sibling jobs are complete/error and aggregate parent status
      await aggregateParentJobStatus(parentJobId);
    } catch (error) {
      const is429 = is429Error(error);
      const errorMsg = `${error}`;
      
      let userFacingMessage = errorMsg;
      if (is429) {
        userFacingMessage = "Rate limit exceeded. The service was temporarily unavailable. Please try again later.";
        console.error(
          `[429 RATE LIMIT FAILURE] Child job processing failed for ${newData.angle}: ` +
          `Project may need Provisioned Throughput. Error:`,
          error
        );
      } else {
        console.error(`Child job processing failed for ${newData.angle}:`, error);
      }

      await childJobRef.update({
        status: "error",
        errorMessage: userFacingMessage,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Recheck parent status (might be time to create history)
      await aggregateParentJobStatus(parentJobId);
    }
  });

async function aggregateParentJobStatus(parentJobId: string): Promise<void> {
  const parentJobRef = db.collection("aiJobs").doc(parentJobId);
  const childJobsRef = parentJobRef.collection("childJobs");

  const parentSnap = await parentJobRef.get();
  if (!parentSnap.exists) {
    return;
  }
  const parentData = parentSnap.data() as ParentJob;

  const childSnaps = await childJobsRef.get();
  const childJobs = childSnaps.docs.map((snap) => snap.data() as ChildJob);

  // Sequential orchestration: if nothing is active, promote exactly one blocked child to pending.
  const hasActiveJob = childJobs.some(
    (c) => c.status === "pending" || c.status === "processing"
  );
  if (!hasActiveJob) {
    const childById = new Map(
      childSnaps.docs.map((snap) => [snap.id, snap.data() as ChildJob])
    );

    const nextBlockedId =
      parentData.childJobIds?.find(
        (childJobId) => childById.get(childJobId)?.status === "blocked"
      ) || childSnaps.docs.find((snap) => (snap.data() as ChildJob).status === "blocked")?.id;

    if (nextBlockedId) {
      await childJobsRef.doc(nextBlockedId).update({
        status: "pending",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }
  }

  // Check if all are finalized
  const allFinalized = childJobs.every((c) => c.status === "completed" || c.status === "error");
  if (!allFinalized) {
    return; // Wait for more jobs to finish
  }

  const completedJobs = childJobs.filter((c) => c.status === "completed");
  const failedJobs = childJobs.filter((c) => c.status === "error");

  // All failed: apply 90% refund
  if (completedJobs.length === 0 && failedJobs.length > 0) {
    const refundPoints = Math.floor(parentData.totalCost * 0.9);
    await applyRefund(parentData.userId, refundPoints);

    await parentJobRef.update({
      status: "error",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return;
  }

  // Partial failure: refund 1 point per failed angle
  if (failedJobs.length > 0) {
    const refundPoints = failedJobs.length * 1; // 1 point per failed angle
    await applyRefund(parentData.userId, refundPoints);
  }

  // Create history document and delete parent job
  await createHistoryAndCleanup(parentJobId, parentData, completedJobs);
}

async function createHistoryAndCleanup(
  parentJobId: string,
  parentData: ParentJob,
  completedJobs: ChildJob[]
): Promise<void> {
  const now = admin.firestore.FieldValue.serverTimestamp();

  // Format generated images by angle
  const generatedImages: Record<string, string> = {};
  const failedAngles: string[] = [];

  for (const job of completedJobs) {
    if (job.generatedImage) {
      generatedImages[job.angle.toLowerCase()] = job.generatedImage;
    }
  }

  // Get failed angles from child jobs
  const childSnaps = await db
    .collection("aiJobs")
    .doc(parentJobId)
    .collection("childJobs")
    .get();

  childSnaps.forEach((snap) => {
    const child = snap.data() as ChildJob;
    if (child.status === "error") {
      failedAngles.push(child.angle);
    }
  });

  // Create history document
  const historyRef = db.collection("history").doc();
  await historyRef.set({
    schemaVersion: 2,
    userId: parentData.userId,
    parentJobId,
    haircutId: parentData.haircutId,
    haircutName: parentData.haircutName,
    beardId: parentData.beardId,
    beardName: parentData.beardName,
    generatedImages, // Flattened: { front: url, left: url, right: url, back: url }
    failedAngles,
    totalCost: parentData.totalCost,
    angleCount: parentData.angleCount,
    completedAt: now,
    createdAt: now,
  });

  // Delete parent job and all child jobs to save storage
  const batch = db.batch();

  // Delete all child jobs
  childSnaps.forEach((snap) => {
    batch.delete(snap.ref);
  });

  // Delete parent job
  batch.delete(db.collection("aiJobs").doc(parentJobId));

  await batch.commit();

  console.log(
    `History created (${historyRef.id}) and parent job (${parentJobId}) deleted.`
  );
}

async function applyRefund(userId: string, refundPoints: number): Promise<void> {
  if (refundPoints <= 0) return;

  const userRef = db.collection("users").doc(userId);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    const currentPoints = (userSnap.data()?.points ?? 0) as number;

    tx.update(userRef, {
      points: currentPoints + refundPoints,
      updatedAt: now,
    });
  });

  console.log(`Refunded ${refundPoints} points to user ${userId}`);
}
