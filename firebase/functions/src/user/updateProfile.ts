import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Update user profile information
 */
export const updateUserProfile = functions.https.onCall(
  async (data, context) => {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to update profile"
      );
    }

    const userId = context.auth.uid;
    const { displayName, phone, address, photoURL, bio, role } = data;

    try {
      const updateData: any = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Only allow updating own profile (or admin updating others)
      if (displayName !== undefined) updateData.displayName = displayName;
      if (phone !== undefined) updateData.phone = phone;
      if (address !== undefined) updateData.address = address;
      if (photoURL !== undefined) updateData.photoURL = photoURL;
      if (bio !== undefined) updateData.bio = bio;
      
      // Only admins can change role
      if (role !== undefined) {
        const userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.data()?.role === "admin") {
          updateData.role = role;
        }
      }

      await db.collection("users").doc(userId).update(updateData);

      console.log(`✓ Profile updated for user ${userId}`);

      return {
        success: true,
        message: "Profile updated successfully",
      };
    } catch (error) {
      console.error("❌ Error updating profile:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to update profile"
      );
    }
  }
);
