# Local Development with Firebase Emulators

This guide explains how to develop locally using Firebase Emulators with data persistence.

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Node.js 18 or higher
- Firebase project set up (for production deployment later)

## Setup

### 1. Install Dependencies

```bash
cd firebase/functions
npm install
```

### 2. Start Firebase Emulators

From the `firebase` directory:

```bash
cd firebase
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

This will:
- Start all emulators (Auth, Firestore, Functions, Storage)
- Import existing data from `./emulator-data` (if it exists)
- Export data to `./emulator-data` when you stop the emulators
- **Data persists** across emulator restarts!

### 3. Emulator Ports

The emulators run on these ports:
- **Firestore**: http://127.0.0.1:8080
- **Auth**: http://127.0.0.1:9099
- **Storage**: http://127.0.0.1:9199
- **Functions**: http://127.0.0.1:5001
- **Emulator UI**: http://127.0.0.1:4000

Open http://127.0.0.1:4000 to view the Emulator UI and manage data visually.

## Migrate Data to Emulator

### First Time Setup

1. **Start the emulators** (in one terminal):
   ```bash
   cd firebase
   firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
   ```

2. **Migrate data** (in another terminal):
   ```bash
   cd firebase/functions
   npm run migrate:data:local:clear
   ```

This will:
- Clear any existing data in the emulator
- Upload haircuts, beard_styles, and products from JSON files
- Data will be saved to `firebase/emulator-data/`

### Subsequent Runs

Just start the emulators, and your data will be automatically loaded:

```bash
cd firebase
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

## Configure Flutter App for Emulators

Update your Flutter app's `main.dart` to connect to emulators in debug mode:

```dart
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to emulators in debug mode
  if (kDebugMode) {
    await _connectToEmulators();
  }

  // ... rest of your main() function
}

Future<void> _connectToEmulators() async {
  // Firestore Emulator
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  
  // Auth Emulator
  await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
  
  // Storage Emulator
  await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
  
  print('🔧 Connected to Firebase Emulators');
}
```

## Development Workflow

### Daily Workflow

1. **Start Emulators** (terminal 1):
   ```bash
   cd firebase
   firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
   ```

2. **Run Flutter App** (terminal 2):
   ```bash
   cd apps/barbcut
   flutter run
   ```

3. **Make changes to data** using the app or Emulator UI

4. **Stop emulators** (Ctrl+C) - Data is automatically exported!

### Reset Data

If you want to start fresh:

```bash
# Clear emulator data
rm -rf firebase/emulator-data

# Start emulators
cd firebase
firebase emulators:start --export-on-exit=./emulator-data

# In another terminal, migrate fresh data
cd firebase/functions
npm run migrate:data:local:clear
```

## Available Scripts

In `firebase/functions/`:

### Local (Emulator) Scripts
- `npm run migrate:data:local` - Import data to emulator (additive)
- `npm run migrate:data:local:clear` - Clear emulator data and import fresh

### Production Scripts
- `npm run migrate:data:prod` - Import data to production (additive)
- `npm run migrate:data:prod:clear` - Clear production data and import fresh ⚠️

## Emulator Data Persistence

### Where is data stored?

Data is stored in: `firebase/emulator-data/`

This directory contains:
- `firestore_export/` - Firestore database snapshots
- `auth_export/` - Auth users export
- `storage_export/` - Storage files
- `firebase-export-metadata.json` - Metadata

### Should I commit emulator-data?

**No!** Add it to `.gitignore`:

```
# Firebase Emulator Data
firebase/emulator-data/
```

Each developer can generate their own test data.

## Testing Authentication

### Create Test Users in Emulator

1. Open Emulator UI: http://127.0.0.1:4000
2. Go to **Authentication** tab
3. Click **Add User**
4. Create test accounts (no real email needed!)

These users persist in `emulator-data/auth_export/`.

### Test User Example

```
Email: test@barbcut.com
Password: password123
```

## Troubleshooting

### Port Already in Use

If you see "Port 8080 is not open", try:

```bash
# Find and kill the process
lsof -ti:8080 | xargs kill -9

# Then restart emulators
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

### Data Not Persisting

Make sure you're using the `--export-on-exit` flag:

```bash
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

### Connection Refused from Flutter

1. Make sure emulators are running
2. Use `127.0.0.1` not `localhost` in Flutter
3. Check the ports match your `firebase.json` configuration
4. Restart the Flutter app after starting emulators

### Migration Script Fails

Ensure emulators are running first:

```bash
# Terminal 1
cd firebase
firebase emulators:start

# Terminal 2 (after emulators are ready)
cd firebase/functions
npm run migrate:data:local:clear
```

## Production Deployment

When you're ready to deploy to production:

### 1. Deploy Functions
```bash
cd firebase
firebase deploy --only functions
```

### 2. Deploy Rules
```bash
firebase deploy --only firestore:rules,storage:rules
```

### 3. Migrate Production Data
```bash
cd firebase/functions
npm run migrate:data:prod:clear
```

### 4. Update Flutter App
Remove or comment out the emulator connection code, or use environment variables:

```dart
if (kDebugMode && const bool.fromEnvironment('USE_EMULATOR', defaultValue: false)) {
  await _connectToEmulators();
}
```

Then run with:
```bash
# With emulator
flutter run --dart-define=USE_EMULATOR=true

# Production
flutter run
```

## Tips

1. **Keep emulators running** during development - they use minimal resources
2. **Use Emulator UI** at http://127.0.0.1:4000 for quick data inspection
3. **Export data regularly** by stopping emulators cleanly (Ctrl+C)
4. **Share seed data** - commit migration scripts, not emulator data
5. **Test auth flows** - emulator allows unlimited users without verification

## Next Steps

- [ ] Start emulators with persistence
- [ ] Run data migration
- [ ] Configure Flutter app to use emulators
- [ ] Create test users
- [ ] Test all app features locally
- [ ] Deploy to production when ready

---

For production deployment, see [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
