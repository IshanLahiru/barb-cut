# Firebase Architecture Diagram

## 📐 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Your Application (Flutter)                                 │
│  - Users sign up                                            │
│  - Book appointments                                        │
│  - Upload style preferences                                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Firebase Authentication                                    │
│  - User login/signup (managed by Firebase)                 │
│  - UID generation (immutable)                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Firestore Database (Real-time)                            │
│                                                             │
│  collections/                                              │
│  ├── users/{uid}                                           │
│  │   ├── displayName                                       │
│  │   ├── email                                             │
│  │   └── role                                              │
│  │                                                         │
│  ├── styles/{styleId}                                      │
│  │   ├── name                                              │
│  │   ├── type (haircut|beard)                              │
│  │   └── price                                             │
│  │                                                         │
│  ├── bookings/{bookingId}                                  │
│  │   ├── userId                                            │
│  │   ├── barberId                                          │
│  │   └── status                                            │
│  │                                                         │
│  └── _migrations/                                          │
│      └── migration_status (tracks schema version)          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  Cloud Functions (Server-side Logic)                       │
│  - Data validation                                         │
│  - AI generation triggers                                  │
│  - Email notifications                                     │
│  - Payment processing                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Migration System Flow

```
Developer writes migration
        ↓
    001_init_users.ts
    002_init_styles.ts
    003_init_bookings.ts (new)
        ↓
    npm run migrate:up
        ↓
┌─────────────────────────────────────────┐
│ CLI Entry (functions/src/cli.ts)        │
│ - Parse command                         │
│ - Check environment                     │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ Migration Runner (functions/src/...)    │
│ - Load migration files                  │
│ - Connect to Firestore                  │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ Check Current Version                   │
│ Query: _migrations/migration_status     │
│ Current: 002                            │
│ Pending: 003+                           │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ Execute Migration UP Functions          │
│ - 003_init_bookings.up()                │
│ - Batch write to Firestore              │
│ - Update version to 003                 │
└──────────────┬──────────────────────────┘
               ↓
        ✅ Done!
        
Migration_status now:
{
  version: 3,
  lastMigration: "003_init_bookings",
  timestamp: "2026-02-01T12:00:00Z"
}
```

---

## 📁 File Organization

```
firebase/
│
├── 📄 README_MIGRATIONS.md          ← You are here
├── 📄 MIGRATIONS.md                 ← Setup guide
├── 📄 WORKFLOW.md                   ← Daily usage
├── 📄 QUICK_REFERENCE.md            ← Command cheat sheet
├── 📄 SETUP_COMPLETE.md             ← Overview
│
├── migrations/                       ← Migration scripts
│   ├── 001_init_users.ts
│   ├── 002_init_styles.ts
│   ├── 003_*.ts                     ← You create these
│   ├── TEMPLATE.ts                  ← Copy for new migrations
│   └── index.ts                     ← Exports all migrations
│
├── functions/                        ← Firebase Cloud Functions
│   ├── src/
│   │   ├── migrations.ts            ← Core migration engine
│   │   ├── cli.ts                   ← Command-line interface
│   │   └── index.ts                 ← Deployed functions
│   ├── package.json
│   └── tsconfig.json
│
├── firestore.rules                  ← Security rules
├── firestore.indexes.json           ← Database indexes
├── firebase.json                    ← Firebase config
└── .gitignore                       ← Excludes secrets
```

---

## 🎯 Data Flow Example: User Signup

```
┌─────────────────────────────────────────┐
│ 1. Flutter App: User Signs Up           │
│    - Email, Password, Display Name      │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 2. Firebase Auth: Creates User          │
│    - Generates UID (immutable)          │
│    - Stores credentials securely        │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 3. Firestore: Create User Document      │
│    - Doc ID = UID                       │
│    - Path: users/{uid}                  │
│    - Fields: email, displayName, role   │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│ 4. Cloud Function: Post-processing      │
│    - Send welcome email                 │
│    - Update user stats                  │
│    - Send to analytics                  │
└──────────────────┬──────────────────────┘
                   │
                   ▼
         ✅ User created & stored
```

---

## 🔐 Security Boundaries

```
┌─────────────────────────────────────────────────┐
│ Public (No Authentication)                      │
│ - Read public styles list                       │
│ - Read barber info                              │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ Authenticated User                              │
│ - Read own user document                        │
│ - Create/read own bookings                      │
│ - Access own AI generations                     │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ Barber (Admin role)                             │
│ - View all bookings for their location          │
│ - Update style pricing/details                  │
│ - Mark appointments complete                    │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ App Admin (Admin role)                          │
│ - Full access to all data                       │
│ - Run migrations                                │
│ - Manage users, barbers, locations              │
└─────────────────────────────────────────────────┘
```

---

## 📊 Collection Relationships

```
users/{userId}
    ├── Many → Many bookings
    ├── Many → Saved styles (favorites)
    └── Many → AI generations
         
styles/{styleId}
    ├── One → Many bookings (selected)
    └── One → Many AI generations (used)

bookings/{bookingId}
    ├── One → user
    ├── One → barber (user with role="barber")
    ├── One → style (hairstyle or beard)
    └── Many → payments

payments/{paymentId}
    └── One → booking

barbers/{barberId}
    ├── One → location
    ├── Many → bookings (their appointments)
    └── Many → styles (services offered)

ai_generations/{generationId}
    ├── One → user
    ├── One → hairstyle (optional)
    ├── One → beard style (optional)
    └── One → input image + result image
```

---

## ⏱️ Timeline: Your Setup

```
├─ 2024: Project starts
│  └─ Web app built (React)
│
├─ 2025: Migration to Flutter
│  ├─ Q1: Firebase setup
│  ├─ Q2: Basic auth
│  └─ Q3: Database design
│
├─ 2026: Database migrations (NOW)
│  ├─ Feb 1: Migration system installed ✅
│  ├─ Feb 2: Run first migrations
│  ├─ Feb: Add bookings, payments, etc.
│  └─ Mar: Production deployment
```

---

## 🚀 What's Next

1. **Download Service Account Key** (Firebase Console)
2. **Run first migration** (`npm run migrate:up`)
3. **Check status** (`npm run migrate:status`)
4. **Create new collections** as needed
5. **Deploy to production** with confidence

---

**Happy building! 🎉**
