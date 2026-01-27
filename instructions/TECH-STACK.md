# Tech Stack & Dependencies

## Monorepo & Build Tools
* **Manager:** **Turborepo** (for task orchestration across Flutter and Firebase).
* **Package Managers:**
	* **Flutter/Dart:** Use `flutter pub` for all Dart/Flutter dependencies.
	* **Firebase Backend:** Use `npm` for Node.js Cloud Functions and backend dependencies in `firebase/`.
* **Workspaces:** npm workspaces enabled in root `package.json` for backend only.

## Core Frameworks
* **Mobile:** Flutter (Dart). Workspace: `apps/barbcut`.
* **Language:** Dart (null safety enabled).

## Backend & Cloud (Firebase)
* **Platform:** Firebase (Blaze Plan required for external AI API calls).
* **Auth:** Firebase Authentication.
* **Database:** Cloud Firestore.
* **Storage:** Cloud Storage for Firebase.
* **Serverless:** Cloud Functions for Firebase (Node.js runtime).

## AI Generation Pipeline
* **Provider:** Replicate API or OpenAI DALL-E 3.
* **Model Strategy:** SDXL with IP-Adapter (InstantID) or similar for identity preservation.

## State Management & Navigation (Flutter)
* **State:** Provider, Riverpod, or Bloc (choose one; Provider is default for simple apps).
* **Navigation:** Flutter's built-in Navigator 2.0 or go_router.

## Security
* **Secrets:** `.env` file at the root for backend, and build-time environment variables for Flutter (e.g., using --dart-define). Never commit secrets to version control.