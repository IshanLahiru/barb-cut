import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const COST_PER_ANGLE = 1;
const RETRY_COST_PER_ANGLE = 1;
const MAX_PAID_RETRIES_PER_ANGLE = 2;

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

type UserHairData = {
  hairType?: string; // e.g., "straight", "wavy", "curly", "coily"
  hairTexture?: string; // e.g., "fine", "medium", "thick"
  hairLength?: string; // e.g., "short", "medium", "long"
  hairColor?: string; // e.g., "black", "brown", "blonde", "red", "gray"
  faceShape?: string; // e.g., "oval", "round", "square", "heart", "diamond"
  skinTone?: string; // e.g., "fair", "medium", "olive", "tan", "dark"
  hairDensity?: string; // e.g., "thin", "medium", "thick"
  scalpCondition?: string; // e.g., "normal", "dry", "oily"
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

async function fetchUserHairData(
  db: admin.firestore.Firestore,
  userId: string
): Promise<UserHairData | null> {
  try {
    const doc = await db.collection("userProfiles").doc(userId).get();
    if (doc.exists) {
      const data = doc.data();
      return {
        hairType: data?.hairType,
        hairTexture: data?.hairTexture,
        hairLength: data?.hairLength,
        hairColor: data?.hairColor,
        faceShape: data?.faceShape,
        skinTone: data?.skinTone,
        hairDensity: data?.hairDensity,
        scalpCondition: data?.scalpCondition,
      } as UserHairData;
    }
  } catch (error) {
    console.error(`Failed to fetch user hair data for ${userId}:`, error);
  }
  return null;
}

function buildPrompt(
  haircut: HaircutData | null,
  beard: BeardData | null,
  userHairData: UserHairData | null
): string {
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

  // Enhance prompt with user's actual hair characteristics
  const characteristics: string[] = [];
  if (userHairData) {
    if (userHairData.hairType) {
      characteristics.push(`${userHairData.hairType} hair`);
    }
    if (userHairData.hairTexture) {
      characteristics.push(`${userHairData.hairTexture} texture`);
    }
    if (userHairData.hairColor) {
      characteristics.push(`${userHairData.hairColor} hair color`);
    }
    if (userHairData.faceShape) {
      characteristics.push(`${userHairData.faceShape} face shape`);
    }
    if (userHairData.skinTone) {
      characteristics.push(`${userHairData.skinTone} skin tone`);
    }
  }

    // Build clear instructions for image editing
    let basePrompt = "Edit and transform the person in the provided reference photo. ";
  
    basePrompt += "Apply the following style changes while preserving their facial features, identity, and natural appearance: ";
  
    if (parts.length > 0) {
      basePrompt += `${parts.join(", ")}. `;
    }
  
    if (characteristics.length > 0) {
      basePrompt += `The person has ${characteristics.join(", ")}. `;
    }
  
    basePrompt += "Create a professional barber shop portrait with the new hairstyle and/or beard style seamlessly applied. ";
    basePrompt += "Maintain realistic proportions, natural hairline, proper hair flow and texture. ";
    basePrompt += "Use professional studio lighting, sharp focus, clean barbershop background. ";
    basePrompt += "The result should look like a real professional photograph, not a digital composite. ";
    basePrompt += "Preserve skin tone, face structure, and all identifying features of the person in the photo.";

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
    let userHairData: UserHairData | null = null;

    if (data.haircutId) {
      haircutData = await fetchHaircutData(db, data.haircutId);
    }

    if (data.beardId) {
      beardData = await fetchBeardData(db, data.beardId);
    }

    // Fetch user's reference photos
    userPhotos = await fetchUserPhotos(db, userId);

    // Fetch user's hair data from onboarding questionnaire
    userHairData = await fetchUserHairData(db, userId);

    // Check if user has at least one photo
    const photoUrls = Object.values(userPhotos).filter(url => url !== null);
    if (photoUrls.length === 0) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Please upload at least one face photo before generating styles."
      );
    }

    // Build prompt from fetched data (including user hair characteristics)
    const prompt = buildPrompt(haircutData, beardData, userHairData);
    const imageCount = photoUrls.length;
    const baseChargePoints = imageCount * COST_PER_ANGLE;
    const now = admin.firestore.FieldValue.serverTimestamp();
    const userRef = db.collection("users").doc(userId);

    // Deduct points and create job in one transaction (idempotent: no double-deduct)
    const jobId = await db.runTransaction(async (tx) => {
      const userSnap = await tx.get(userRef);
      const currentPoints = (userSnap.data()?.points ?? 0) as number;
      if (currentPoints < baseChargePoints) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Insufficient points. Please purchase more credits to generate."
        );
      }
      const newPoints = currentPoints - baseChargePoints;
      tx.update(userRef, {
        points: newPoints,
        updatedAt: now,
      });

      const jobRef = db.collection("aiJobs").doc();
      tx.set(jobRef, {
        userId,
        status: "queued",
        prompt,
        model: "gemini-2.5-flash-image",
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
        userHairData: userHairData ? {
          hairType: userHairData.hairType ?? null,
          hairTexture: userHairData.hairTexture ?? null,
          hairLength: userHairData.hairLength ?? null,
          hairColor: userHairData.hairColor ?? null,
          faceShape: userHairData.faceShape ?? null,
          skinTone: userHairData.skinTone ?? null,
          hairDensity: userHairData.hairDensity ?? null,
          scalpCondition: userHairData.scalpCondition ?? null,
        } : null,
        imageCount,
        generatedImages: [],
        generationConfig: {
          targetOutput: "match_reference",
        },
        billing: {
          costPerAngle: COST_PER_ANGLE,
          retryCostPerAttempt: RETRY_COST_PER_ANGLE,
          maxPaidRetriesPerAngle: MAX_PAID_RETRIES_PER_ANGLE,
          baseChargedPoints: baseChargePoints,
          retryChargedPoints: 0,
          totalChargedPoints: baseChargePoints,
          refundedPoints: 0,
          refundPolicy: {
            allFailedPercent: 90,
            partialRefundFailedAnglesOnly: true,
            chargeAtJobCreation: true,
            chargePerRetry: true,
          },
        },
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
