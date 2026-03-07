# Barbcut (Flutter)

Flutter app for Barbcut – clean architecture, Firebase (Auth, Firestore, Storage).

## Prerequisites

- Flutter SDK
- `.env` file in this directory (see project root or `.env.example` for required vars)

## Run

```bash
flutter pub get
flutter run
```

## Architecture

- **Features**: auth, favourites, home (styles, tab categories), history, products, profile, AI generation
- **Layers**: domain (entities, repo interfaces, use cases), data (datasources, repo impls), presentation (Bloc/Cubit, pages, widgets)
- **DI**: GetIt in `lib/core/di/service_locator.dart`
- **Firebase**: used only inside data-layer datasources; views and main use repositories/use cases only

Full documentation: [../../docs/README.md](../../docs/README.md)
