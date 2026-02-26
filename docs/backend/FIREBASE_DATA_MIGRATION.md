# Firebase Data Migration Guide

## Overview
Your app has been updated to load data from Firebase Firestore instead of local JSON files. The app now fetches:
- **Haircuts** from the `haircuts` collection
- **Beard Styles** from the `beard_styles` collection  
- **Products** from the `products` collection
- **Profile** from the `profile` collection (document: `data`)
- **History** from the `history` collection

## Key Changes Made

### 1. Dependencies Added
- `cloud_firestore: ^6.1.2` added to [pubspec.yaml](../apps/barbcut/pubspec.yaml)

### 2. New Firebase Data Service
Created [firebase_data_service.dart](../apps/barbcut/lib/services/firebase_data_service.dart) with:
- `fetchHaircuts()` - Fetches haircuts from Firestore
- `fetchBeardStyles()` - Fetches beard styles from Firestore
- `fetchProducts()` - Fetches products from Firestore
- `fetchProfile()` - Fetches profile data from Firestore
- `fetchHistory()` - Fetches history from Firestore
- `fetchAllData()` - Fetches all collections at once
- Built-in caching to minimize Firebase reads
- `clearCache()` and `isDataCached` utilities

### 3. Updated AppData Class
Updated [app_data.dart](../apps/barbcut/lib/core/constants/app_data.dart) to:
- Load data from Firebase by default
- Automatically fall back to JSON assets if Firebase is unavailable
- Added `refreshFromFirebase()` method to force refresh data

## How to Upload Data to Firebase

### Step 1: Set Up Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save the file as `serviceAccountKey.json` in the `firebase/` directory

### Step 2: Prepare Your Data
Make sure your JSON files are in place:
```
apps/barbcut/assets/data/
├── haircuts.json
├── beard_styles.json
├── products.json
├── profile.json
└── history.json
```

### Step 3: Run the Upload Script
```bash
cd firebase
npm install
node upload-data.js
```

This will:
- Upload all JSON data to Firestore collections
- Create the appropriate documents with IDs from your JSON files
- Show progress and confirm successful uploads

### Step 4: Verify Data in Firebase
1. Go to Firebase Console → Firestore Database
2. Check that these collections exist:
   - `haircuts`
   - `beard_styles`
   - `products`
   - `profile`  
   - `history`

## Firestore Data Structure

### Collections (Array Data)
For `haircuts`, `beard_styles`, `products`, and `history`:
- Each item in the JSON array becomes a document
- Document ID is taken from the `id` field in the JSON
- All other fields are stored as document data

Example:
```json
// haircuts.json
[
  {
    "id": "classic-fade",
    "name": "Classic Fade",
    "price": "$25",
    ...
  }
]
```
Becomes:
```
haircuts/
  └── classic-fade/
      ├── name: "Classic Fade"
      ├── price: "$25"
      └── ...
```

### Profile Collection (Single Document)
The `profile.json` data is stored as a single document:
```
profile/
  └── data/
      ├── name: "..."
      ├── email: "..."
      └── ...
```

## Using the System

### In Your App
The data loading is automatic in [main.dart](../apps/barbcut/lib/main.dart):
```dart
await AppData.loadAppData();
```

This will:
1. Try to load data from Firebase
2. If Firebase fails, fall back to JSON assets
3. Cache the data for subsequent use

### Manual Refresh
To refresh data from Firebase:
```dart
await AppData.refreshFromFirebase();
```

### Force JSON Fallback
To skip Firebase and only use JSON:
```dart
await AppData.loadAppData(useJsonFallback: true);
```

## Fallback Behavior

The system has automatic fallback:
1. **First attempt**: Load from Firebase
2. **If Firebase fails**: Load from JSON assets
3. **If both fail**: Error is thrown

This ensures your app works even when:
- Firebase is unavailable
- Network connectivity is poor
- Firebase quota is exceeded
- Data hasn't been uploaded yet

## Benefits

### Before (JSON Assets)
- ❌ Static data bundled with app
- ❌ Requires app update to change content
- ❌ Limited to data included in APK/IPA

### After (Firebase)
- ✅ Dynamic data from cloud
- ✅ Update content without app updates
- ✅ Real-time changes reflected in app
- ✅ Centralized data management
- ✅ JSON fallback for reliability

## Caching Strategy

The Firebase service caches data automatically:
- First request fetches from Firestore
- Subsequent requests use cached data
- Call `refreshFromFirebase()` to force refresh
- Call `FirebaseDataService.clearCache()` to clear cache

This minimizes:
- Firebase read operations (cost)
- Network requests (performance)
- Data usage (mobile friendly)

## Security Rules

The data is configured for public read access in [firestore.rules](../firebase/firestore.rules):
```javascript
match /styles/{styleId} {
  allow read: if true;  // Public read
  allow write: if isAdmin();  // Admin only
}
```

Make sure your Firestore rules allow public read access for these collections if you want unauthenticated users to see the data.

## Next Steps

1. **Upload your data**: Run the upload script to populate Firestore
2. **Test the app**: Verify data loads correctly
3. **Update data**: Modify data in Firebase Console to see live updates
4. **Monitor usage**: Check Firebase Console for read/write metrics

## Troubleshooting

### Data not loading from Firebase
- Check Firebase initialization in main.dart
- Verify Firestore rules allow read access
- Check console logs for error messages
- Ensure data is uploaded to correct collections

### App using JSON instead of Firebase
- This is normal fallback behavior
- Check network connectivity
- Verify Firebase project configuration
- Review console logs for Firebase errors

### Empty data in app
- Upload data to Firebase using the script
- Check collection names match exactly
- Verify document IDs are set correctly
- Test with JSON fallback enabled
