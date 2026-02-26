import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { deleteAllUserData } from "../lib/firestoreBatchDelete";

/**
 * Delete user profile and all associated data (admin or self only).
 */
export const deleteUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const userId = context.auth.uid;
  const { targetUserId } = data;

  if (!targetUserId || typeof targetUserId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "targetUserId is required"
    );
  }

  const db = admin.firestore();

  try {
    const userDoc = await db.collection("users").doc(userId).get();
    const isAdmin = userDoc.data()?.role === "admin";

    if (!isAdmin && userId !== targetUserId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "You can only delete your own profile"
      );
    }

    await deleteAllUserData(db, targetUserId);

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
});
