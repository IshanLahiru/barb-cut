# Firebase (BarbCut)

Firebase backend for the BarbCut tryout app: Firestore, Storage, Cloud Functions.

## Structure

- **firestore.rules** – Security rules (users as canonical profile store, userPhotos, history, aiJobs, etc.). No bookings/barbers/payments.
- **firestore.indexes.json** – Composite indexes for `history`, `aiJobs`.
- **storage.rules** – Storage security rules.
- **functions/** – Node 20 Cloud Functions (auth triggers, user, AI jobs, migrations, health).

## Security – do not commit

- **serviceAccountKey.json**, **\*-key.json** – Service account keys (use CI secrets or local-only).
- **.env**, **.env.\*** – Environment variables and API keys.
- **.firebaserc** – Project aliases (optional; can use `firebase use` locally).

Copy from examples when needed: `serviceAccountKey.json.example`, `.env.example`, `.firebaserc.example`.

## Deploy

From repo root or `firebase/`:

```bash
# Firestore rules + indexes only
firebase deploy --only firestore:rules,firestore:indexes

# Functions (build first)
cd firebase/functions && npm run build && cd ../..
firebase deploy --only functions

# All
firebase deploy
```

## Profile Cleanup Migration

Consolidate legacy profile collections into `users/{uid}` and remove migrated docs:

```bash
cd firebase/functions

# Local emulator
npm run migrate:status
npm run migrate:up

# Production (requires GOOGLE_APPLICATION_CREDENTIALS)
npm run migrate:prod:status
npm run migrate:prod:up
```

This runs migration `004_consolidate_profile_collections`, which:
- Migrates `userProfiles/{uid}` profile fields into `users/{uid}`
- Migrates legacy user-like docs from `profile/{docId}` into `users/{uid}`
- Deletes migrated legacy profile docs after successful merge
- Leaves non-user app-config docs in `profile` intact

## Emulators

From `firebase/`:

```bash
firebase emulators:start --only auth,firestore,functions,storage
```

## Image Optimizer

Local CLI tool (not deployed) that resizes PNG images into multiple size variants using `sharp`. Useful for optimizing images before uploading them to Firebase Storage.

Lives in `image-optimizer/`. See [`image-optimizer/README.md`](image-optimizer/README.md) for full usage.
