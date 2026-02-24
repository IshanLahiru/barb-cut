import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { genkit } from "genkit";
import { vertexAI, imagen3Fast } from "@genkit-ai/vertexai";

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
  const match = dataUrl.match(/^data:image\/(png|jpeg);base64,(.+)$/);
  if (!match) {
    throw new Error("Unsupported image data format");
  }
  return Buffer.from(match[2], "base64");
}

export const scheduleJobProcessor = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
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
        const validPositions = positions.filter(pos => referenceImages[pos] !== null);

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

            const result = await ai.generate({
              model: imagen3Fast,
              prompt: positionPrompt,
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
