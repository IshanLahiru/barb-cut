import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

// =====================================================
// Module Imports
// =====================================================

// Auth Functions (account lifecycle)
export * from "./auth";

// User Functions (profile management)
export * from "./user";

// Health Functions (system monitoring)
export * from "./health";

// AI Generation Functions
export * from "./ai";

// =====================================================

