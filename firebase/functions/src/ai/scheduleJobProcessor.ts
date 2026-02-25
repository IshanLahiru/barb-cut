import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { genkit } from "genkit";
import { vertexAI, imagen3 } from "@genkit-ai/vertexai";

const db = admin.firestore();
const storage = admin.storage();

const vertexProject = functions.config().vertexai?.project || "";
const vertexLocation = functions.config().vertexai?.location || "";

const ai = genkit({
  plugins: [
    vertexAI({
      projectId: vertexProject,
      location: vertexLocation,
    }),
  ],
});

if (!vertexProject || !vertexLocation) {
  console.warn(
    "Vertex AI config missing: set functions.config().vertexai.project and functions.config().vertexai.location"
  );
}

function decodeDataUrl(dataUrl: string): Buffer {
  const match = dataUrl.match(/^data:image\/(png|jpeg|jpg|webp);base64,(.+)$/);
  if (!match) {
    throw new Error("Unsupported image data format");
  }
  return Buffer.from(match[2], "base64");
}

type StorageObjectRef = {
  bucket: string;
  path: string;
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

function normalizeContentType(
  contentType: string | undefined,
  path: string
): string {
  if (contentType && contentType.startsWith("image/")) {
    return contentType;
  }
  return inferContentType(path);
}

async function downloadImageAsDataUrl(
  bucketName: string,
  path: string
): Promise<{ dataUrl: string; contentType: string }> {
  const bucketRef = storage.bucket(bucketName);
  const fileRef = bucketRef.file(path);
  const [buffer] = await fileRef.download();
  const [metadata] = await fileRef.getMetadata();
  const contentType = normalizeContentType(metadata.contentType, path);
  const base64 = buffer.toString("base64");
  return {
    dataUrl: `data:${contentType};base64,${base64}`,
    contentType,
  };
}

export const scheduleJobProcessor = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    const hasVertexConfig = Boolean(vertexProject && vertexLocation);

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
      const job = doc.data() as any;

      try {
        if (!hasVertexConfig) {
          throw new Error(
            "Vertex AI configuration missing. Set functions.config().vertexai.project and functions.config().vertexai.location."
          );
        }

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

        // Collect positions that have reference images
        const positions = ["front", "left", "right", "back"] as const;
        const validPositions = positions.filter((pos) => {
          const value = referenceImages[pos];
          return typeof value === "string" && value.trim().length > 0;
        });

        if (validPositions.length === 0) {
          throw new Error("No reference images found");
        }

        const generatedImages: string[] = [];
        const bucket = storage.bucket();

        // Generate an image for each reference photo position
        for (const position of validPositions) {
          try {
            console.log(`Generating image for position: ${position}`);

            const positionPrompt = `${prompt} This is for the ${position} view of the face.`;

            // Get the reference image from Storage
            const referenceImageUrl = referenceImages[position];
            if (!referenceImageUrl) {
              throw new Error(`Missing reference image for ${position}`);
            }

            const storageRef = parseStorageReference(referenceImageUrl);
            if (!storageRef) {
              throw new Error(`Unsupported reference image URL: ${referenceImageUrl}`);
            }

            const { dataUrl, contentType } = await downloadImageAsDataUrl(
              storageRef.bucket,
              storageRef.path
            );
            console.log(
              `Downloaded reference image ${storageRef.bucket}/${storageRef.path} (${contentType}, ${dataUrl.length} chars)`
            );

            const result = await ai.generate({
              model: imagen3,
              prompt: [
                {
                  media: {
                    url: dataUrl,
                    contentType,
                  },
                },
                { text: positionPrompt },
              ],
            });

            const media = Array.isArray(result.media)
              ? result.media[0]
              : result.media;
            if (!media?.url) {
              console.warn(`No image returned for position ${position}`);
              continue;
            }

            const buffer = decodeDataUrl(media.url);
            const imagePath = `generated/${job.userId}/${doc.id}_${position}.png`;
            const file = bucket.file(imagePath);

            await file.save(buffer, {
              contentType: "image/png",
              resumable: false,
            });

            const gsUrl = `gs://${bucket.name}/${imagePath}`;
            generatedImages.push(gsUrl);

            // Create a history document for this image
            await db.collection("history").add({
              userId: job.userId,
              imageUrl: gsUrl,
              haircut: job.haircutName ?? "N/A",
              beard: job.beardName ?? "N/A",
              position: position, // front, left, right, back
              jobId: doc.id,
              generatedAt: admin.firestore.FieldValue.serverTimestamp(),
              timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });

            console.log(`✅ Generated and stored image for ${position}`);
          } catch (positionError) {
            console.error(`Failed to generate image for position ${position}:`, positionError);
            // Continue generating other positions even if one fails
          }
        }

        if (generatedImages.length === 0) {
          throw new Error("Failed to generate any images");
        }

        // Update job with all generated images
        await jobRef.update({
          status: "completed",
          generatedImages: generatedImages,
          imageCount: generatedImages.length,
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`✅ Job ${doc.id} completed with ${generatedImages.length} images`);
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
