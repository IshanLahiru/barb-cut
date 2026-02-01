import * as admin from "firebase-admin";
import { migrateUp, migrateDown, getMigrationStatus } from "./migrations";

// Initialize Firebase Admin (requires GOOGLE_APPLICATION_CREDENTIALS)
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
  console.error(
    "❌ Error: Set GOOGLE_APPLICATION_CREDENTIALS environment variable"
  );
  console.error("   Example: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(serviceAccountPath)),
});

const db = admin.firestore();

async function main() {
  const command = process.argv[2];

  try {
    switch (command) {
      case "migrate:up":
        console.log("🚀 Running migrations...");
        const upResult = await migrateUp(db);
        console.log(
          `✓ Completed ${upResult.migrationsRun.length} migrations:`,
          upResult.migrationsRun
        );
        break;

      case "migrate:down":
        console.log("⬇️  Rolling back last migration...");
        const downResult = await migrateDown(db);
        console.log(`✓ Rolled back: ${downResult.rolledBack}`);
        break;

      case "migrate:status":
        console.log("📊 Migration Status:");
        const status = await getMigrationStatus(db);
        console.log(`   Current version: ${status.currentVersion}`);
        console.log(`   Total migrations: ${status.totalMigrations}`);
        console.log(`   Pending: ${status.pending.join(", ") || "None"}`);
        break;

      default:
        console.log(`
Usage: npm run cli <command>

Commands:
  migrate:up       - Run all pending migrations
  migrate:down     - Rollback last migration
  migrate:status   - Show migration status

Examples:
  npm run cli migrate:up
  npm run cli migrate:status
        `);
    }
  } catch (error) {
    console.error("❌ Error:", error);
    process.exit(1);
  } finally {
    await admin.app().delete();
  }
}

main();
