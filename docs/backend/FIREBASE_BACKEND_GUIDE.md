# Barbcut Firebase Backend - Complete Guide

## Overview

This is the complete Firebase backend for the Barbcut haircut visualization app. It includes:

- **Firestore Database** - Document-based NoSQL database
- **Cloud Functions** - Serverless backend functions
- **Firebase Authentication** - User account management
- **Database Migrations** - Version-controlled schema management
- **Local Emulator** - Full local development environment

## Related Documentation

- **[README_MIGRATIONS.md](README_MIGRATIONS.md)** - Firebase migrations guide with file management
- **[MIGRATION_FILES_QUICK_REFERENCE.md](MIGRATION_FILES_QUICK_REFERENCE.md)** - Migration upload and file reference
- **[MIGRATION_FILES_QUICK_REFERENCE.md](MIGRATION_FILES_QUICK_REFERENCE.md)** - Quick reference for migration files
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Overall clean architecture structure
- **[FIREBASE_DATA_MIGRATION.md](FIREBASE_DATA_MIGRATION.md)** - Data migration to JSON files

---

## Project Structure

```
firebase/
├── functions/
│   ├── src/
│   │   ├── auth/              # Authentication triggers
│   │   │   ├── onUserCreate.ts
│   │   │   ├── onUserDelete.ts
│   │   │   └── index.ts
│   │   ├── user/              # User profile functions
│   │   │   ├── updateProfile.ts
│   │   │   ├── getProfile.ts
│   │   │   ├── deleteProfile.ts
│   │   │   └── index.ts
│   │   ├── health/            # System monitoring
│   │   │   ├── healthCheck.ts
│   │   │   └── index.ts
│   │   ├── migrations/        # Database migrations
│   │   │   ├── 001_init_styles_from_data.ts
│   │   │   └── index.ts
│   │   ├── index.ts           # Main entry point
│   │   ├── migrations.ts      # Migration runner
│   │   └── cli.ts             # CLI tool for migrations
│   ├── lib/                   # Compiled JavaScript
│   ├── tsconfig.json
│   └── package.json
├── firestore.rules            # Security rules for Firestore
├── firestore.indexes.json     # Custom indexes
├── firebase.json              # Firebase configuration
├── package.json               # Project dependencies
└── GUIDE.md                   # This file
```

---

## Quick Start

### Prerequisites

- Node.js 20+ (Firebase CLI requires Java 21+)
- Firebase CLI: `npm install -g firebase-tools`
- Java 21+: `brew install openjdk@21` (macOS)

### 1. Install Dependencies

```bash
cd firebase
npm install
npm run build
```

### 2. Start Local Emulator

```bash
npm run serve
```

The emulator starts with:
- **Authentication**: http://127.0.0.1:9099 (port 9099)
- **Firestore**: http://127.0.0.1:8080 (port 8080)
- **Functions**: http://127.0.0.1:5001 (port 5001)
- **Emulator UI**: http://127.0.0.1:4000 (port 4400)

### 3. Run Database Migrations

```bash
npm run migrate:up
```

This loads 2 hairstyles from `apps/barbcut/assets/data/images/data.json` into Firestore.

---

## Cloud Functions

All functions automatically set emulator environment variables and connect to local emulators by default:
- `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080` - Firestore emulator
- `FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099` - Auth emulator

### Auth Functions (Automatic Triggers)

#### `createUserDocument`
**Trigger**: Firebase Auth user signup
**Action**: Creates user document in Firestore with default role "customer"

```typescript
// Automatic - fires when user signs up
// Creates document in "users" collection
```

#### `deleteUserDocument`
**Trigger**: Firebase Auth user deletion
**Action**: Deletes user document and all associated data

```typescript
// Automatic - fires when user account is deleted
// Cleans up: aiGenerations, preferences, ratings
```

---

### User Functions (HTTP Callable)

#### `updateUserProfile`
**Call**: `POST http://127.0.0.1:5001/barb-cut/us-central1/updateUserProfile`

