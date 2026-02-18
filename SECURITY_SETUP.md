# Security & API Keys Setup Guide

## Overview

This document outlines how environment variables and API keys are managed in this project to prevent accidental exposure of sensitive credentials.

## Environment Variables

### Key Security Practices

1. **Never commit `.env` files** - Use `.env.example` for reference templates
2. **All `.env` files are in `.gitignore`** - Ensures they won't be accidentally committed
3. **Use environment-specific variables** - Load from `.env` at runtime, never hardcode credentials

### `.env` Files

The following `.env` files exist in the repository and contain sensitive data:

- `/apps/barbcut/.env` - Flutter app Firebase and API credentials
- `/firebase/.env` - Firebase backend configuration
- `/.env` - Root-level configuration

These are **not committed** to version control.

### Reference Examples

The following `.env.example` files are committed and serve as templates:

- `/apps/barbcut/.env.example` - Template for Flutter app configuration
- `/firebase/.env.example` - Template for Firebase backend
- `/.env.example` - Template for root configuration

## API Keys & Credentials

### Current Configuration

#### Firebase (Multiple Platforms)
- **Web**: `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, etc.
- **iOS**: `FIREBASE_IOS_API_KEY`, separate iOS bundle ID
- **Android**: `FIREBASE_ANDROID_API_KEY`, separate Android app ID
- **Server**: `serviceAccountKey.json` (stored locally, not committed)

#### RevenueCat
- **API Key**: `REVENUECAT_API_KEY` (for handling subscriptions)

#### AI Provider
- **Replicate API Token**: `REPLICATE_API_TOKEN` (image generation)

## Setting Up Your Environment

1. Copy the example files to create your actual `.env` files:
   ```bash
   cp apps/barbcut/.env.example apps/barbcut/.env
   cp firebase/.env.example firebase/.env
   cp .env.example .env
   ```

2. Fill in the values with your actual API keys:
   - Get Firebase keys from [Firebase Console](https://console.firebase.google.com)
   - Get RevenueCat keys from [RevenueCat Dashboard](https://app.revenuecat.com)
   - Get Replicate token from [Replicate API](https://replicate.com/account/api-tokens)

3. **Important**: Never commit these files. They should already be in `.gitignore`.

## Accessing Credentials

### In Dart/Flutter Code
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['FIREBASE_API_KEY'];
```

### In Node.js/Firebase Functions
```javascript
const apiKey = process.env.FIREBASE_API_KEY;
```

## Service Account Keys

The `serviceAccountKey.json` file is needed for Firebase Admin SDK access:

1. Generate from [Firebase Console](https://console.firebase.google.com):
   - Project Settings → Service Accounts
   - Click "Generate New Private Key"

2. Place in appropriate directories (all are `.gitignore`'d):
   - `./serviceAccountKey.json` (root)
   - `./firebase/serviceAccountKey.json` (backend)

3. Reference via environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
   ```

## Security Checklist

- [x] All `.env` files are in `.gitignore`
- [x] No hardcoded API keys in source code
- [x] Service account keys are not committed
- [x] Example files (.env.example) are provided for reference
- [x] `.env.example` files are kept up-to-date with required variables

## Emergency: Exposed Credentials

If credentials are accidentally exposed:

1. **Immediately revoke the credentials**:
   - Firebase: Regenerate API keys in Console
   - RevenueCat: Rotate API keys in Dashboard
   - Others: Similarly revoke and rotate

2. **Update local `.env` files** with new credentials

3. **Check git history** for any commits containing secrets:
   ```bash
   git log --all --full-history -- ".env"
   git log --oneline --all | head -20
   ```

4. **Request any tools to remove secrets from history** if needed

## References

- [Firebase Security Best Practices](https://firebase.google.com/docs/database/security)
- [Dart dotenv Package](https://pub.dev/packages/flutter_dotenv)
- [Git Security - Handling Secrets](https://docs.github.com/en/code-security/secret-scanning)
