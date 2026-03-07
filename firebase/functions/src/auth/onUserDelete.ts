import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { deleteAllUserData } from "../lib/firestoreBatchDelete";

/**
 * Delete user document and related data when user is deleted from Firebase Auth.
 */
export const deleteUserDocument = functions.auth.user().onDelete(async (user) => {
  console.log(`🗑️  User deleted: ${user.uid}`);

  const db = admin.firestore();

  try {
    await deleteAllUserData(db, user.uid);
    console.log(`✓ User data deleted for ${user.uid}`);
  } catch (error) {
    console.error(`❌ Error deleting user document for ${user.uid}:`, error);
    // Don't rethrow - allow user deletion to proceed
  }
});
