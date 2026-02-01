#!/bin/bash

# Firebase Migration Setup Script
# Run: ./setup-migrations.sh

set -e

echo "🔧 Setting up Firebase Migrations..."
echo ""

# Check if in firebase directory
if [ ! -f "firebase.json" ]; then
    echo "❌ Error: Run this script from the firebase/ directory"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build TypeScript
echo "🔨 Building TypeScript..."
npm run build

# Check for service account
if [ ! -f "serviceAccountKey.json" ]; then
    echo ""
    echo "⚠️  IMPORTANT: Add your Firebase Service Account Key"
    echo ""
    echo "Steps:"
    echo "1. Go to: https://console.firebase.google.com"
    echo "2. Project Settings → Service Accounts"
    echo "3. Click 'Generate New Private Key'"
    echo "4. Save as: firebase/serviceAccountKey.json"
    echo ""
    echo "Then set: export GOOGLE_APPLICATION_CREDENTIALS='firebase/serviceAccountKey.json'"
    echo ""
else
    echo "✓ Service account key found"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Add serviceAccountKey.json (see above)"
echo "   2. Set: export GOOGLE_APPLICATION_CREDENTIALS='firebase/serviceAccountKey.json'"
echo "   3. Run: npm run migrate:status"
echo "   4. Run: npm run migrate:up"
echo ""
echo "For more info, see MIGRATIONS.md"
