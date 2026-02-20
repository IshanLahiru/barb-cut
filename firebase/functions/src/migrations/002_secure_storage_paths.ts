import * as admin from "firebase-admin";

function normalizeStoragePath(value: string): string | null {
  try {
    if (value.startsWith("gs://")) {
      const withoutScheme = value.replace("gs://", "");
      const slashIndex = withoutScheme.indexOf("/");
      if (slashIndex !== -1) {
        return withoutScheme.slice(slashIndex + 1);
      }
      return null;
    }

    if (!value.startsWith("http")) {
      return null;
    }

    const url = new URL(value);

    if (url.hostname.includes("firebasestorage.googleapis.com")) {
      const segments = url.pathname.split("/").filter(Boolean);
      const oIndex = segments.indexOf("o");
      if (oIndex !== -1 && segments.length > oIndex + 1) {
        return decodeURIComponent(segments[oIndex + 1]);
      }
    }

    if (url.hostname.includes("storage.googleapis.com")) {
      const segments = url.pathname.split("/").filter(Boolean);
      if (segments.length >= 2) {
        return segments.slice(1).join("/");
      }
    }

    return null;
  } catch (error) {
    return null;
  }
}

function normalizeImageMap(images: Record<string, unknown>): {
  changed: boolean;
  normalized: Record<string, unknown>;
} {
  const normalized: Record<string, unknown> = { ...images };
  let changed = false;

  for (const [key, value] of Object.entries(images)) {
    if (typeof value !== "string") {
      continue;
    }

    const storagePath = normalizeStoragePath(value);
    if (storagePath && storagePath !== value) {
      normalized[key] = storagePath;
      changed = true;
    }
  }

  return { changed, normalized };
}

function normalizeImageList(images: unknown[]): {
  changed: boolean;
  normalized: unknown[];
} {
  const normalized = images.slice();
  let changed = false;

  images.forEach((value, index) => {
    if (typeof value !== "string") {
      return;
    }

    const storagePath = normalizeStoragePath(value);
    if (storagePath && storagePath !== value) {
      normalized[index] = storagePath;
      changed = true;
    }
  });

  return { changed, normalized };
}

async function updateCollection(
  db: admin.firestore.Firestore,
  collectionName: string
): Promise<void> {
  const snapshot = await db.collection(collectionName).get();

  let batch = db.batch();
  let batchCount = 0;
  let updatedCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const updates: Record<string, unknown> = {};
    let changed = false;

    if (typeof data.imageUrl === "string") {
      const storagePath = normalizeStoragePath(data.imageUrl);
      if (storagePath && storagePath !== data.imageUrl) {
        updates.imageUrl = storagePath;
        changed = true;
      }
    }

    if (data.images && typeof data.images === "object" && !Array.isArray(data.images)) {
      const { changed: imagesChanged, normalized } = normalizeImageMap(
        data.images as Record<string, unknown>
      );
      if (imagesChanged) {
        updates.images = normalized;
        changed = true;
      }
    }

    if (Array.isArray(data.imageUrls)) {
      const { changed: listChanged, normalized } = normalizeImageList(
        data.imageUrls
      );
      if (listChanged) {
        updates.imageUrls = normalized;
        changed = true;
      }
    }

    if (!changed) {
      continue;
    }

    batch.update(doc.ref, updates);
    batchCount += 1;
    updatedCount += 1;

    if (batchCount >= 450) {
      await batch.commit();
      batch = db.batch();
      batchCount = 0;
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(
    `Updated ${updatedCount} documents in collection: ${collectionName}`
  );
}

export async function up(db: admin.firestore.Firestore) {
  console.log("Running migration 002: secure_storage_paths");

  const collections = ["styles", "haircuts", "beard_styles"];
  for (const collectionName of collections) {
    await updateCollection(db, collectionName);
  }
}

export async function down(_db: admin.firestore.Firestore) {
  console.log("No rollback for migration 002: secure_storage_paths");
}

export const migration = {
  id: "002_secure_storage_paths",
  description: "Normalize image URLs to storage paths",
  up,
  down,
};
