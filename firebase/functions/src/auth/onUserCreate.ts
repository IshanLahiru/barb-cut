import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

import { getCanonicalUserPayload } from "./userShape";

/**
 * Create user document when user is created via Firebase Auth.
 * Uses canonical user shape (includes favouritesCount: 0).
 */
export const createUserDocument = functions.auth.user().onCreate(async (user) => {
  console.log(`✅ New user created: ${user.uid}`);

  const db = admin.firestore();

  try {
    const payload = getCanonicalUserPayload(user);
    await db.collection("users").doc(user.uid).set(payload);

    console.log(`📝 User profile created for ${user.uid}`);
  } catch (error) {
    console.error(`❌ Error creating user document for ${user.uid}:`, error);
    throw error;
  }
});
