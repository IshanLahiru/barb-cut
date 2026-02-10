import * as admin from "firebase-admin";
import * as path from "path";
import {
  getMigrationStatus,
  migrateUp,
  migrateDown,
  getDetailedStatus,
} from "./migrations";

// Initialize Firebase Admin
const isEmulator = process.env.FIRESTORE_EMULATOR_HOST;
const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (isEmulator) {
  // Using local emulator - no credentials needed
  console.log("🔥 Using Firebase Emulator...");
  admin.initializeApp({
    projectId: "barb-cut",
  });
} else {
  // Using production Firebase - credentials required
  if (!credentialsPath) {
    console.error(
      "❌ Error: GOOGLE_APPLICATION_CREDENTIALS environment variable not set"
    );
    console.error(
      "   Set it with: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json"
    );
    console.error(
      "   OR set up emulator with: export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080"
    );
    process.exit(1);
  }

  try {
    admin.initializeApp({
      credential: admin.credential.cert(require(credentialsPath)),
    });
  } catch (error) {
    console.error("❌ Error: Could not load Firebase credentials");
    console.error(`   Path: ${credentialsPath}`);
    console.error(`   Error: ${error}`);
    process.exit(1);
  }
}

const db = admin.firestore();

async function main() {
  const command = process.argv[2];

  try {
    switch (command) {
      case "up":
        console.log("⬆️  Running forward migrations...");
        await migrateUp(db);
        await getDetailedStatus(db);
        break;

      case "down":
        console.log("⬇️  Rolling back last migration...");
        await migrateDown(db);
        await getDetailedStatus(db);
        break;

      case "status":
        console.log("📊 Checking migration status...");
        await getDetailedStatus(db);
        break;

      default:
        console.log("\nUsage: node cli.js <command>");
        console.log("\nCommands:");
        console.log("  up      - Run all pending migrations");
        console.log("  down    - Rollback the last migration");
        console.log("  status  - Show current migration status");
        console.log("\nExample:");
        console.log("  npm run migrate:up");
        console.log("  npm run migrate:down");
        console.log("  npm run migrate:status");
        break;
    }
  } catch (error) {
    console.error(`\n❌ Error: ${error}`);
    process.exit(1);
  } finally {
    await admin.app().delete();
    process.exit(0);
  }
}

main();
