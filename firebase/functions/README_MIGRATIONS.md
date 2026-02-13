# Firebase Functions Migrations Guide

## Quick Start

### Development (Emulator)
```bash
cd firebase/functions

# Start emulators (includes storage)
npm run serve

# Run migrations
npm run migrate:up

# Check migration status
npm run migrate:status

# Rollback if needed
npm run migrate:down
```

### Production
```bash
cd firebase/functions

# 1. Set up credentials
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"

# 2. Copy assets to functions directory (for deployment)
npm run copy-assets

# 3. Deploy functions (includes pre-deploy asset copy)
npm run deploy

# 4. Run migrations on production
npm run migrate:prod up
```

## File Management

### How Files Are Organized

**Source Files** (version controlled):
```
apps/barbcut/assets/data/images/
  ├── data.json
  ├── 017d638e3daea06085427bc0314cff61ae758c6bcf739e38eea8385e493e44dd.png
  ├── 1603d6b0a8a122c9d24d2c30b6687d779da6b8d3ca606622815f8fea77d6fa36.png
  └── ...
```

**Bundled for Deployment** (generated, gitignored):
```
firebase/functions/src/data/images/
  ├── data.json
  └── *.png
```

**Uploaded to Storage**:
```
gs://barb-cut.appspot.com/
  └── styles/
      ├── textured-crew-cut/
      │   ├── front.png
      │   ├── left_side.png
      │   ├── right_side.png
      │   └── back.png
      └── bowl-cut/
          └── ...
```

### File Naming Strategy

**Current: Content-Hash Based** ✅ Recommended

Files use SHA256 content hashes:
- ✅ Automatic deduplication
- ✅ Cache-friendly (immutable content)
- ✅ No naming conflicts
- ❌ Not human-readable

**Storage paths** are organized and descriptive:
- `styles/{style-id}/front.png`
- `styles/{style-id}/left_side.png`

This gives you the best of both worlds:
- Source files are content-addressed (efficient)
- Storage paths are organized and readable

### Adding New Styles

1. **Add images** to `apps/barbcut/assets/data/images/`
   - Use content-hash filenames (or any unique name)
   - PNG format recommended

2. **Update data.json**:
```json
{
  "id": "new-style-id",
  "name": "New Style Name",
  "images": {
    "front": "/apps/barbcut/assets/data/images/hash123.png",
    "left_side": "/apps/barbcut/assets/data/images/hash456.png",
    "right_side": "/apps/barbcut/assets/data/images/hash789.png",
    "back": "/apps/barbcut/assets/data/images/hashabc.png"
  }
}
```

3. **For development**:
```bash
# Migration auto-detects files from apps/barbcut/assets/
npm run migrate:up
```

4. **For production**:
```bash
# Copy new assets
npm run copy-assets

# Deploy
npm run deploy

# Run migration
npm run migrate:prod up
```

## Migration Features

### ✅ Idempotency
Safe to run multiple times - skips:
- Already uploaded files
- Already created documents
- Already tracked migrations

### ✅ Path Auto-Detection
Works in both environments:
- **Development**: Reads from `apps/barbcut/assets/`
- **Production**: Reads from bundled `src/data/`

### ✅ Environment-Aware URLs
Generates correct URLs for:
- **Emulator**: `http://127.0.0.1:9199/v0/b/.../o/...?alt=media`
- **Production**: `https://storage.googleapis.com/...`

### ✅ Rollback Support
```bash
npm run migrate:down  # Removes styles and deletes uploaded images
```

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run copy-assets` | Copy assets from apps to functions |
| `npm run clean-assets` | Remove bundled assets |
| `npm run build` | Compile TypeScript |
| `npm run serve` | Start Firebase emulators |
| `npm run deploy` | Deploy to production (auto-copies assets) |
| `npm run migrate:up` | Run pending migrations (emulator) |
| `npm run migrate:down` | Rollback last migration (emulator) |
| `npm run migrate:status` | Check migration version |
| `npm run migrate:prod` | Run migrations in production |

## Production Deployment Checklist

- [ ] **Credentials**: Set `GOOGLE_APPLICATION_CREDENTIALS`
- [ ] **Assets**: Run `npm run copy-assets` (or use `predeploy`)
- [ ] **Build**: Run `npm run build`
- [ ] **Deploy Functions**: `npm run deploy`
- [ ] **Run Migrations**: `npm run migrate:prod up`
- [ ] **Verify**: Check Firestore and Storage in Firebase Console
- [ ] **Test**: Verify URLs are accessible

## Troubleshooting

### "Bucket name not specified"
**Fixed** ✅ - Added `storageBucket` to `cli.ts`

### "File not found" in migration
- Development: Ensure files exist in `apps/barbcut/assets/data/images/`
- Production: Run `npm run copy-assets` before deploying

### "Already exists" warnings
**This is normal** - Idempotency working correctly. Files won't re-upload.

### Emulator storage not running
```bash
# Stop all emulators
pkill -f "firebase.*emulators"

# Start fresh
cd firebase/functions && npm run serve
```

### Need to re-upload everything
```bash
# Rollback migration
npm run migrate:down

# Clear storage (emulator auto-clears on restart)

# Re-run migration
npm run migrate:up
```

### Production files missing after deployment
Check `build/data/images/` directory exists after `npm run build`:
```bash
ls -la build/data/images/
```

If missing, run `npm run copy-assets` before building.

## Security Best Practices

### Public Files (Current)
Images are publicly accessible - good for:
- ✅ Profile pictures
- ✅ Style showcase images
- ✅ Static content
- ✅ CDN-friendly

### Private Files (Future)
For user uploads or sensitive content:
1. Skip `makePublic()` in migration
2. Use Firebase Auth tokens
3. Generate signed URLs
4. Set Storage Rules

### Storage Rules Example
```javascript
// firebase/storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Public read for style images
    match /styles/{styleId}/{imageFile} {
      allow read: if true;
      allow write: if false; // Only via Functions
    }
    
    // Private user uploads
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## Cost Considerations

### Storage Costs
- **Storage**: $0.026/GB/month
- **Downloads**: $0.12/GB (US)
- **Operations**: $0.05 per 10,000 operations

### Optimization Tips
1. **Compress images** before upload
2. **Use appropriate formats** (WebP > PNG)
3. **Set cache headers** (already done: 1 year)
4. **Use CDN** (Firebase Storage has built-in CDN)
5. **Lazy load** images in app

### Estimated Costs (Example)
- 100 styles × 4 images × 500KB = ~200 MB storage → **$0.01/month**
- 10,000 users × 10 image views = 100,000 downloads × 0.5MB = 50GB → **$6.00/month**

## Next Steps

1. **Add more styles**: Update `data.json` and run migration
2. **Implement storage rules**: Secure production storage
3. **Add image optimization**: Compress images before upload
4. **Create admin panel**: Manage styles via web interface
5. **Add CDN**: Use Firebase CDN for better performance
6. **Monitor costs**: Set up billing alerts in Firebase Console

## Documentation

- [FILE_MANAGEMENT_STRATEGY.md](./FILE_MANAGEMENT_STRATEGY.md) - Detailed file strategy
- [Firebase Storage Docs](https://firebase.google.com/docs/storage)
- [Cloud Functions Docs](https://firebase.google.com/docs/functions)
