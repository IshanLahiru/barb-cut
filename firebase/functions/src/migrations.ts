import * as admin from "firebase-admin";
import { MIGRATIONS_REGISTRY } from "../../migrations/index";

export interface Migration {
  id: string;
  up: (db: admin.firestore.Firestore) => Promise<void>;
  down: (db: admin.firestore.Firestore) => Promise<void>;
}

const MIGRATIONS: Migration[] = [
  ...MIGRATIONS_REGISTRY as Migration[],
];

/**
 * Get the current migration version from Firestore
 */
export async function getCurrentVersion(
  db: admin.firestore.Firestore
): Promise<number> {
  try {
    const doc = await db
      .collection("_migrations")
      .doc("migration_status")
      .get();
    return doc.exists ? (doc.data()?.version || 0) : 0;
  } catch (error) {
    console.log("First migration run, starting from version 0");
    return 0;
  }
}

/**
 * Run pending migrations up
 */
export async function migrateUp(
  db: admin.firestore.Firestore
): Promise<{ success: boolean; migrationsRun: string[] }> {
  const currentVersion = await getCurrentVersion(db);
  const pendingMigrations = MIGRATIONS.filter(
    (m) => m && parseInt(m.id.split("_")[0]) > currentVersion
  );

  if (pendingMigrations.length === 0) {
    console.log("✓ No pending migrations");
    return { success: true, migrationsRun: [] };
  }

  const migrationsRun: string[] = [];

  for (const migration of pendingMigrations) {
    try {
      await migration.up(db);
      const versionNum = parseInt(migration.id.split("_")[0]);
      await db.collection("_migrations").doc("migration_status").set({
        version: versionNum,
        lastMigration: migration.id,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
      migrationsRun.push(migration.id);
      console.log(`✓ Migration ${migration.id} completed`);
    } catch (error) {
      console.error(`✗ Migration ${migration.id} failed:`, error);
      throw error;
    }
  }

  return { success: true, migrationsRun };
}

/**
 * Rollback last migration
 */
export async function migrateDown(
  db: admin.firestore.Firestore
): Promise<{ success: boolean; rolledBack?: string }> {
  const currentVersion = await getCurrentVersion(db);

  if (currentVersion === 0) {
    console.log("✓ Already at version 0");
    return { success: true };
  }

  const migrationToRollback = MIGRATIONS.find(
    (m) => m && parseInt(m.id.split("_")[0]) === currentVersion
  );

  if (!migrationToRollback) {
    throw new Error(`Migration ${currentVersion} not found`);
  }

  try {
    await migrationToRollback.down(db);
    await db.collection("_migrations").doc("migration_status").set({
      version: currentVersion - 1,
      lastMigration: `${currentVersion - 1}`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`✓ Rolled back migration ${migrationToRollback.id}`);
    return { success: true, rolledBack: migrationToRollback.id };
  } catch (error) {
    console.error(`✗ Rollback failed:`, error);
    throw error;
  }
}

/**
 * Get migration status
 */
export async function getMigrationStatus(
  db: admin.firestore.Firestore
): Promise<{ currentVersion: number; totalMigrations: number; pending: string[] }> {
  const currentVersion = await getCurrentVersion(db);
  const pending = MIGRATIONS.filter((m) => m && parseInt(m.id.split("_")[0]) > currentVersion).map(
    (m) => m.id
  );

  return {
    currentVersion,
    totalMigrations: MIGRATIONS.length,
    pending,
  };
}
