import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Delete user document and related data when user is deleted from Firebase Auth
 */
export const deleteUserDocument = functions.auth.user().onDelete(async (user) => {
  console.log(`🗑️  User deleted: ${user.uid}`);

  try {
    const batch = db.batch();

    // Delete user document
    const userRef = db.collection("users").doc(user.uid);
    batch.delete(userRef);

    // Delete user's bookings
    const bookingsSnapshot = await db
      .collection("bookings")
      .where("userId", "==", user.uid)
      .get();

    bookingsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete user's AI generations
    const aiGenSnapshot = await db
      .collection("users")
      .doc(user.uid)
      .collection("aiGenerations")
      .get();

    aiGenSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete user's preferences
    const prefsSnapshot = await db
      .collection("users")
      .doc(user.uid)
      .collection("preferences")
      .get();

    prefsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`✓ User data deleted for ${user.uid}`);
  } catch (error) {
    console.error(`❌ Error deleting user document for ${user.uid}:`, error);
    // Don't rethrow - allow user deletion to proceed
  }
});
