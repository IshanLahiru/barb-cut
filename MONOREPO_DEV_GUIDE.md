# Barbcut Monorepo - Development Guide

This document describes the complete development workflow for the Barbcut monorepo using Turborepo and Firebase Emulators.

## 🏗️ Architecture Overview

```
barb-cut/
├── apps/
│   └── barbcut/              # Flutter mobile app
├── firebase/
│   ├── functions/            # Cloud Functions & migration scripts
│   └── emulator-data/        # Persisted emulator data (auto-generated)
├── scripts/
│   └── start-local-dev.sh    # Automated startup script
└── turbo.json                # Turborepo pipeline configuration
```

## 🚀 Quick Start

### One-Command Startup

```bash
npm run start:local
```

This single command will:
1. ✅ Install all dependencies
2. ✅ Start Firebase emulators with data persistence
3. ✅ Run initial data migration (if no data exists)
4. ✅ Display emulator UI URL and next steps

### Run Flutter App

In a **new terminal**, navigate to the Flutter app and run:

```bash
cd apps/barbcut
flutter run
```

The app automatically connects to local emulators in debug mode.

## 📋 Available Commands

### Root Level Commands (run from `/`)

| Command | Description |
|---------|-------------|
| `npm run start:local` | 🎯 **Recommended**: Complete local dev setup |
| `npm run dev:local` | Run all services in parallel via Turborepo |
| `npm run emulator:start` | Start Firebase emulators only |
| `npm run emulator:migrate` | Re-run data migration to emulators |
| `npm run build` | Build all packages |
| `npm run lint` | Lint all packages |
| `npm run clean` | Clean all build artifacts |

### Firebase Commands (run from `/firebase`)

| Command | Description |
|---------|-------------|
| `npm run emulator:start` | Start emulators with data persistence |
| `npm run emulator:start:clean` | Start emulators with fresh data |
| `npm run emulator:migrate` | Migrate data to running emulators |
| `npm run dev` | Start emulators (turbo-compatible) |
| `npm run build` | Build Cloud Functions |
| `npm run deploy` | Deploy to production Firebase |
| `npm run deploy:functions` | Deploy functions only |
| `npm run deploy:rules` | Deploy security rules only |

### Flutter Commands (run from `/apps/barbcut`)

