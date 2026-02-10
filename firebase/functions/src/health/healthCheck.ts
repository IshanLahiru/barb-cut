import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Health check endpoint for monitoring Firebase backend status
 */
export const healthCheck = functions.https.onCall(async (data, context) => {
  const db = admin.firestore();

  try {
    // Check Firestore connectivity
    const testDoc = await db.collection("_health").doc("status").get();

    // Check if we can read from key collections
    const usersCount = await db.collection("users").limit(1).get();
    const stylesCount = await db.collection("styles").limit(1).get();

    console.log("✓ Health check passed");

    return {
      success: true,
      status: "healthy",
      timestamp: new Date().toISOString(),
      checks: {
        firestore: "ok",
        users: usersCount.size >= 0 ? "reachable" : "empty",
        styles: stylesCount.size >= 0 ? "reachable" : "empty",
      },
    };
  } catch (error) {
    console.error("❌ Health check failed:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Health check failed"
    );
  }
});
