import * as admin from "firebase-admin";

/**
 * Migration XXX: [Brief description]
 * 
 * Details:
 * - What this migration does
 * - Any collections affected
 */
export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration XXX: [description]");

  try {
    // Example: Add a new field to all documents
    // const batch = db.batch();
    // const querySnapshot = await db.collection("users").get();
    //
    // querySnapshot.forEach((doc) => {
    //   batch.update(doc.ref, {
    //     newField: "value",
    //     updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    //   });
    // });
    //
    // await batch.commit();
    // console.log(`✓ Updated ${querySnapshot.size} documents`);

    console.log("✓ Migration XXX completed");
  } catch (error) {
    console.error("✗ Migration XXX failed:", error);
    throw error;
  }
}

export async function down(db: admin.firestore.Firestore) {
  console.log("⬇️  Rolling back migration XXX");

  try {
    // Reverse the changes made in up()
    console.log("✓ Migration XXX rolled back");
  } catch (error) {
    console.error("✗ Rollback failed:", error);
    throw error;
  }
}

export const migration = {
  id: "XXX_description",
  up,
  down,
};
