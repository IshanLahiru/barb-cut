import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/** Cost in points per generation job (one job = multiple images). */
const COST_PER_GENERATION = 1;

type CreateGenerationJobInput = {
  haircutId?: string;
  beardId?: string;
};

type HaircutData = {
  id: string;
  name: string;
  description?: string;
  suitableFaceShapes?: string[];
  maintenanceTips?: string[];
};

type BeardData = {
  id: string;
  name: string;
  description?: string;
  tips?: string;
  suitableFaceShapes?: string[];
  maintenanceTips?: string[];
};

type UserPhotos = {
  front?: string;
  left?: string;
  right?: string;
  back?: string;
};

type ReferenceImages = {
  front: string | null;
  left: string | null;
  right: string | null;
  back: string | null;
};

async function fetchHaircutData(
  db: admin.firestore.Firestore,
  haircutId: string
): Promise<HaircutData | null> {
  try {
    const doc = await db.collection("haircuts").doc(haircutId).get();
    if (doc.exists) {
      return doc.data() as HaircutData;
    }
  } catch (error) {
    console.error(`Failed to fetch haircut ${haircutId}:`, error);
  }
  return null;
}

async function fetchBeardData(
  db: admin.firestore.Firestore,
  beardId: string
): Promise<BeardData | null> {
  try {
    const doc = await db.collection("beard_styles").doc(beardId).get();
    if (doc.exists) {
      return doc.data() as BeardData;
    }
  } catch (error) {
    console.error(`Failed to fetch beard ${beardId}:`, error);
  }
  return null;
}

async function fetchUserPhotos(
  db: admin.firestore.Firestore,
  userId: string
): Promise<ReferenceImages> {
  try {
    const doc = await db.collection("userPhotos").doc(userId).get();
    if (doc.exists) {
      const data = doc.data() as UserPhotos;
      return {
        front: data.front || null,
        left: data.left || null,
        right: data.right || null,
        back: data.back || null,
      };
    }
  } catch (error) {
    console.error(`Failed to fetch user photos for ${userId}:`, error);
  }
  return {
    front: null,
    left: null,
    right: null,
    back: null,
  };
}

function buildPrompt(haircut: HaircutData | null, beard: BeardData | null): string {
  const parts: string[] = [];

  if (haircut) {
    parts.push(`haircut: ${haircut.name}`);
    if (haircut.description) {
      parts.push(`${haircut.description}`);
    }
  }

  if (beard) {
    parts.push(`beard: ${beard.name}`);
    if (beard.description) {
      parts.push(`${beard.description}`);
    }
  }

  const basePrompt = `A professional barber shop portrait showcasing ${parts.join(", ")}. Professional studio lighting, sharp focus, pristine barbershop background, high quality professional photography.`;

  return basePrompt;
}

export const createGenerationJob = functions.https.onCall(
  async (data: CreateGenerationJobInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to create a generation job."
      );
    }

    const userId = context.auth.uid;
    const db = admin.firestore();

    // Fetch haircut and beard data from Firestore
    let haircutData: HaircutData | null = null;
    let beardData: BeardData | null = null;
    let userPhotos: ReferenceImages = {
      front: null,
      left: null,
      right: null,
      back: null,
    };

    if (data.haircutId) {
      haircutData = await fetchHaircutData(db, data.haircutId);
    }

    if (data.beardId) {
      beardData = await fetchBeardData(db, data.beardId);
    }

    // Fetch user's reference photos
    userPhotos = await fetchUserPhotos(db, userId);

    // Check if user has at least one photo
    const photoUrls = Object.values(userPhotos).filter(url => url !== null);
    if (photoUrls.length === 0) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Please upload at least one face photo before generating styles."
      );
    }

    // Build prompt from fetched data
    const prompt = buildPrompt(haircutData, beardData);
    const now = admin.firestore.FieldValue.serverTimestamp();
    const userRef = db.collection("users").doc(userId);

    // Deduct points and create job in one transaction (idempotent: no double-deduct)
    const jobId = await db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      const currentPoints = (userSnap.data()?.points ?? 0) as number;
      if (currentPoints < COST_PER_GENERATION) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Insufficient points. Please purchase more credits to generate."
        );
      }
      const newPoints = currentPoints - COST_PER_GENERATION;
      tx.update(userRef, {
        points: newPoints,
        updatedAt: now,
      });

      const jobRef = db.collection("aiJobs").doc();
      tx.set(jobRef, {
        userId,
        status: "queued",
        prompt,
        model: "imagen3",
        haircutId: data.haircutId ?? null,
        haircutName: haircutData?.name ?? null,
        beardId: data.beardId ?? null,
        beardName: beardData?.name ?? null,
        referenceImages: {
          front: userPhotos.front,
          left: userPhotos.left,
          right: userPhotos.right,
          back: userPhotos.back,
        },
        imageCount: photoUrls.length,
        generatedImages: [],
        createdAt: now,
        updatedAt: now,
        scheduledAt: now,
      });
      return jobRef.id;
    });

    return {
      success: true,
      jobId,
      status: "queued",
      imageCount: photoUrls.length,
    };
  }
);
