# Barb Cut Monorepo

Monorepo for the Barbcut app and Firebase backend (Turborepo).

## Structure

- **apps/barbcut** – Flutter app (clean architecture, Firebase Auth/Firestore/Storage)
- **firebase/** – Firebase config, rules, and tooling
- **image-generation/** – AI image generation service (ComfyUI)
- **docs/** – Project documentation ([docs/README.md](docs/README.md))

## Prerequisites

- Flutter SDK (see [flutter.dev](https://flutter.dev))
- Node.js (for Turborepo)
- Firebase CLI (optional, for emulators)
- `.env` in `apps/barbcut/` with any required keys (see `.env.example` if present)

## Run the Flutter app

```bash
cd apps/barbcut
flutter pub get
flutter run
```

Use `flutter run -d <device-id>` to pick a device. Run `flutter doctor` if you have setup issues.

## Monorepo scripts (root)

- `npm run dev` – Turborepo dev (if configured for this app)
- `npm run build` – Turborepo build
- `npm run lint` – Lint
- `npm run clean` – Clean

Flutter is typically run directly from `apps/barbcut` as above.

## Architecture (Flutter app)

The app uses clean architecture per feature:

- **Domain**: entities, repository interfaces, use cases
- **Data**: datasources (remote/local), repository implementations, models
- **Presentation**: Bloc/Cubit, pages, widgets

Firebase is accessed only via injectable datasources and repositories (no `FirebaseAuth`/`FirebaseFirestore` in views or main). Dependency injection is done with GetIt in `core/di/service_locator.dart`.
