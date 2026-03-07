import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { DEFAULT_FREE_CREDITS } from "../auth/userShape";

/**
 * Default values for canonical user fields when merging (migration only adds missing).
 */
const DEFAULTS: Record<string, unknown> = {
  role: "customer",
  isActive: true,
  favouritesCount: 0,
  points: DEFAULT_FREE_CREDITS,
};

/**
 * Migration 003: Normalize user documents.
 * Merges missing canonical fields into existing users (idempotent).
 * Optionally backfills favouritesCount from users/{uid}/favourites size.
 */
export async function up(db: admin.firestore.Firestore) {
  console.log("Running migration 003: normalize_user_data");

  const snapshot = await db.collection("users").get();
  let batch = db.batch();
  let batchCount = 0;
  let updatedCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const updates: Record<string, unknown> = {};
    let changed = false;

    for (const [key, defaultValue] of Object.entries(DEFAULTS)) {
      if (data[key] === undefined || data[key] === null) {
        updates[key] = defaultValue;
        changed = true;
      }
    }

    if (data.updatedAt === undefined || data.updatedAt === null) {
      updates.updatedAt = FieldValue.serverTimestamp();
      changed = true;
    }

    if (changed) {
      batch.update(doc.ref, updates);
      batchCount += 1;
      updatedCount += 1;
    }

    if (batchCount >= 450) {
      await batch.commit();
      batch = db.batch();
      batchCount = 0;
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(`Updated ${updatedCount} user documents with missing canonical fields.`);

  // Backfill favouritesCount from subcollection size (second pass to avoid read-your-write)
  let favBackfillCount = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const currentCount = typeof data.favouritesCount === "number" ? data.favouritesCount : 0;
    const favSnap = await doc.ref.collection("favourites").get();
    const actualCount = favSnap.size;
    if (actualCount !== currentCount) {
      await doc.ref.update({
        favouritesCount: actualCount,
        updatedAt: FieldValue.serverTimestamp(),
      });
      favBackfillCount += 1;
    }
  }

  if (favBackfillCount > 0) {
    console.log(`Backfilled favouritesCount for ${favBackfillCount} users.`);
  }
}

export async function down(_db: admin.firestore.Firestore) {
  console.log("No rollback for migration 003: normalize_user_data");
}

export const migration = {
  id: "003_normalize_user_data",
  description: "Merge missing canonical user fields and backfill favouritesCount",
  up,
  down,
};
