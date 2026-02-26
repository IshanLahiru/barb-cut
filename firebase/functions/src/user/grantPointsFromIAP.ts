import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Grant points to a user (e.g. after IAP via RevenueCat).
 * Production: call from RevenueCat webhook after verifying signature, or from
 * a callable that verifies the purchase with RevenueCat server API.
 *
 * Stub: only admins can grant points (for testing). Integrate RevenueCat
 * webhook or receipt verification before allowing client-triggered grants.
 */
export const grantPointsFromIAP = functions.https.onCall(
  async (data: { userId: string; amount: number; source?: string }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated."
      );
    }

    const { userId, amount, source = "iap" } = data ?? {};
    if (typeof userId !== "string" || userId === "") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "userId is required."
      );
    }
    const pointsToAdd = Math.floor(Number(amount));
    if (!Number.isFinite(pointsToAdd) || pointsToAdd <= 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "amount must be a positive number."
      );
    }

    const db = admin.firestore();
    const callerUid = context.auth.uid;

    // Stub: only allow if caller is admin or calling for self (self-grant for testing only)
    const callerDoc = await db.collection("users").doc(callerUid).get();
    const callerRole = callerDoc.data()?.role;
    const isAdmin = callerRole === "admin";
    const isSelf = callerUid === userId;
    if (!isAdmin && !isSelf) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admin can grant points to another user."
      );
    }

    const userRef = db.collection("users").doc(userId);
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      if (!snap.exists) {
        throw new functions.https.HttpsError("not-found", "User not found.");
      }
      const current = (snap.data()?.points ?? 0) as number;
      const newPoints = Math.max(0, current + pointsToAdd);
      tx.update(userRef, {
        points: newPoints,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return { success: true, granted: pointsToAdd };
  }
);
