import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import * as fs from "fs";
import * as path from "path";

/**
 * Migration 001: Initialize Styles Collection from app data
 * Loads haircut styles from apps/barbcut/assets/data/images/data.json
 * Uploads images to Firebase Storage and stores storage paths in Firestore
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

/**
 * Upload an image file to Firebase Storage (with idempotency)
 * @param localPath - Local file path to the image
 * @param storagePath - Destination path in Firebase Storage (e.g., "styles/style-id/front.png")
 * @returns Storage path
 */
async function uploadImageToStorage(
  localPath: string,
  storagePath: string
): Promise<string> {
  const bucket = admin.storage().bucket();
  const file = bucket.file(storagePath);
  
  // Check if file already exists (idempotency)
  const [exists] = await file.exists();
  
  if (exists) {
    console.log(`    ⏭️  Skipped (already exists): ${storagePath}`);
    return storagePath;
  }
  
  // Upload file to Storage
  await bucket.upload(localPath, {
    destination: storagePath,
    metadata: {
      contentType: "image/png",
      cacheControl: "private, max-age=31536000", // Cache for 1 year
    },
  });

  return storagePath;
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
    // Auto-detect data path (development vs production)
    // Production: firebase/functions/build/data/images (bundled with deployment)
    // Development: workspace root/apps/barbcut/assets/data/images
    const productionDataPath = path.join(__dirname, "../data/images");
    const developmentDataPath = path.join(
      process.cwd(),
      "../../apps/barbcut/assets/data/images"
    );
    
    // Try production path first, fallback to development
    const imagesBaseDir = fs.existsSync(productionDataPath) 
      ? productionDataPath 
      : developmentDataPath;
    
    const dataFilePath = path.join(imagesBaseDir, "data.json");
    
    console.log(`📂 Looking for assets in: ${imagesBaseDir}`);

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
        console.log(`  Processing style: ${style.name}`);
        
        // Check if style already exists (idempotency)
        const styleRef = db.collection("styles").doc(style.id);
        const existingStyle = await styleRef.get();
        
        if (existingStyle.exists) {
          console.log(`  ⏭️  Style already exists, skipping: ${style.name}`);
          continue;
        }

        // Upload images to Firebase Storage and store storage paths
        const images: { [key: string]: string } = {};
        
        for (const [angleKey, assetPath] of Object.entries(style.images)) {
          // Extract filename from asset path
          const filename = path.basename(assetPath);
          const localImagePath = path.join(imagesBaseDir, filename);

          if (fs.existsSync(localImagePath)) {
            // Upload to Storage: styles/{style-id}/{angle}.png
            const storagePath = `styles/${style.id}/${angleKey}.png`;
            const storedPath = await uploadImageToStorage(localImagePath, storagePath);
            images[angleKey] = storedPath;
            console.log(`    ✓ Uploaded ${angleKey}: ${filename}`);
          } else {
            console.warn(`    ⚠️  Image not found: ${localImagePath}`);
            images[angleKey] = assetPath; // Fallback to original path
          }
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
    const bucket = admin.storage().bucket();
    const batch = db.batch();

    // Get all styles to delete their images from Storage
    const snapshot = await db.collection("styles").get();
    
    for (const doc of snapshot.docs) {
      // Delete images from Storage
      const styleId = doc.id;
      const storagePrefix = `styles/${styleId}/`;
      
      try {
        const [files] = await bucket.getFiles({ prefix: storagePrefix });
        for (const file of files) {
          await file.delete();
          console.log(`  ✓ Deleted image: ${file.name}`);
        }
      } catch (error) {
        console.warn(`  ⚠️  Could not delete images for style ${styleId}:`, error);
      }

      // Delete Firestore document
      batch.delete(doc.ref);
    }

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
  description: "Initialize styles collection and upload images to Firebase Storage",
  up,
  down,
};
