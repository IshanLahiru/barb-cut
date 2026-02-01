# Firebase Migration System - Quick Reference

## 📋 Command Cheat Sheet

```bash
# Check migration status
npm run migrate:status

# Run all pending migrations
npm run migrate:up

# Rollback last migration
npm run migrate:down

# Build TypeScript
npm run build

# Start local emulator
npm run serve

# Deploy functions to production
npm run deploy
```

---

## 📂 Key Files at a Glance

| File | Purpose |
|------|---------|
| `migrations/001_init_users.ts` | User collection schema |
| `migrations/002_init_styles.ts` | Styles data + samples |
| `migrations/003_*.ts` | Your next migrations |
| `functions/src/migrations.ts` | Migration runner engine |
| `functions/src/cli.ts` | CLI commands |
| `firestore.rules` | Security rules |
| `firestore.indexes.json` | Database indexes |

---

## 🔄 Typical Workflow

```
1. Check status → npm run migrate:status
2. Write migration → migrations/00X_name.ts
3. Register it → migrations/index.ts + functions/src/migrations.ts
4. Test locally → npm run serve
5. Deploy → npm run migrate:up
6. Verify → npm run migrate:status
```

---

## 🎯 Your Firestore Collections (Roadmap)

```
✅ users              (001_init_users)
✅ styles             (002_init_styles)
⬜ bookings           (003_init_bookings)
⬜ payments           (004_init_payments)
⬜ ai_generations     (005_init_ai_generations)
⬜ locations          (006_init_locations)
⬜ barbers            (007_init_barbers)
```

---

## 🛠️ Creating Migration 003 (Example: Bookings)

```bash
# 1. Copy template
cp migrations/TEMPLATE.ts migrations/003_init_bookings.ts

# 2. Edit the file (replace XXX with 003, add your logic)

# 3. Register in index.ts
echo 'export { migration as migration003InitBookings } from "./003_init_bookings";' >> migrations/index.ts

# 4. Add to functions/src/migrations.ts
# (Add import + add to MIGRATIONS array)

# 5. Run it
npm run migrate:up

# 6. Check status
npm run migrate:status
```

---

## ⚠️ Important Notes

- **DO NOT commit** `serviceAccountKey.json`
- **Always test** migrations locally first
- **Always write** a `down()` function for rollbacks
- **One change** per migration file
- **Use batch operations** for multiple writes

---

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| `GOOGLE_APPLICATION_CREDENTIALS not set` | `export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"` |
| `Migration X already exists` | Check `npm run migrate:status` |
| `Need to undo a migration` | `npm run migrate:down` |
| `Emulator won't start` | Kill process: `lsof -i :8080` then `kill -9 <PID>` |

---

## 📞 Where to Find Help

- **Setup issues?** → Read `MIGRATIONS.md`
- **How to use?** → Read `WORKFLOW.md`
- **Quick reference?** → You're reading it! 📄
- **Full setup?** → See `SETUP_COMPLETE.md`

---

**Ready to start?** Run: `npm run migrate:status`
