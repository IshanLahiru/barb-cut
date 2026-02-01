# Firebase Database Migrations

This directory manages Firestore database schema and data migrations.

## 📁 Structure

```
firebase/
├── migrations/          # Migration scripts
│   ├── 001_init_users.ts
│   ├── 002_init_styles.ts
│   └── index.ts
├── functions/
│   └── src/
│       ├── migrations.ts    # Migration runner logic
│       └── cli.ts           # CLI commands
├── firestore.rules         # Security rules
├── firestore.indexes.json   # Firestore indexes
└── package.json
```

## 🚀 Quick Start

### 1. **Set up Firebase Service Account**

Download your Firebase service account key:
- Go to [Firebase Console](https://console.firebase.google.com)
- Project Settings → Service Accounts
- Click "Generate New Private Key"
- Save as `firebase/serviceAccountKey.json`

### 2. **Set Environment Variable**

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
```

### 3. **Install Dependencies**

```bash
cd firebase
npm install
```

### 4. **Run Migrations**

```bash
# Check status
npm run migrate:status

# Run all pending migrations
npm run migrate:up

# Rollback last migration
npm run migrate:down
```

## 📝 Create a New Migration

### Template: `migrations/00X_description.ts`

```typescript
import * as admin from "firebase-admin";

export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration 00X: description");
  // Your up logic here
}

export async function down(db: admin.firestore.Firestore) {
  console.log("⬇️  Rolling back migration 00X");
  // Your down logic here (rollback)
}

export const migration = {
  id: "00X_description",
  up,
  down,
};
```

### Steps:
1. Create new file in `migrations/`
2. Implement `up()` and `down()` functions
3. Export migration in `migrations/index.ts`
4. Run `npm run migrate:up`

## 📊 Example Migrations

### ✅ Included

- **001_init_users** - User collection metadata
- **002_init_styles** - Sample hairstyle data

## 🔒 Security & Best Practices

- ✅ Always test migrations locally first using emulator
- ✅ Never commit `serviceAccountKey.json` (it's in `.gitignore`)
- ✅ Every migration must have a `down()` for rollback
- ✅ Use batch operations for multiple writes
- ✅ Track migration status in `_migrations/migration_status`

## 🧪 Test Locally with Emulator

```bash
# In one terminal
npm run serve

# In another terminal
export GOOGLE_APPLICATION_CREDENTIALS="emulator" # Uses emulator
npm run migrate:up
```

## 🚨 Troubleshooting

**"GOOGLE_APPLICATION_CREDENTIALS not set"**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
```

**"Migration 001 already exists"**
- Run `npm run migrate:status` to check
- Only run `migrate:up` once per environment

**"Want to rollback?"**
```bash
npm run migrate:down
```

## 📚 Firestore Collections Reference

### `_migrations/migration_status` (system)
```json
{
  "version": 2,
  "lastMigration": "002_init_styles",
  "timestamp": "2026-02-01T12:00:00Z"
}
```

### `users/{userId}` (see 001_init_users)
```json
{
  "displayName": "string",
  "email": "string",
  "role": "customer|barber|admin",
  "createdAt": "timestamp"
}
```

### `styles/{styleId}` (see 002_init_styles)
```json
{
  "name": "string",
  "type": "haircut|beard",
  "price": "number",
  "durationMinutes": "number",
  "isActive": "boolean"
}
```

---

**Need to add more collections?** Create a new migration file and follow the template!