| Command | Description |
|---------|-------------|
| `flutter run` | Run app (connects to emulators in debug) |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter test` | Run unit tests |
| `flutter analyze` | Analyze code for issues |

## 🔥 Firebase Emulators

### Emulator Ports

| Service | Port | URL |
|---------|------|-----|
| **Emulator UI** | 4000 | http://127.0.0.1:4000 |
| Auth | 9099 | http://127.0.0.1:9099 |
| Firestore | 8080 | http://127.0.0.1:8080 |
| Storage | 9199 | http://127.0.0.1:9199 |
| Functions | 5001 | http://127.0.0.1:5001 |

### Data Persistence

Emulator data is automatically persisted in `firebase/emulator-data/` directory:

- Data **persists** between emulator restarts
- Data is **excluded** from git (in `.gitignore`)
- To reset data, delete the directory or use `emulator:start:clean`

#### Firebase CLI Flags (Automatic Persistence)

If you start emulators manually with the Firebase CLI, use `--import` and `--export-on-exit` to persist data between sessions:

```bash
firebase emulators:start --import=./firebase-data --export-on-exit=./firebase-data
```

- `--import=./firebase-data` loads data on startup (the directory is created if it does not exist)
- `--export-on-exit=./firebase-data` saves emulator state on shutdown

These flags work with Auth, Firestore, Realtime Database, and Storage emulators.

#### Manual Export/Import

Export from a running emulator:

```bash
firebase emulators:export ./export-directory
```

Import on startup:

```bash
firebase emulators:start --import=./export-directory
```

### Emulator UI Features

Access at http://127.0.0.1:4000:

- 👀 View Firestore collections and documents
- 👤 Manage test users and authentication
- 📦 Browse Storage files
- 📊 Monitor request logs
- 🧹 Clear data between tests

## 🔄 Data Migration

### Initial Migration

On first run, the startup script automatically migrates data from local JSON files to Firestore:

```bash
# Happens automatically via start:local
# Or run manually:
npm run emulator:migrate
```

### Re-running Migration

To refresh emulator data with latest JSON files:

```bash
cd firebase/functions
npm run migrate:data:local:clear
```

This clears existing data and re-uploads from:
- `apps/barbcut/assets/data/*.json`

### Production Migration

⚠️ **Not needed yet** - only for future production deployment:

```bash
cd firebase/functions
npm run migrate:data:prod:clear
```

## 📱 Flutter + Firebase Connection

### Automatic Emulator Connection

In **debug mode**, the Flutter app automatically connects to local emulators:

```dart
// apps/barbcut/lib/main.dart
if (kDebugMode) {
  await _connectToEmulators(); // Auto-connects to 127.0.0.1
}
```

This happens transparently - no configuration needed!

### Production Mode

In **release builds**, the app connects to production Firebase:

```bash
flutter build apk --release  # Uses production Firebase
```

## 🛠️ Development Workflow

### Daily Workflow

1. **Start Backend**
   ```bash
   npm run start:local
   ```
   Keep this terminal running.

2. **Run Flutter App** (new terminal)
   ```bash
   cd apps/barbcut
   flutter run
   ```

3. **Open Emulator UI**
   - Visit http://127.0.0.1:4000
   - Inspect data, users, storage

4. **Develop!**
   - Edit Flutter code - hot reload applies instantly
   - Edit Cloud Functions - emulator auto-reloads
   - Edit security rules - changes apply immediately

5. **Stop Everything**
   - Press `Ctrl+C` in emulator terminal
   - Data persists for next session

### Testing Data Changes

```bash
# Edit JSON files in apps/barbcut/assets/data/
cd firebase/functions
npm run migrate:data:local:clear
# Restart Flutter app to see changes
```

### Clearing Emulator Data

```bash
# Option 1: Manual delete
rm -rf firebase/emulator-data

# Option 2: Clean start
cd firebase
npm run emulator:start:clean
```

## 🏗️ Turborepo Integration

### Pipeline Configuration

The `turbo.json` defines task dependencies:

```json
{
  "pipeline": {
    "emulator:start": {
      "cache": false,
      "persistent": true,
      "dependsOn": ["^build"]
    },
    "emulator:migrate": {
      "cache": false,
      "dependsOn": ["^build", "emulator:start"]
    },
    "dev:local": {
      "cache": false,
      "persistent": true,
      "dependsOn": ["emulator:start"]
    }
  }
}
```

### Parallel Execution

Turbo runs independent tasks in parallel:

```bash
npm run dev:local        # Runs all dev tasks in parallel
turbo run build --parallel  # Builds all packages at once
```

### Workspace Structure

```json
{
  "workspaces": [
    "apps/*",      // Flutter app (non-npm, but included in turbo tasks)
    "firebase"     // Firebase functions & config
  ]
}
```

## 🐛 Troubleshooting

### Emulators Won't Start

**Error**: Port already in use

```bash
# Find and kill processes on emulator ports
lsof -ti:4000,8080,9099,9199,5001 | xargs kill -9

# Or manually check:
lsof -i:8080  # Replace with specific port
```

### Flutter Can't Connect to Emulator

**Error**: `Connection refused` or `FirebaseException`

1. Verify emulators are running:
   ```bash
   curl http://127.0.0.1:8080
   ```

2. Check debug mode:
   ```dart
   // Emulator connection only works with kDebugMode = true
   flutter run --debug  // ✅ Connects to emulator
   flutter run --release  // ❌ Connects to production
   ```

3. Check Flutter console for connection logs:
   ```
   ✅ Connected to Auth Emulator at 127.0.0.1:9099
   ✅ Connected to Firestore Emulator at 127.0.0.1:8080
   ✅ Connected to Storage Emulator at 127.0.0.1:9199
   ```

### No Data in Emulators

**Issue**: Emulator starts but no collections/data visible

```bash
# Check if migration ran
cd firebase/functions
npm run migrate:data:local:clear

# Check migration script output for errors
```

### Changes Not Appearing

**Issue**: Code changes not reflected in app

- **Flutter**: Press `r` in terminal for hot reload, `R` for hot restart
- **Functions**: Emulator auto-reloads, but check console for errors
- **Data**: Re-run migration if JSON files changed

### Build Errors

```bash
# Clean all build artifacts
npm run clean

# Reinstall dependencies
rm -rf node_modules firebase/node_modules firebase/functions/node_modules
npm install

# Flutter clean
cd apps/barbcut
flutter clean
flutter pub get
```

## 📊 Database Schema

See [FIREBASE_SCHEMA.md](firebase/FIREBASE_SCHEMA.md) for complete database structure.

### Collections

- `haircuts` - Haircut styles catalog
- `beard_styles` - Beard styles catalog
- `products` - Products catalog
- `users` - User profiles
- `users/{userId}/history` - User's style history

## 🚢 Production Deployment

**Not needed for current development**, but for future reference:

### Deploy Everything

```bash
cd firebase
npm run deploy
```

### Deploy Specific Services

```bash
npm run deploy:functions  # Functions only
npm run deploy:rules      # Security rules only
```

### Environment Variables

Add production secrets to Firebase:

```bash
firebase functions:config:set someservice.key="THE_API_KEY"
```

## 📚 Additional Resources

- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Turborepo Documentation](https://turbo.build/repo/docs)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)
- [LOCAL_DEVELOPMENT.md](firebase/LOCAL_DEVELOPMENT.md) - Detailed emulator guide

## 🎯 Best Practices

1. **Always use `npm run start:local`** for development
2. **Never commit** `firebase/emulator-data/` directory
3. **Keep emulators running** during development for hot reload
4. **Check Emulator UI** (port 4000) to debug data issues
5. **Run migrations** after changing JSON data files
6. **Use debug mode** for Flutter development (emulator connection)
7. **Test with emulators** before deploying to production

## 🔐 Security Notes

- Emulators have **no authentication** - use only locally
- Local data is **not encrypted** - don't use real user data
- Production deployment requires **Firebase security rules review**
- Test security rules in emulator before production deploy

---

**Need Help?**

- Check [firebase/LOCAL_DEVELOPMENT.md](firebase/LOCAL_DEVELOPMENT.md)
- Check [FIREBASE_MIGRATION_COMPLETE.md](FIREBASE_MIGRATION_COMPLETE.md)
- Review Flutter console logs for connection status
- Inspect Emulator UI at http://127.0.0.1:4000
