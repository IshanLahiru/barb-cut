import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Create user document when user is created via Firebase Auth
 */
export const createUserDocument = functions.auth.user().onCreate(async (user) => {
  console.log(`✅ New user created: ${user.uid}`);

  try {
    await db.collection("users").doc(user.uid).set({
      uid: user.uid,
      email: user.email || "",
      displayName: user.displayName || "",
      phone: user.phoneNumber || "",
      photoURL: user.photoURL || "",
      role: "customer", // Default role
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    });

    console.log(`📝 User profile created for ${user.uid}`);
  } catch (error) {
    console.error(`❌ Error creating user document for ${user.uid}:`, error);
    throw error;
  }
});