**Payload**:
```json
{
  "displayName": "John Doe",
  "phone": "+1234567890",
  "address": "123 Main St",
  "photoURL": "https://...",
  "bio": "Barber enthusiast"
}
```

**Requirements**: Authenticated user

---

#### `getUserProfile`
**Call**: `POST http://127.0.0.1:5001/barb-cut/us-central1/getUserProfile`

**Payload**:
```json
{
  "userId": "user123"  // Optional - if omitted, returns own profile
}
```

**Requirements**: Authenticated user (admins can view any user)

---

#### `deleteUserProfile`
**Call**: `POST http://127.0.0.1:5001/barb-cut/us-central1/deleteUserProfile`

**Payload**:
```json
{
  "userId": "user123"  // Optional - if omitted, deletes own profile
}
```

**Requirements**: Authenticated user (can only delete own profile unless admin)

---

### Health Function

#### `healthCheck`
**Call**: `POST http://127.0.0.1:5001/barb-cut/us-central1/healthCheck`

**Response**:
```json
{
  "status": "ok",
  "timestamp": "2026-02-10T14:39:00.000Z",
  "authenticated": true,
  "userId": "user123"
}
```

**Use**: Monitor Firebase backend health

---

## Database Schema

### Collections

#### `users`
- `uid` (string) - Firebase Auth UID
- `email` (string)
- `displayName` (string)
- `phone` (string)
- `photoURL` (string)
- `bio` (string)
- `role` (string) - "customer" or "admin"
- `isActive` (boolean)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

#### `styles`
- `id` (string) - Unique identifier
- `name` (string) - Style name (e.g., "Textured Crew Cut")
- `type` (string) - "haircut" (for future expansion)
- `description` (string)
- `price` (number) - Price in dollars
- `priceDisplay` (string) - Display format (e.g., "$20")
- `durationMinutes` (number) - Service duration
- `durationDisplay` (string) - Display format (e.g., "25 min")
- `tags` (array) - Search tags
- `images` (object)
  - `front` (string) - Asset path
  - `left_side` (string)
  - `right_side` (string)
  - `back` (string)
- `suitableFaceShapes` (array) - Face shapes this style works for
- `maintenanceTips` (array) - Care instructions
- `isActive` (boolean)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)
- `assetPath` (string) - Original app asset path

#### `_migrations`
- `migration_status` - Tracks applied migrations
  - `version` (number)
  - `lastMigration` (string)
  - `timestamp` (timestamp)

---

## Migrations

Migrations are version-controlled database updates applied sequentially.

### Migration Files

**Location**: `functions/src/migrations/`

**Structure**:
```typescript
export const migration = {
  id: "001_init_styles_from_data",
  description: "Initialize styles collection from app data",
  up(db: Firestore): Promise<void>,
  down(db: Firestore): Promise<void>
}
```

### Migration Commands

```bash
# Check migration status
npm run migrate:status

# Apply pending migrations
npm run migrate:up

# Rollback last migration
npm run migrate:down
```

### Current Migrations

- **001_init_styles_from_data** - Loads hairstyles from Flutter app assets

---

## Testing Functions Locally

### Using cURL

```bash
# Health check
curl -X POST http://127.0.0.1:5001/barb-cut/us-central1/healthCheck \
  -H "Content-Type: application/json" \
  -d '{}'

# Update profile (requires auth token)
curl -X POST http://127.0.0.1:5001/barb-cut/us-central1/updateUserProfile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "displayName": "John Doe",
    "phone": "+1234567890"
  }'
```

### Using Postman

1. Open http://127.0.0.1:4000 (Emulator UI)
2. Copy function endpoint
3. Create POST request with JSON body
4. Add `Authorization: Bearer <token>` header if authenticated

### Using Firebase SDK (Flutter)

