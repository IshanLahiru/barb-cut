import * as admin from "firebase-admin";

/**
 * Migration 002: Initialize Styles Collection
 * Sets up haircut and beard styles collection
 */
export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration 002: init_styles");

  // Create sample styles
  const stylesData = [
    {
      name: "Classic Fade",
      type: "haircut",
      price: 2500,
      durationMinutes: 30,
      description: "Clean and timeless fade haircut",
      tags: ["fade", "classic", "professional"],
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      name: "Full Beard",
      type: "beard",
      price: 1500,
      durationMinutes: 20,
      description: "Classic full beard trim and shape",
      tags: ["beard", "full", "classic"],
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
  ];

  const batch = db.batch();
  const stylesRef = db.collection("styles");

  for (const style of stylesData) {
    const docRef = stylesRef.doc();
    batch.set(docRef, style);
  }

  await batch.commit();
  console.log(`✓ Created ${stylesData.length} sample styles`);
}

export async function down(db: admin.firestore.Firestore) {
  console.log("⬇️  Rolling back migration 002: init_styles");

  // Delete all styles
  const snapshot = await db.collection("styles").get();
  const batch = db.batch();

  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log("✓ Migration 002 rolled back");
}

export const migration = {
  id: "002_init_styles",
  up,
  down,
};
