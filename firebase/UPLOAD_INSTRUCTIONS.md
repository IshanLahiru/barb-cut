# Upload Data to Firebase

This guide explains how to upload your haircut images and data to Firebase Storage and Firestore.

## Prerequisites

1. **Service Account Key**: Download your Firebase service account key
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save it as `serviceAccountKey.json` in the `/firebase` directory

2. **Storage Bucket**: Get your storage bucket name
   - Go to Firebase Console → Storage
   - Your bucket name is usually `your-project-id.appspot.com`

## Setup

1. **Update the script** - Edit `upload-data.js` and replace:
   ```javascript
   storageBucket: 'your-project-id.appspot.com'
   ```
   and
   ```javascript
   https://storage.googleapis.com/your-project-id.appspot.com/
   ```
   with your actual project ID

2. **Install dependencies** (if not already installed):
   ```bash
   cd firebase
   npm install
   ```

## Run the Upload

```bash
cd firebase
node upload-data.js
```

## What It Does

### 1. Uploads Images to Storage
- Uploads all PNG files from `apps/barbcut/assets/data/images/`
- Stores them in the `haircut-images/` directory in Firebase Storage
- Makes them publicly accessible
- Adds cache headers for performance

### 2. Uploads Data to Firestore
- Uploads haircuts from `images/data.json` to `haircuts` collection
- Updates image paths to use Firebase Storage URLs
- Uploads other JSON files (beard_styles, products, etc.) to their respective collections

## Firestore Collections Created

- `haircuts` - Haircut styles with images
- `beard_styles` - Beard style data (if file exists)
- `products` - Product data (if file exists)

## After Upload

Your data will be available at:
- **Storage**: Firebase Console → Storage → `haircut-images/`
- **Firestore**: Firebase Console → Firestore Database → Collections

## Troubleshooting

- **Authentication Error**: Make sure `serviceAccountKey.json` is in the firebase directory
- **Bucket Not Found**: Update the storage bucket name in the script
- **Permission Denied**: Ensure your service account has Storage and Firestore permissions
