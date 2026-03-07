import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

const PROFILE_FIELDS = [
  "username",
  "displayName",
  "email",
  "bio",
  "photoURL",
  "hairType",
  "faceShape",
  "preferredLength",
  "hasBeard",
  "beardStyle",
  "lifestyle",
  "photoPaths",
] as const;

type ProfileField = (typeof PROFILE_FIELDS)[number];

function pickProfileFields(data: Record<string, unknown>): Partial<Record<ProfileField, unknown>> {
  const picked: Partial<Record<ProfileField, unknown>> = {};
  for (const key of PROFILE_FIELDS) {
    if (data[key] !== undefined && data[key] !== null) {
      picked[key] = data[key];
    }
  }
  return picked;
}

function hasAnyProfileField(data: Record<string, unknown>): boolean {
  return PROFILE_FIELDS.some((key) => data[key] !== undefined && data[key] !== null);
}

function resolveLegacyProfileUserId(
  docId: string,
  data: Record<string, unknown>
): string | null {
  const explicitUserId = data.userId;
  if (typeof explicitUserId === "string" && explicitUserId.trim().length > 0) {
    return explicitUserId.trim();
  }

  const uid = data.uid;
  if (typeof uid === "string" && uid.trim().length > 0) {
    return uid.trim();
  }

  if (docId.trim().length > 0) {
    return docId.trim();
  }

  return null;
}

export async function up(db: admin.firestore.Firestore) {
  console.log("Running migration 004: consolidate_profile_collections");

  let batch = db.batch();
  let pendingOps = 0;

  const commitIfNeeded = async (force = false) => {
    if (!force && pendingOps < 400) {
      return;
    }
    if (pendingOps === 0) {
      return;
    }
    await batch.commit();
    batch = db.batch();
    pendingOps = 0;
  };

  let migratedUserProfiles = 0;
  let deletedUserProfiles = 0;

  const userProfilesSnap = await db.collection("userProfiles").get();
  for (const doc of userProfilesSnap.docs) {
    const data = doc.data() as Record<string, unknown>;
    const profileFields = pickProfileFields(data);

    if (Object.keys(profileFields).length > 0) {
      const userRef = db.collection("users").doc(doc.id);
      batch.set(
        userRef,
        {
          ...profileFields,
          userId: doc.id,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      pendingOps += 1;
      migratedUserProfiles += 1;
    }

    batch.delete(doc.ref);
    pendingOps += 1;
    deletedUserProfiles += 1;

    await commitIfNeeded();
  }

  let migratedLegacyProfileDocs = 0;
  let deletedLegacyProfileDocs = 0;
  let retainedAppConfigProfileDocs = 0;

  const profileSnap = await db.collection("profile").get();
  for (const doc of profileSnap.docs) {
    const data = doc.data() as Record<string, unknown>;
    if (!hasAnyProfileField(data)) {
      retainedAppConfigProfileDocs += 1;
      continue;
    }

    const userId = resolveLegacyProfileUserId(doc.id, data);
    if (!userId) {
      retainedAppConfigProfileDocs += 1;
      continue;
    }

    const profileFields = pickProfileFields(data);
    const userRef = db.collection("users").doc(userId);
    batch.set(
      userRef,
      {
        ...profileFields,
        userId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    pendingOps += 1;
    migratedLegacyProfileDocs += 1;

    batch.delete(doc.ref);
    pendingOps += 1;
    deletedLegacyProfileDocs += 1;

    await commitIfNeeded();
  }

  await commitIfNeeded(true);

  console.log(`Migrated userProfiles docs into users: ${migratedUserProfiles}`);
  console.log(`Deleted userProfiles docs: ${deletedUserProfiles}`);
  console.log(`Migrated legacy profile docs into users: ${migratedLegacyProfileDocs}`);
  console.log(`Deleted legacy profile docs: ${deletedLegacyProfileDocs}`);
  console.log(`Retained app-config profile docs: ${retainedAppConfigProfileDocs}`);
}

export async function down(_db: admin.firestore.Firestore) {
  console.log("No rollback for migration 004: consolidate_profile_collections");
}

export const migration = {
  id: "004_consolidate_profile_collections",
  description:
    "Migrate legacy userProfiles/profile user data into users and clean up migrated docs",
  up,
  down,
};
