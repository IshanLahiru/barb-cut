import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const COST_PER_ANGLE = 1;
const RETRY_COST_PER_ANGLE = 1;
const MAX_PAID_RETRIES_PER_ANGLE = 2;

type CreateGenerationJobInput = {
  haircutId?: string;
  beardId?: string;
  angles?: string[];
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
  hairType?: string;
  hairTexture?: string;
  hairLength?: string;
  hairColor?: string;
  faceShape?: string;
  skinTone?: string;
  hairDensity?: string;
  scalpCondition?: string;
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

type AngleType = "FRONT" | "LEFT" | "RIGHT" | "BACK";

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
    const now = admin.firestore.FieldValue.serverTimestamp();

    // Fetch all required data
    let haircutData: HaircutData | null = null;
    let beardData: BeardData | null = null;
    const userPhotos = await fetchUserPhotos(db, userId);
    const userHairData = await fetchUserHairData(db, userId);

    if (data.haircutId) {
      haircutData = await fetchHaircutData(db, data.haircutId);
    }

    if (data.beardId) {
      beardData = await fetchBeardData(db, data.beardId);
    }

    // Check if user has at least one photo
    const photoUrls = Object.values(userPhotos).filter((url) => url !== null);
    if (photoUrls.length === 0) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Please upload at least one face photo before generating styles."
      );
    }

    const hasHaircutStyle = !!data.haircutId;
    const hasBeardStyle = !!data.beardId;

    // Use user-provided angles if available, otherwise determine based on styles
    let angles: AngleType[];
    if (data.angles && Array.isArray(data.angles) && data.angles.length > 0) {
      // Validate provided angles
      const validAngles = ["FRONT", "LEFT", "RIGHT", "BACK"];
      angles = data.angles.filter((angle) =>
        validAngles.includes(angle)
      ) as AngleType[];
      
      if (angles.length === 0) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "At least one valid angle must be selected (FRONT, LEFT, RIGHT, or BACK)."
        );
      }
    } else {
      // Fallback to auto-determining angles (backward compatibility)
      // - Haircut only: 4 angles (FRONT, LEFT, RIGHT, BACK)
      // - Haircut + Beard: 4 angles (FRONT, LEFT, RIGHT, BACK)
      // - Beard only: 3 angles (FRONT, LEFT, RIGHT)
      angles = ["FRONT", "LEFT", "RIGHT"];
      if (hasHaircutStyle) {
        // Always include BACK angle when haircut is involved
        angles.push("BACK");
      }
    }

    // Validate that user has photos for all selected angles
    const missingAngles: string[] = [];
    for (const angle of angles) {
      const angleKey = angle.toLowerCase() as keyof UserPhotos;
      if (!userPhotos[angleKey]) {
        missingAngles.push(angle);
      }
    }

    if (missingAngles.length > 0) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        `Missing photos for selected angles: ${missingAngles.join(", ")}. Please upload photos for all angles or deselect missing angles.`
      );
    }

    // Build shared prompt
    const prompt = buildPrompt(haircutData, beardData, userHairData);
    const baseChargePoints = angles.length * COST_PER_ANGLE;
    const userRef = db.collection("users").doc(userId);

    // Create parent job + child jobs in one transaction
    const result = await db.runTransaction(async (tx) => {
      // Check user points
      const userSnap = await tx.get(userRef);
      const currentPoints = (userSnap.data()?.points ?? 0) as number;
      if (currentPoints < baseChargePoints) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Insufficient points. Please purchase more credits to generate."
        );
      }

      // Create parent job
      const parentJobRef = db.collection("aiJobs").doc();
      const parentJobId = parentJobRef.id;

      // Generate child job IDs for each angle
      const childJobIds: string[] = [];
      const childRefs: { angle: AngleType; ref: admin.firestore.DocumentReference }[] = [];

      for (const angle of angles) {
        const childRef = parentJobRef.collection("childJobs").doc();
        childJobIds.push(childRef.id);
        childRefs.push({ angle, ref: childRef });
      }

      // Deduct points from user
      const newPoints = currentPoints - baseChargePoints;
      tx.update(userRef, {
        points: newPoints,
        updatedAt: now,
      });

      // Create parent job document
      tx.set(parentJobRef, {
        schemaVersion: 2,
        userId,
        status: "generating",
        haircutId: data.haircutId ?? null,
        haircutName: haircutData?.name ?? null,
        beardId: data.beardId ?? null,
        beardName: beardData?.name ?? null,
        hasBeardStyle,
        childJobIds,
        angleCount: angles.length,
        totalCost: baseChargePoints,
        referenceImages: {
          front: userPhotos.front,
          left: userPhotos.left,
          right: userPhotos.right,
          back: userPhotos.back,
        },
        userHairData: userHairData
          ? {
              hairType: userHairData.hairType ?? null,
              hairTexture: userHairData.hairTexture ?? null,
              hairLength: userHairData.hairLength ?? null,
              hairColor: userHairData.hairColor ?? null,
              faceShape: userHairData.faceShape ?? null,
              skinTone: userHairData.skinTone ?? null,
              hairDensity: userHairData.hairDensity ?? null,
              scalpCondition: userHairData.scalpCondition ?? null,
            }
          : null,
        createdAt: now,
        updatedAt: now,
      });

      // Create child job documents
      for (const [index, { angle, ref }] of childRefs.entries()) {
        const angleKey = angle.toLowerCase();
        const referenceImage =
          userPhotos[angleKey as keyof ReferenceImages];

        tx.set(ref, {
          schemaVersion: 2,
          parentJobId,
          angle,
          status: index === 0 ? "pending" : "blocked",
          referenceImage,
          generatedImage: null,
          errorMessage: null,
          prompt,
          retryCount: 0,
          costCharged: COST_PER_ANGLE,
          createdAt: now,
          updatedAt: now,
        });
      }

      return { parentJobId, childJobIds, angleCount: angles.length };
    });

    return {
      success: true,
      parentJobId: result.parentJobId,
      childJobIds: result.childJobIds,
      angleCount: result.angleCount,
      status: "generating",
    };
  }
);
