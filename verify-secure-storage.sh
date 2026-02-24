#!/bin/bash
# Verification script for secure storage implementation

echo "🔍 Secure Storage Implementation Verification Checklist"
echo "========================================================"
echo ""

PROJECT_ROOT="/Users/ishanlahiru/Documents/private/barb-cut"

# 1. Check storage rules
echo "✓ Checking Storage Rules..."
if grep -q "allow read: if request.auth != null;" "$PROJECT_ROOT/firebase/storage.rules"; then
    echo "  ✅ Storage rules require authentication"
else
    echo "  ❌ Storage rules missing auth requirement"
fi

# 2. Check migration 001 changes
echo ""
echo "✓ Checking Migration 001..."
if grep -q "cacheControl: \"private" "$PROJECT_ROOT/firebase/functions/src/migrations/001_init_styles_from_data.ts"; then
    echo "  ✅ Migration 001 uses private cache"
else
    echo "  ❌ Migration 001 still using public cache"
fi

if ! grep -q "makePublic()" "$PROJECT_ROOT/firebase/functions/src/migrations/001_init_styles_from_data.ts"; then
    echo "  ✅ Migration 001 removed makePublic()"
else
    echo "  ❌ Migration 001 still has makePublic()"
fi

# 3. Check upload config
echo ""
echo "✓ Checking Upload Config..."
if grep -q '"makePublic": false' "$PROJECT_ROOT/firebase/upload-data/config.json"; then
    echo "  ✅ Upload config disabled makePublic"
else
    echo "  ❌ Upload config still has makePublic enabled"
fi

if grep -q '"imageUrlPrefix": "haircut-images/"' "$PROJECT_ROOT/firebase/upload-data/config.json"; then
    echo "  ✅ Upload config uses storage paths"
else
    echo "  ❌ Upload config still using public URLs"
fi

# 4. Check migration 002 exists
echo ""
echo "✓ Checking Migration 002..."
if [ -f "$PROJECT_ROOT/firebase/functions/src/migrations/002_secure_storage_paths.ts" ]; then
    echo "  ✅ Migration 002 file exists"
else
    echo "  ❌ Migration 002 file missing"
fi

# 5. Check client-side storage helper
echo ""
echo "✓ Checking Client Storage Helper..."
if grep -q "_extractStoragePath" "$PROJECT_ROOT/apps/barbcut/lib/services/firebase_storage_helper.dart"; then
    echo "  ✅ Storage helper has URL normalization"
else
    echo "  ❌ Storage helper missing URL normalization"
fi

# 6. Check Node.js runtime
echo ""
echo "✓ Checking Node.js Runtime..."
if grep -q '"runtime": "nodejs20"' "$PROJECT_ROOT/firebase/firebase.json"; then
    echo "  ✅ Firebase config uses Node 20"
else
    echo "  ❌ Firebase config not updated to Node 20"
fi

# 7. Check helper scripts exist
echo ""
echo "✓ Checking Helper Scripts..."
if [ -f "$PROJECT_ROOT/firebase/revoke-public-acl.js" ]; then
    echo "  ✅ ACL revocation script exists"
else
    echo "  ❌ ACL revocation script missing"
fi

if [ -f "$PROJECT_ROOT/firebase/functions/fix-migration-status.js" ]; then
    echo "  ✅ Migration status helper exists"
else
    echo "  ❌ Migration status helper missing"
fi

echo ""
echo "========================================================"
echo "✨ Verification Complete!"
echo ""
echo "📝 Next: Run these commands to verify in Firebase:"
echo "   1. Check rules: firebase rules:test"
echo "   2. Verify migration: npm run migrate:status"
echo "   3. Revoke public ACLs: BUCKET_NAME=... node revoke-public-acl.js"