```dart
// Configure Flutter to use emulator
FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
FirebaseFunctions.instance.useFunctionsEmulator('127.0.0.1', 5001);
FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);

// Call function
final result = await FirebaseFunctions.instance
  .httpsCallable('updateUserProfile')
  .call({
    'displayName': 'John Doe',
    'phone': '+1234567890',
  });
```

---

## Development Workflow

### 1. Make Changes to Functions

Edit TypeScript files in `functions/src/`:

```bash
# Watch for changes and recompile
npm run watch

# Or manually rebuild
npm run build
```

The emulator automatically reloads compiled functions.

### 2. Create Database Migrations

Create new file in `functions/src/migrations/`:

```typescript
// 002_add_barbers_collection.ts
import * as admin from "firebase-admin";

export const migration = {
  id: "002_add_barbers_collection",
  description: "Add barbers collection",

  async up(db: admin.firestore.Firestore) {
    const batch = db.batch();
    
    // Add your migration logic
    
    await batch.commit();
  },

  async down(db: admin.firestore.Firestore) {
    // Rollback logic
  }
};
```

Then add to `functions/src/migrations/index.ts`:

```typescript
import { migration as migration002 } from "./002_add_barbers_collection";

export const migrations: Migration[] = [
  migration001,
  migration002  // Add here
];
```

### 3. Run Migrations

```bash
npm run build
npm run migrate:up
```

---

## Emulator UI

Access the Firebase Emulator Suite at **http://127.0.0.1:4000**

### Features

- **Firestore** (Port 8080) - View/edit documents, run queries
- **Functions** (Port 5001) - View logs, copy function URLs
- **Authentication** (Port 9099) - Create/manage test users, view auth logs
- **Emulator Hub** (Port 4400) - Monitor all services, view connection details

---

## Deployment

### Deploy to Production

```bash
# Deploy everything
firebase deploy

# Deploy only functions
npm run build && firebase deploy --only functions

# Deploy only security rules
firebase deploy --only firestore:rules

# Deploy only indexes
firebase deploy --only firestore:indexes
```

**Note**: Requires Firebase credentials configured with `firebase login`

---

## Troubleshooting

### Functions not loading

**Error**: `Could not detect runtime for functions`

**Solution**:
```bash
# Create functions/package.json
npm run build
npm run serve
```

### Can't connect to emulator

**Error**: `FIRESTORE_EMULATOR_HOST` not set

**Solution**: All npm scripts already set this automatically. If running Node directly:
```bash
export FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
node functions/lib/cli.js up
```

### Port already in use

**Error**: Port 5001, 8080, or 4000 already in use

**Solution**:
```bash
# Kill process using the port (macOS/Linux)
lsof -i :5001
kill -9 <PID>

# Or use different port
firebase emulators:start --only firestore,auth,functions --import=./emulator-data
```

### Migration fails

**Error**: `Data file not found`

**Solution**: Ensure `apps/barbcut/assets/data/images/data.json` exists, or modify migration to skip data import.

---

## Environment Variables

### Development (Local Emulator)

```bash
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
```

(Automatically set by npm scripts)

### Production

```bash
GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
```

---

## Security Rules

**File**: `firestore.rules`

Current rules:
- Users can read/write their own documents
- Admins can read/write all documents
- Migrations tracked in `_migrations` collection (write-protected)

Modify and deploy:
```bash
npm run build
firebase deploy --only firestore:rules
```

---

## Performance Indexes

Custom indexes are defined in `firestore.indexes.json` for optimal query performance.

Deploy indexes:
```bash
firebase deploy --only firestore:indexes
```

---

## Support

For issues or questions:

1. Check the Firebase Console: https://console.firebase.google.com
2. View Emulator logs: `cat firebase-debug.log`
3. Check function logs: `npm run logs`
4. Review Firestore rules: `firestore.rules`

---

**Last Updated**: February 10, 2026  
**Firebase SDK**: Admin v12.1.0, Functions v5.0.1  
**Node**: 18+ (20+ recommended)
