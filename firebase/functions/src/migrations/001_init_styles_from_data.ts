import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import * as fs from "fs";
import * as path from "path";

/**
 * Migration 001: Initialize Styles Collection from app data
 * Loads haircut styles from apps/barbcut/assets/data/images/data.json
 * and imports them into Firestore with properly configured storage paths
 */

// Interface for the style data structure
interface StyleImage {
  front: string;
  left_side: string;
  right_side: string;
  back: string;
}

interface StyleData {
  id: string;
  name: string;
  price: string;
  duration: string;
  description: string;
  images: StyleImage;
  suitableFaceShapes: string[];
  maintenanceTips: string[];
}

// Convert app asset path to Cloud Storage path
function convertAssetPathToStoragePath(assetPath: string): string {
  // Transform: /apps/barbcut/assets/data/images/xxx.png
  // Into: gs://PROJECT_ID.appspot.com/apps/barbcut/assets/data/images/xxx.png
  // For now, we store the path as-is for local assets
  // In production, these will be uploaded to Cloud Storage
  return assetPath;
}

// Parse price string to number
function parsePrice(priceStr: string): number {
  const match = priceStr.match(/\d+/);
  return match ? parseInt(match[0], 10) : 0;
}

// Parse duration string to minutes
function parseDuration(durationStr: string): number {
  const match = durationStr.match(/\d+/);
  return match ? parseInt(match[0], 10) : 30;
}

export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration 001: init_styles_from_data");

  try {
    // Read data.json from the assets directory
    // Navigate to workspace root: firebase/functions -> firebase -> workspace root
    const dataFilePath = path.join(
      process.cwd(),
      "../../apps/barbcut/assets/data/images/data.json"
    );

    if (!fs.existsSync(dataFilePath)) {
      console.warn(`⚠️  Data file not found at: ${dataFilePath}`);
      console.log("Proceeding without data import...");
      // Continue with metadata setup even if data file not found
    }

    const batch = db.batch();

    // Create migration status document
    const migrationStatusRef = db.collection("_migrations").doc("migration_status");
    batch.set(
      migrationStatusRef,
      {
        version: 1,
        lastMigration: "001_init_styles_from_data",
        timestamp: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Try to load and import styles data
    if (fs.existsSync(dataFilePath)) {
      const rawData = fs.readFileSync(dataFilePath, "utf-8");
      const stylesData: StyleData[] = JSON.parse(rawData);

      console.log(`✓ Loaded ${stylesData.length} styles from data.json`);

      // Import each style into Firestore
      for (const style of stylesData) {
        const styleRef = db.collection("styles").doc(style.id);

        // Convert image paths for Cloud Storage
        const images: { [key: string]: string } = {};
        for (const [angleKey, assetPath] of Object.entries(style.images)) {
          images[angleKey] = convertAssetPathToStoragePath(assetPath);
        }

        batch.set(styleRef, {
          id: style.id,
          name: style.name,
          type: "haircut", // Classify as haircut by default
          description: style.description,
          price: parsePrice(style.price),
          priceDisplay: style.price,
          durationMinutes: parseDuration(style.duration),
          durationDisplay: style.duration,
          tags: [style.name.toLowerCase().replace(/\s+/g, "-")],
          images: images,
          suitableFaceShapes: style.suitableFaceShapes || [],
          maintenanceTips: style.maintenanceTips || [],
          isActive: true,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
          assetPath: style.images.front, // Original asset path for reference
        });

        console.log(`  ✓ Added style: ${style.name}`);
      }
    }

    await batch.commit();
    console.log("✓ Migration 001 completed successfully");
  } catch (error) {
    console.error("❌ Error in migration 001:", error);
    throw error;
  }
}

export async function down(db: admin.firestore.Firestore) {
  console.log("⬇️  Rolling back migration 001: init_styles_from_data");

  try {
    const batch = db.batch();

    // Delete all styles
    const snapshot = await db.collection("styles").get();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Reset migration status
    const statusRef = db.collection("_migrations").doc("migration_status");
    batch.set(
      statusRef,
      {
        version: 0,
        lastMigration: null,
        timestamp: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    await batch.commit();
    console.log("✓ Migration 001 rolled back successfully");
  } catch (error) {
    console.error("❌ Error rolling back migration 001:", error);
    throw error;
  }
}

export const migration = {
  id: "001_init_styles_from_data",
  description: "Initialize styles collection from apps/barbcut/assets/data/images/data.json",
  up,
  down,
};
