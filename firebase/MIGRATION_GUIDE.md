# Firebase Data Migration Guide

This guide explains how to migrate your local JSON data to Firebase Firestore.

## Prerequisites

1. Firebase project set up
2. Firebase Admin SDK credentials
3. Node.js and npm installed
4. Firebase CLI installed (`npm install -g firebase-tools`)

## Setup

1. **Initialize Firebase (if not already done)**:
   ```bash
   cd firebase/functions
   npm install
   ```

2. **Set up service account** (for local development):
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file as `serviceAccountKey.json` in `firebase/functions/`
   - **DO NOT commit this file to git** (it's in .gitignore)

3. **Update migrate-data.ts** if needed to point to your service account:
   ```typescript
   admin.initializeApp({
     credential: admin.credential.cert(require('./serviceAccountKey.json'))
   });
   ```

## Running the Migration

### Option 1: Fresh Migration (Clear and Import)

This will delete all existing data and import fresh data from JSON files:

```bash
cd firebase/functions
npx ts-node migrate-data.ts --clear
```

### Option 2: Additive Migration

This will add data without clearing existing documents:

```bash
cd firebase/functions
npx ts-node migrate-data.ts
```

## What Gets Migrated

The migration script will upload the following data to Firestore:

1. **Haircuts** → `haircuts` collection
   - From: `apps/barbcut/assets/data/haircuts.json`
   - Document ID: Uses the `id` field from JSON

2. **Beard Styles** → `beard_styles` collection
   - From: `apps/barbcut/assets/data/beard_styles.json`
   - Document ID: Uses the `id` field from JSON

3. **Products** → `products` collection
   - From: `apps/barbcut/assets/data/products.json`
   - Document ID: Uses the `id` field or generates from name

Each document will have additional fields added:
- `createdAt`: Server timestamp
- `updatedAt`: Server timestamp

## Firestore Security Rules

After migration, make sure to apply the security rules:

```bash
cd firebase
firebase deploy --only firestore:rules
```

The rules are defined in `firebase/firestore.rules` and ensure:
- Public read access for haircuts, beard_styles, and products
- User-specific read/write for user profiles and history
- Admin-only write for catalog data

## Verification

After migration, you can verify the data in:
1. Firebase Console → Firestore Database
2. Or use the Firebase CLI:
   ```bash
   firebase firestore:get haircuts
   ```

## Troubleshooting

### Permission Denied
- Ensure your service account has the necessary permissions
- Check that you're authenticated with Firebase CLI: `firebase login`

### Path Not Found
- Verify that the JSON file paths in `migrate-data.ts` are correct
- Ensure you're running the script from the `firebase/functions` directory

### Batch Size Limit
- The script handles Firestore's 500 operations per batch limit automatically
- Large datasets will be committed in multiple batches

## Post-Migration Steps

1. **Update Security Rules**: Deploy the security rules to production
2. **Test the App**: Run the Flutter app to ensure data loads correctly
3. **Remove Local Data Loading**: Once confirmed working, you can remove the local JSON loading code
4. **Monitor Usage**: Check Firebase Console for read/write metrics

## User Data

Note: User-specific data (profiles, history) will be created when users:
- Sign up/login (creates profile document)
- Use the app features (creates history documents)

The migration script only handles catalog data (styles and products) that is common to all users.
