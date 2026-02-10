import * as admin from "firebase-admin";
import { migrations, Migration } from "./migrations/index";

export interface MigrationStatus {
  version: number;
  lastMigration: string | null;
  timestamp: any;
  migrationsRun: string[];
}

const MIGRATION_STATUS_DOC = "_migrations/migration_status";

/**
 * Get current migration status from Firestore
 */
export async function getMigrationStatus(
  db: admin.firestore.Firestore
): Promise<MigrationStatus> {
  const doc = await db.doc(MIGRATION_STATUS_DOC).get();

  if (!doc.exists) {
    return {
      version: 0,
      lastMigration: null,
      timestamp: new Date(),
      migrationsRun: [],
    };
  }

  return doc.data() as MigrationStatus;
}

/**
 * Get the next migration to run
 */
export function getNextMigration(currentVersion: number): Migration | null {
  if (currentVersion >= migrations.length) {
    return null;
  }

  return migrations[currentVersion];
}

/**
 * Run all pending migrations (forward)
 */
export async function migrateUp(
  db: admin.firestore.Firestore
): Promise<string[]> {
  const status = await getMigrationStatus(db);
  const migrationsRan: string[] = [];

  console.log(`\n📊 Current version: ${status.version}`);
  console.log(`📊 Total migrations available: ${migrations.length}`);

  const pendingMigrations = migrations.slice(status.version);

  if (pendingMigrations.length === 0) {
    console.log("✅ Database is up to date!");
    return [];
  }

  console.log(`\n🚀 Running ${pendingMigrations.length} pending migration(s)...\n`);

  for (const migration of pendingMigrations) {
    try {
      console.log(`Running: ${migration.id}`);
      if (migration.description) {
        console.log(`  └─ ${migration.description}`);
      }

      await migration.up(db);

      migrationsRan.push(migration.id);
      console.log(`✅ Completed: ${migration.id}\n`);
    } catch (error) {
      console.error(`❌ Failed to run migration: ${migration.id}`);
      console.error(`Error: ${error}`);
      throw error;
    }
  }

  return migrationsRan;
}

/**
 * Rollback the last migration (backward)
 */
export async function migrateDown(
  db: admin.firestore.Firestore
): Promise<string | null> {
  const status = await getMigrationStatus(db);

  if (status.version === 0) {
    console.log("❌ No migrations to rollback");
    return null;
  }

  const migrationToRollback = migrations[status.version - 1];

  try {
    console.log(`⏮️  Rolling back: ${migrationToRollback.id}`);
    if (migrationToRollback.description) {
      console.log(`  └─ ${migrationToRollback.description}`);
    }

    await migrationToRollback.down(db);

    console.log(`✅ Rolled back: ${migrationToRollback.id}`);

    return migrationToRollback.id;
  } catch (error) {
    console.error(`❌ Failed to rollback migration: ${migrationToRollback.id}`);
    console.error(`Error: ${error}`);
    throw error;
  }
}

/**
 * Get detailed migration status
 */
export async function getDetailedStatus(
  db: admin.firestore.Firestore
): Promise<void> {
  const status = await getMigrationStatus(db);

  console.log("\n" + "=".repeat(50));
  console.log("📋 Migration Status");
  console.log("=".repeat(50));
  console.log(`\nCurrent Version: ${status.version}/${migrations.length}`);
  console.log(`Last Migration: ${status.lastMigration || "None"}`);
  console.log(
    `Last Updated: ${status.timestamp?.toDate?.() || status.timestamp}`
  );

  console.log("\n📂 Available Migrations:");
  migrations.forEach((m, idx) => {
    const isMigrated = idx < status.version;
    const icon = isMigrated ? "✅" : "⬜";
    console.log(`  ${icon} ${m.id}`);
    if (m.description) {
      console.log(`     └─ ${m.description}`);
    }
  });

  console.log("\n" + "=".repeat(50) + "\n");
}
