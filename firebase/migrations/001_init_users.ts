import * as admin from "firebase-admin";

/**
 * Migration 001: Initialize Users Collection
 * Creates the users collection structure with proper indexes and metadata
 */
export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration 001: init_users");

  // Create a metadata document to track schema version
  await db.collection("_migrations").doc("schema_version").set({
    version: 1,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    description: "Initial users collection setup",
  });

  // Create sample user with auto-generated ID
  const userRef = await db.collection("users").add({
    displayName: "Sample User",
    email: "sample@example.com",
    phone: "",
    role: "customer",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
    isActive: true,
  });

  console.log(`✓ Sample user created with ID: ${userRef.id}`);
  console.log("✓ Users collection initialized");
}

export async function down(db: admin.firestore.Firestore) {
  console.log("⬇️  Rolling back migration 001: init_users");

  // Remove migration metadata
  await db.collection("_migrations").doc("schema_version").delete();

  console.log("✓ Migration 001 rolled back");
}

export const migration = {
  id: "001_init_users",
  up,
  down,
};
