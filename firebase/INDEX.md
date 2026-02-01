# 📚 Firebase Documentation Index

Welcome! This folder contains a **production-ready Firestore migration system**. Here's your guide:

---

## 🎯 Start Here

### New to migrations?
**Read:** [README_MIGRATIONS.md](./README_MIGRATIONS.md)
- Overview of what was set up
- Quick 3-step getting started guide
- Key files explained

### Want to understand the system?
**Read:** [ARCHITECTURE.md](./ARCHITECTURE.md)
- System diagrams
- Data flow examples
- Collection relationships

---

## 📖 Full Documentation

### Setup & Configuration
- **[MIGRATIONS.md](./MIGRATIONS.md)** - Complete setup guide, environment variables, troubleshooting

### Daily Workflow
- **[WORKFLOW.md](./WORKFLOW.md)** - How to use migrations daily, best practices, common scenarios

### Quick Reference
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Command cheat sheet, file reference, quick FAQ

---

## 🎓 Learning Path

```
1. README_MIGRATIONS.md      ← Start here (10 min)
   └─ Understand what you have

2. SETUP_COMPLETE.md         ← Overview (5 min)
   └─ See what was installed

3. ARCHITECTURE.md           ← Understand the system (10 min)
   └─ Learn how it works

4. MIGRATIONS.md             ← Get technical (15 min)
   └─ Learn all options

5. WORKFLOW.md               ← Learn by doing (20 min)
   └─ Real-world examples

6. QUICK_REFERENCE.md        ← Keep handy (reference)
   └─ Quick lookups while coding
```

---

## 🚀 Quick Start Commands

```bash
# Check status
npm run migrate:status

# Run pending migrations
npm run migrate:up

# Rollback last migration
npm run migrate:down
```

---

## 📁 What's Available

### Migrations (Already Created)
- ✅ **001_init_users.ts** - User collection
- ✅ **002_init_styles.ts** - Style data

### Your Next Migrations
- ⬜ **003_init_bookings.ts** - Booking system
- ⬜ **004_init_payments.ts** - Payments
- ⬜ **005_init_ai_generations.ts** - AI image tracking
- ⬜ *Add more as needed*

### Tools
- 🔧 **functions/src/migrations.ts** - Migration engine
- 🔧 **functions/src/cli.ts** - Command-line interface

---

## ✅ Prerequisites

Before you start:
- [ ] Download Firebase Service Account Key
- [ ] Save as `firebase/serviceAccountKey.json`
- [ ] Set `export GOOGLE_APPLICATION_CREDENTIALS=...`
- [ ] Run `npm install` in firebase directory

---

## 🎯 Your Next Steps

1. **Read** [README_MIGRATIONS.md](./README_MIGRATIONS.md) - (10 min)
2. **Download** Service Account Key from Firebase Console
3. **Run** `npm run migrate:status`
4. **Explore** the migration files: `migrations/001_*.ts`
5. **Create** `003_init_bookings.ts` for your next collection

---

## 📞 Quick Navigation

| Need | See |
|------|-----|
| Getting started | [README_MIGRATIONS.md](./README_MIGRATIONS.md) |
| System overview | [ARCHITECTURE.md](./ARCHITECTURE.md) |
| How to use | [WORKFLOW.md](./WORKFLOW.md) |
| Commands | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) |
| Setup details | [MIGRATIONS.md](./MIGRATIONS.md) |
| What's installed | [SETUP_COMPLETE.md](./SETUP_COMPLETE.md) |

---

## 💡 Key Concepts

### Migration
A versioned change to your database schema (create collection, add fields, seed data, etc.)

### Version Tracking
Stored in `_migrations/migration_status` - Firebase knows which migrations have run

### Rollback
Each migration has a `down()` function to undo changes if something goes wrong

### Batch Operations
Multiple writes grouped together for safety and performance

### Environment
Controlled by `GOOGLE_APPLICATION_CREDENTIALS` variable

---

## 🔐 Security Reminders

- ✅ Never commit `serviceAccountKey.json`
- ✅ Keep credentials in environment variables only
- ✅ Use `firestore.rules` for runtime security
- ✅ Each migration is tracked and reversible

---

## 🎉 Ready?

Pick one:
- 👉 **Just want to get started?** → [README_MIGRATIONS.md](./README_MIGRATIONS.md)
- 👉 **Want to understand it?** → [ARCHITECTURE.md](./ARCHITECTURE.md)
- 👉 **Need a command?** → [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
- 👉 **Ready to code?** → [WORKFLOW.md](./WORKFLOW.md)

---

**Made with ❤️ for smooth database management**
