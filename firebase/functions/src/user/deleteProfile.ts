import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Delete user profile and all associated data (admin only)
 */
export const deleteUserProfile = functions.https.onCall(
  async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const userId = context.auth.uid;
    const { targetUserId } = data;

    const db = admin.firestore();

    try {
      // Check if user is admin or deleting own account
      const userDoc = await db.collection("users").doc(userId).get();
      const isAdmin = userDoc.data()?.role === "admin";

      if (!isAdmin && userId !== targetUserId) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You can only delete your own profile"
        );
      }

      const batch = db.batch();

      // Delete user document
      const userRef = db.collection("users").doc(targetUserId);
      batch.delete(userRef);

      // Delete user's bookings
      const bookingsSnapshot = await db
        .collection("bookings")
        .where("userId", "==", targetUserId)
        .get();

      bookingsSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      // Delete user's subcollections
      const aiGenSnapshot = await db
        .collection("users")
        .doc(targetUserId)
        .collection("aiGenerations")
        .get();

      aiGenSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      const prefsSnapshot = await db
        .collection("users")
        .doc(targetUserId)
        .collection("preferences")
        .get();

      prefsSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      console.log(`✓ User profile and data deleted for ${targetUserId}`);

      return {
        success: true,
        message: "User profile deleted successfully",
      };
    } catch (error) {
      console.error("❌ Error deleting profile:", error);
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      throw new functions.https.HttpsError(
        "internal",
        "Failed to delete profile"
      );
    }
  }
);
