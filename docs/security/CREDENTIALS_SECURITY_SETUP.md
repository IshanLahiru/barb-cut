# Credential Security Setup Guide

## Overview
This project contains sensitive credentials and API keys that **MUST NEVER** be committed to version control. This guide explains how to properly configure your environment.

## Files Protected by .gitignore

### Credential Files
- `serviceAccountKey.json` - Firebase Service Account private key
- `GoogleService-Info.plist` - iOS Firebase configuration
- `google-services.json` - Android Firebase configuration
- `.firebaserc` - Firebase CLI configuration
- `firebase.json` - Firebase project configuration
- `.env`, `.env.local`, `.env.*.local` - Environment variables with secrets

### Key Patterns Protected
- `*.key` - Any private key files
- `*.pem` - Any PEM-encoded certificate files
- `*-key.json` - Any JSON key files

## Setup Instructions

### 1. Root Level Setup
Copy the example files to their actual names and fill in your credentials:

```bash
# Firebase credentials
cp serviceAccountKey.json.example serviceAccountKey.json
cp GoogleService-Info.plist.example GoogleService-Info.plist
cp google-services.json.example google-services.json
cp firebase.json.example firebase.json
cp .firebaserc.example .firebaserc
cp .env.example .env
```

### 2. Apps/BarbCut Setup
```bash
cd apps/barbcut/
cp .firebaserc.example .firebaserc
# Copy Firebase generated files as needed
cp ../../firebase.json.example firebase.json
```

### 3. Firebase Directory Setup
```bash
cd firebase/
cp .firebaserc.example .firebaserc
cd functions/
cp .env.example .env
cp ../../serviceAccountKey.json.example serviceAccountKey.json
```

## Where to Get Your Credentials

### Firebase Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save as `serviceAccountKey.json`

### Firebase Configuration Files
1. Run: `flutterfire configure`
2. This will automatically generate:
   - `GoogleService-Info.plist` (iOS)
   - `google-services.json` (Android)
   - `lib/firebase_options.dart`
   - Update `firebase.json`

### Environment Variables (.env)
Create `.env` file with:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
REPLICATE_API_TOKEN=your_replicate_token
```

## Security Best Practices

### ✅ DO
- Store all credentials in `.env` or local files (never in git)
- Use `.example` files as templates for setup
- Rotate credentials regularly
- Use different credentials for dev/staging/production
- Enable 2FA on Firebase account
- Restrict service account permissions

### ❌ DON'T
- Commit any credential files to git
- Share credentials via email or chat
- Use the same credentials across environments
- Hardcode API keys in source code
- Push secrets in commit messages
- Share example files that contain real credentials

## Verifying Your Setup

Check that sensitive files are NOT being tracked:
```bash
# This should show empty (all files ignored)
git status | grep -E "(service|firebase|plist|json|\.env)"

# Verify files are in gitignore
git check-ignore -v serviceAccountKey.json
git check-ignore -v GoogleService-Info.plist
git check-ignore -v .env
```

## If You Accidentally Committed Credentials

1. **IMMEDIATELY** rotate all compromised credentials
2. Remove from git history:
   ```bash
   git rm --cached serviceAccountKey.json
   git commit --amend
   ```
3. Force push: `git push --force-with-lease`
4. Notify team members
5. Update `.env` with new credentials

## CI/CD Environment Variables

For GitHub Actions or other CI systems:
1. Never commit `.env` files
2. Add secrets via repository settings
3. Reference as: `${{ secrets.FIREBASE_API_KEY }}`
4. Use different secrets for different environments

## Example File Updates

When `.example` files are updated, developers should:
```bash
# Review what changed
diff .env.example .env

# Add new variables to .env
# Never commit .env itself
```

## Questions?
Refer to Firebase docs:
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Service Account Setup](https://firebase.google.com/docs/admin/setup)
- [Security Rules](https://firebase.google.com/docs/rules)
