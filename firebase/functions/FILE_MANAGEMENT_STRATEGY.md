# File Management Strategy for Firebase Migrations

## Overview
This document explains how files (images, assets) are managed during migrations for both development (emulator) and production environments.

## File Naming Convention

### Option 1: Content-Hash Based (Current - Recommended)
**✅ Current Implementation**

Files are named using SHA256 content hashes:
```
017d638e3daea06085427bc0314cff61ae758c6bcf739e38eea8385e493e44dd.png
```

**Pros:**
- Automatic deduplication (same image = same hash)
- Cache-friendly (content never changes for a given hash)
- No naming conflicts ever

**Cons:**
- Not human-readable
- Can't tell what image is from filename alone

### Option 2: Descriptive Names
```
textured-crew-cut-front.png
textured-crew-cut-left.png
```

**Pros:**
- Human-readable
- Easy to understand

**Cons:**
- Must manually ensure uniqueness
- Requires renaming if style name changes

## Storage Organization

Images are uploaded to Firebase Storage with organized paths:
```
storage://
  └── styles/
      ├── textured-crew-cut/
      │   ├── front.png
      │   ├── left_side.png
      │   ├── right_side.png
      │   └── back.png
      └── bowl-cut/
          ├── front.png
          ├── left_side.png
          ├── right_side.png
          └── back.png
```

This provides:
- ✅ Organized by entity (style)
- ✅ Predictable paths
- ✅ Easy to manage/backup
- ✅ Clean URLs

## Production Deployment Strategy

### 1. Bundle Assets with Functions
Assets must be included in the Functions deployment package:

```
firebase/functions/
  ├── src/
  │   ├── migrations/
  │   └── data/           # ← Assets bundled here
  │       └── images/
  │           ├── data.json
  │           └── *.png
  └── package.json
```

### 2. Copy Assets Before Deployment
Add a pre-deploy script to `package.json`:

```json
{
  "scripts": {
    "copy-assets": "mkdir -p src/data/images && cp -r ../../apps/barbcut/assets/data/images/* src/data/images/",
    "predeploy": "npm run copy-assets",
    "deploy": "firebase deploy --only functions"
  }
}
```

### 3. Path Resolution
The migration uses relative paths that work in both environments:

```typescript
// Development (running from source)
const dataPath = path.join(__dirname, '../../apps/barbcut/assets/data/images');

// Production (bundled with functions)
const dataPathProduction = path.join(__dirname, '../data/images');

// Auto-detect which exists
const dataPath = fs.existsSync(dataPathProd) ? dataPathProd : dataPathDev;
```

## Idempotency (Prevent Re-uploads)

Migrations should be idempotent - safe to run multiple times:

```typescript
async function uploadIfNotExists(localPath: string, storagePath: string) {
  const bucket = admin.storage().bucket();
  const file = bucket.file(storagePath);
  
  // Check if file already exists
  const [exists] = await file.exists();
  
  if (exists) {
    console.log(`    ⏭️  Skipped (already exists): ${storagePath}`);
    return getPublicUrl(storagePath);
  }
  
  // Upload only if doesn't exist
  return uploadImageToStorage(localPath, storagePath);
}
```

## URL Generation

### Emulator
```
http://127.0.0.1:9199/v0/b/barb-cut.appspot.com/o/styles%2Ftextured-crew-cut%2Ffront.png?alt=media
```

### Production
```
https://storage.googleapis.com/barb-cut.appspot.com/styles/textured-crew-cut/front.png
```
Or using Firebase's signed URLs for access control:
```
https://firebasestorage.googleapis.com/v0/b/barb-cut.appspot.com/o/styles%2Ftextured-crew-cut%2Ffront.png?alt=media&token=xxx
```

## Best Practices

1. **Keep Source Files Separate**: Original assets stay in `apps/barbcut/assets/`
2. **Bundle for Functions**: Copy to `functions/src/data/` for deployment
3. **Ignore in Git**: Add `functions/src/data/` to `.gitignore` (copied at build time)
4. **Version in JSON**: Track file references in `data.json`
5. **Make Idempotent**: Check if files exist before uploading
6. **Validate Checksums**: Optional - verify file integrity after upload

## Example Workflow

### Development
```bash
cd firebase/functions
npm run migrate:up  # Uses emulator, reads from apps/barbcut/assets/
```

### Production
```bash
cd firebase/functions
npm run copy-assets  # Copies assets to src/data/
npm run build        # Compiles TypeScript
firebase deploy --only functions  # Deploys with bundled assets
```

Then run migrations:
```bash
GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json node build/cli.js up
```

## Security Considerations

1. **Public vs Private**: Default makes files public. For private files, skip `makePublic()` and use signed URLs
2. **File Size Limits**: Firebase Functions have memory limits (default 256MB)
3. **Timeout**: Large uploads may timeout (default 60s for HTTP functions)
4. **Cost**: Storage and bandwidth costs apply in production

## Troubleshooting

### "Bucket name not specified"
✅ Fixed: Added `storageBucket: "barb-cut.appspot.com"` to admin.initializeApp()

### "File not found" in production
Add assets to deployment package using copy-assets script

### "Port not available" in emulator
Stop processes: `pkill -f "firebase.*emulators"`

### Re-upload files
Run migration down then up: `npm run migrate:down && npm run migrate:up`
