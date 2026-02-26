# Migration File Upload - Quick Reference

## 📋 Summary

Your migration system now supports **production-ready file uploads** with:

✅ **Idempotency** - Safe to run multiple times  
✅ **Auto-path detection** - Works in dev & production  
✅ **Environment-aware URLs** - Emulator vs production  
✅ **Asset bundling** - Files included in deployment  

---

## 🎯 File Naming Strategy (Current)

### Source Files (Apps)
```
apps/barbcut/assets/data/images/
  └── {SHA256-hash}.png
```

**Example**: `017d638e3daea06085427bc0314cff61ae758c6bcf739e38eea8385e493e44dd.png`

**Why?**
- ✅ Content-based (same image = same hash)
- ✅ No duplicates possible
- ✅ Cache-friendly (immutable)
- ✅ Automatic deduplication

### Storage Organization
```
gs://barb-cut.appspot.com/styles/
  ├── textured-crew-cut/
  │   ├── front.png
  │   ├── left_side.png
  │   ├── right_side.png
  │   └── back.png
  └── bowl-cut/
      └── ...
```

**Why?**
- ✅ Human-readable paths
- ✅ Organized by entity
- ✅ Predictable URLs
- ✅ Easy to manage

---

## 🚀 Usage

### Development (Emulator)
```bash
cd firebase/functions
npm run migrate:up
```
✅ Auto-detects files from `apps/barbcut/assets/`

### Production
```bash
cd firebase/functions

# 1. Bundle assets
npm run copy-assets

# 2. Deploy (auto-runs predeploy)
npm run deploy

# 3. Set credentials
export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"

# 4. Run migration
npm run migrate:prod up
```

---

## 📝 Adding New Styles

1. **Add image files** to `apps/barbcut/assets/data/images/`
   - Any unique filename works (hash recommended)
   - PNG format preferred

2. **Update `data.json`**:
```json
{
  "id": "fade-cut",
  "name": "Fade Cut",
  "images": {
    "front": "/apps/barbcut/assets/data/images/your-hash-here.png",
    "left_side": "/apps/barbcut/assets/data/images/another-hash.png",
    "right_side": "/apps/barbcut/assets/data/images/more-hash.png",
    "back": "/apps/barbcut/assets/data/images/last-hash.png"
  }
}
```

3. **Run migration**:
   - Dev: `npm run migrate:up`
   - Prod: `npm run copy-assets && npm run deploy && npm run migrate:prod up`

---

## 🔄 How It Works

### Path Auto-Detection
```typescript
// Migration checks both locations:
1. firebase/functions/build/data/images/  ← Production (bundled)
2. apps/barbcut/assets/data/images/       ← Development

// Uses whichever exists
```

### Idempotency
```typescript
// Before uploading, checks:
1. Does file already exist in Storage? → Skip
2. Does style already exist in Firestore? → Skip

// Safe to run multiple times!
```

### URL Generation
```typescript
// Emulator:
http://127.0.0.1:9199/v0/b/barb-cut.appspot.com/o/styles%2Ffade%2Ffront.png?alt=media

// Production:
https://storage.googleapis.com/barb-cut.appspot.com/styles/fade/front.png
```

---

## 📦 What Gets Bundled

**Source** (version controlled):
```
apps/barbcut/assets/data/images/
  ├── data.json
  └── *.png (8 images × ~1.5MB = 12MB)
```

**Bundled** (gitignored, auto-generated):
```
firebase/functions/src/data/images/
  ├── data.json
  └── *.png (copied at build time)
```

**Deployed**:
```
Firebase Functions package includes:
  build/data/images/*.png
  build/migrations/*.js
  build/cli.js
```

---

## 🛠️ Scripts Reference

| Command | When | What |
|---------|------|------|
| `npm run copy-assets` | Before deploy | Copies images to functions |
| `npm run clean-assets` | Cleanup | Removes bundled assets |
| `npm run migrate:up` | Dev | Runs migrations locally |
| `npm run migrate:prod up` | Production | Runs on real Firebase |
| `npm run deploy` | Production | Deploys functions (auto-copies) |

---

## ✅ Verification Checklist

After running migration:

**Emulator** (http://127.0.0.1:4000):
- [ ] Check Storage tab → See `styles/{id}/*.png` files
- [ ] Check Firestore tab → See `styles` collection
- [ ] Verify image URLs work in browser

**Production** (Firebase Console):
- [ ] Storage → Browse `styles/` folder
- [ ] Firestore → Check `styles` collection
- [ ] Copy URL → Paste in browser → Image loads

---

## 🔍 Troubleshooting

### "File not found" error
**Development**: Files missing in `apps/barbcut/assets/data/images/`  
**Production**: Run `npm run copy-assets` before deploying

### "Already exists" messages  
✅ **Normal!** Idempotency working. Files won't re-upload.

### Need to re-upload everything
```bash
npm run migrate:down  # Deletes all
npm run migrate:up    # Re-uploads all
```

### Production URLs not working
1. Check if `makePublic()` was called
2. Verify storage rules allow `read: if true`
3. Test URL in incognito browser

---

## 📚 Full Documentation

- **[README_MIGRATIONS.md](./README_MIGRATIONS.md)** - Complete guide
- **[README_MIGRATIONS.md](./README_MIGRATIONS.md)** - Migrations and file management
- **[firebase/functions/src/migrations/](./src/migrations/)** - Migration code

---

## 🎓 Key Concepts

**Content-Hash Naming** = Immutable files with guaranteed uniqueness  
**Organized Storage Paths** = Human-readable, hierarchical structure  
**Idempotency** = Safe to run multiple times without side effects  
**Auto-Detection** = Works in dev and production automatically  
**Asset Bundling** = Files packaged with function deployment  

---

**Need help?** Check the full docs in README_MIGRATIONS.md
