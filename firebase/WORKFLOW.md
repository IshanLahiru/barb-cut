# Firebase Database Workflow

## 🎯 Overview

This setup provides a production-ready migration system for managing your Firestore database schema.

```
┌─────────────────────────────────────────────────────────┐
│  You write migration files (.ts)                        │
│  - Define schema changes                               │
│  - Add/modify collections                              │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│  npm run migrate:up                                      │
│  - Reads migration files                               │
│  - Checks current version in Firestore                │
│  - Runs only pending migrations                        │
│  - Updates _migrations/migration_status                │
└────────────┬────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│  Firestore Database                                     │
│  - Collections created/updated                         │
│  - Data seeded or transformed                          │
│  - Schema version tracked                              │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Daily Workflow

### 1️⃣ **Check Status**
```bash
npm run migrate:status
```
Shows:
- Current schema version
- Total available migrations
- Which migrations are pending

### 2️⃣ **Make Database Changes**

Example: Adding a new `bookings` collection

**File:** `firebase/migrations/003_init_bookings.ts`
```typescript
import * as admin from "firebase-admin";

export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration 003: init_bookings");

  // Create a sample booking
  await db.collection("bookings").add({
    userId: "sample_user",
    barberId: "sample_barber",
    status: "pending",
    scheduledAt: new Date(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log("✓ Bookings collection initialized");
}

export async function down(db: admin.firestore.Firestore) {
  // Rollback logic
}

export const migration = {
  id: "003_init_bookings",
  up,
  down,
};
```

### 3️⃣ **Register Migration**

**File:** `firebase/migrations/index.ts`
```typescript
export { migration as migration003InitBookings } from "./003_init_bookings";
```

### 4️⃣ **Add to migrations.ts**

**File:** `firebase/functions/src/migrations.ts`
```typescript
import { migration003InitBookings } from "./migrations";

const MIGRATIONS: Migration[] = [
  migration001InitUsers,
  migration002InitStyles,
  migration003InitBookings,  // ← Add here
];
```

### 5️⃣ **Test Locally**

```bash
# Terminal 1: Start emulator
npm run serve

# Terminal 2: Set to use emulator and test
export GOOGLE_APPLICATION_CREDENTIALS="emulator"
npm run migrate:up
```

### 6️⃣ **Deploy to Production**

```bash
# Set correct credentials for production
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"

# Run migrations
npm run migrate:up

# Verify
npm run migrate:status
```

---

## 🔄 Rollback Workflow

If something goes wrong:

```bash
# Check what version you're at
npm run migrate:status

# Rollback one migration
npm run migrate:down

# Or multiple times
npm run migrate:down
npm run migrate:down
npm run migrate:down
```

Each `migrate:down` calls the `down()` function in the migration to reverse changes.

---

## 📁 File Structure Reference

```
firebase/
├── migrations/
│   ├── 001_init_users.ts       ← First migration
│   ├── 002_init_styles.ts      ← Second migration
│   ├── 003_init_bookings.ts    ← Third migration (example)
│   ├── index.ts                ← Export all migrations
│   ├── TEMPLATE.ts             ← Copy for new migrations
│   └── ...
├── functions/src/
│   ├── migrations.ts           ← Migration runner logic
│   ├── cli.ts                  ← CLI commands
│   └── index.ts                ← Deployed functions
├── firestore.rules             ← Security rules
├── firestore.indexes.json      ← Indexes config
├── MIGRATIONS.md               ← Setup guide
└── WORKFLOW.md                 ← This file
```

---

## 🗂️ Your Collection Roadmap

Based on your app, create these migrations in order:

```
001 ✅ init_users          → User profiles & auth
002 ✅ init_styles         → Haircuts & beard styles
003    init_bookings       → Appointment bookings
004    init_payments       → Payment records
005    init_ai_generations → AI-generated images
```

---

## 💡 Best Practices

### ✅ DO:

- Write small, focused migrations (one change per file)
- Always include rollback (`down()` function)
- Use batch operations for multiple writes
- Test with emulator before production
- Number migrations sequentially (001, 002, 003...)
- Document what each migration does

### ❌ DON'T:

- Modify existing migration files (always create new ones)
- Run migrations manually without tracking
- Forget to export migrations in `index.ts`
- Commit `serviceAccountKey.json`
- Use auto-generated IDs if you need specific ordering

---

## 🚨 Common Scenarios

### Scenario: "I need to add a field to all users"

**Migration file:**
```typescript
export async function up(db: admin.firestore.Firestore) {
  const batch = db.batch();
  const users = await db.collection("users").get();

  users.forEach((doc) => {
    batch.update(doc.ref, {
      isVerified: false,
      verifiedAt: null,
    });
  });

  await batch.commit();
}
```

### Scenario: "I need to delete a collection"

**Migration file:**
```typescript
export async function up(db: admin.firestore.Firestore) {
  const batch = db.batch();
  const docs = await db.collection("old_collection").get();

  docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
}
```

### Scenario: "I need to transform data"

**Migration file:**
```typescript
export async function up(db: admin.firestore.Firestore) {
  const users = await db.collection("users").get();
  const batch = db.batch();

  users.forEach((doc) => {
    const data = doc.data();
    batch.update(doc.ref, {
      displayName: data.name, // Rename field
      name: admin.firestore.FieldValue.delete(), // Remove old field
    });
  });

  await batch.commit();
}
```

---

## 📞 Need Help?

- **Check MIGRATIONS.md** for setup instructions
- **Look at 001_init_users.ts** for examples
- **Use TEMPLATE.ts** to start a new migration
- **Test locally first** with emulator before deploying

Happy migrating! 🚀
