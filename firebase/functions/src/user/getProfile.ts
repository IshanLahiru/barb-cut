import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Get user profile information
 */
export const getUserProfile = functions.https.onCall(
  async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const userId = context.auth.uid;
    const { userId: targetUserId } = data;

    // Users can only read their own profile, admins can read any
    const readUserId = targetUserId || userId;

    try {
      const userDoc = await db.collection("users").doc(readUserId).get();

      if (!userDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "User not found"
        );
      }

      const userData = userDoc.data();

      // Check permissions
      if (userId !== readUserId) {
        const currentUserDoc = await db.collection("users").doc(userId).get();
        if (currentUserDoc.data()?.role !== "admin") {
          throw new functions.https.HttpsError(
            "permission-denied",
            "You can only view your own profile"
          );
        }
      }

      return {
        success: true,
        data: userData,
      };
    } catch (error) {
      console.error("❌ Error getting profile:", error);
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      throw new functions.https.HttpsError(
        "internal",
        "Failed to get profile"
      );
    }
  }
);
