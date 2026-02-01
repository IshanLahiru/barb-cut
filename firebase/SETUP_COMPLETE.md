# 🎯 Firebase Setup - Complete

Your Firebase directory now has a **production-ready migration system** for Firestore.

## ✅ What's Installed

### Migration System
- ✅ **migrations/** - Where you define schema changes
- ✅ **functions/src/migrations.ts** - Core migration runner
- ✅ **functions/src/cli.ts** - Command-line interface
- ✅ **MIGRATIONS.md** - Setup & reference guide
- ✅ **WORKFLOW.md** - Daily workflow guide

### Example Migrations (Already Included)
- **001_init_users** - User collection structure
- **002_init_styles** - Haircut & beard styles samples

### Scripts (in package.json)
```bash
npm run migrate:up       # Run pending migrations
npm run migrate:down     # Rollback last migration
npm run migrate:status   # Check current version
npm run serve           # Start local emulator
npm run deploy          # Deploy to production
```

---

## 🚀 Get Started in 3 Steps

### Step 1: Add Service Account Key
```bash
# Download from Firebase Console:
# Settings → Service Accounts → Generate New Private Key

# Save it as:
firebase/serviceAccountKey.json
```

### Step 2: Set Environment Variable
```bash
export GOOGLE_APPLICATION_CREDENTIALS="firebase/serviceAccountKey.json"
```

### Step 3: Run Migrations
```bash
cd firebase
npm install
npm run migrate:status
npm run migrate:up
```

---

## 📁 Your Database Structure (Ready to Use)

Currently tracking 2 collections:

### `users/{userId}`
```json
{
  "displayName": "string",
  "email": "string",
  "phone": "string (optional)",
  "role": "customer|barber|admin",
  "createdAt": "timestamp",
  "lastActiveAt": "timestamp",
  "isActive": "boolean"
}
```

### `styles/{styleId}`
```json
{
  "name": "string",
  "type": "haircut|beard",
  "price": "number",
  "durationMinutes": "number",
  "description": "string",
  "tags": ["string"],
  "isActive": "boolean",
  "createdAt": "timestamp"
}
```

---

## 📚 Next: Add More Collections

**Files to create:**
1. `firebase/migrations/003_init_bookings.ts`
2. `firebase/migrations/004_init_payments.ts`
3. `firebase/migrations/005_init_ai_generations.ts`

Copy from `firebase/migrations/TEMPLATE.ts` and customize!

---

## 📖 Documentation

- **[MIGRATIONS.md](./MIGRATIONS.md)** - Full setup guide
- **[WORKFLOW.md](./WORKFLOW.md)** - Daily workflow & examples

---

## ❓ Quick FAQ

**Q: Can I change my data after migrations run?**  
A: Yes! Create a new migration to add/modify fields.

**Q: Can I rollback?**  
A: Yes! `npm run migrate:down` rolls back the last migration.

**Q: Do I commit serviceAccountKey.json?**  
A: **NO!** It's in .gitignore for security.

**Q: How do I test locally?**  
A: Use the Firebase Emulator: `npm run serve`

---

## 🎓 Example: Create Migration 003

Copy `TEMPLATE.ts`, update the number, and follow this pattern:

```typescript
// migrations/003_init_bookings.ts
import * as admin from "firebase-admin";

export async function up(db: admin.firestore.Firestore) {
  console.log("⬆️  Running migration 003: init_bookings");
  
  // Your logic here
  await db.collection("bookings").add({
    userId: "sample",
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log("✓ Bookings collection created");
}

export async function down(db: admin.firestore.Firestore) {
  console.log("⬇️  Rolling back migration 003");
  
  // Delete all bookings
  const batch = db.batch();
  const docs = await db.collection("bookings").get();
  docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
}

export const migration = { id: "003_init_bookings", up, down };
```

Then:
1. Add to `migrations/index.ts`
2. Add to `functions/src/migrations.ts`
3. Run `npm run migrate:up`

---

## 🔗 Related Files

- **firestore.rules** - Security rules (already set up)
- **firestore.indexes.json** - Composite indexes (add as needed)
- **firebase.json** - Firebase project config

---

**Questions?** See [MIGRATIONS.md](./MIGRATIONS.md) or [WORKFLOW.md](./WORKFLOW.md)
