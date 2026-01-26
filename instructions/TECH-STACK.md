# Tech Stack & Dependencies

## Monorepo & Build Tools
* **Manager:** **Turborepo** (for task orchestration).
* **Package Manager:** **npm** ONLY. (Strictly NO Yarn, NO pnpm, NO Bun).
* **Workspaces:** npm workspaces enabled in root `package.json`.

## Core Frameworks
* **Mobile:** React Native (0.76+) with Expo. Workspace: `apps/barbcut`.
* **Language:** TypeScript (Strict mode).

## Backend & Cloud (Firebase)
* **Platform:** Firebase (Blaze Plan required for external AI API calls).
* **Auth:** Firebase Authentication.
* **Database:** Cloud Firestore.
* **Storage:** Cloud Storage for Firebase.
* **Serverless:** Cloud Functions for Firebase (Node.js runtime).

## AI Generation Pipeline
* **Provider:** Replicate API or OpenAI DALL-E 3.
* **Model Strategy:** Flux.1 or SDXL with IP-Adapter (InstantID) for identity preservation.

## State Management & Navigation
* **State:** React Context API or Zustand.
* **Navigation:** React Navigation (Stack + Tabs).

## Security
* **Secrets:** `.env` file at the root. Managed via `react-native-dotenv` or Expo's environment variable system.