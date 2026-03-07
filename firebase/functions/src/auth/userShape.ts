import { FieldValue } from "firebase-admin/firestore";

/**
 * Minimal auth user shape (from Firebase Auth UserRecord in onCreate)
 */
export interface AuthUserLike {
  uid: string;
  email?: string | null;
  displayName?: string | null;
  phoneNumber?: string | null;
  photoURL?: string | null;
}

/**
 * Canonical fields for users/{uid} documents.
 * Single source of truth for both onCreate and migration 003.
 */
/** Initial credits for new users (free tier). */
export const DEFAULT_FREE_CREDITS = 3;

export const CANONICAL_USER_FIELDS = [
  "uid",
  "email",
  "displayName",
  "phone",
  "photoURL",
  "role",
  "createdAt",
  "updatedAt",
  "isActive",
  "favouritesCount",
  "points",
] as const;

export type CanonicalUserPayload = {
  uid: string;
  email: string;
  displayName: string;
  phone: string;
  photoURL: string;
  role: string;
  createdAt: unknown;
  updatedAt: unknown;
  isActive: boolean;
  favouritesCount: number;
  points: number;
};

/**
 * Build the canonical user document payload for a new user (e.g. from Auth onCreate).
 * Used by createUserDocument and by migration 003 for merge defaults.
 */
export function getCanonicalUserPayload(user: AuthUserLike): Record<string, unknown> {
  return {
    uid: user.uid,
    email: user.email || "",
    displayName: user.displayName || "",
    phone: user.phoneNumber || "",
    photoURL: user.photoURL || "",
    role: "customer",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    isActive: true,
    favouritesCount: 0,
    points: DEFAULT_FREE_CREDITS,
  };
}
