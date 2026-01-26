# Project Overview: AI Hairstyle & Beard Try-On App

## Core Value Proposition
A mobile application that allows male and female users to generate hyper-realistic images of themselves featuring different hairstyles and beard styles. The core technology uses AI to preserve the user's facial identity while modifying hair and facial hair based on user selection.

## User Flow
1.  **Onboarding & Capture:**
    * User signs up/logs in.
    * **Face Capture:** User uploads or takes 4 distinct photos of their face (Front, Left Profile, Right Profile, Angled) to build a consistent identity model.
2.  **Transformation Studio:**
    * User selects a target style (e.g., "Buzz Cut + Stubble", "Long Wavy Hair", "Goatee").
    * User hits "Generate".
    * App sends the 4 reference photos + style prompts to the AI backend.
3.  **Result & Interaction:**
    * User views the generated image.
    * Options to save, share, or regenerate with tweaked settings.

## Folder Structure Strategy (Monorepo)
The project is a **Turborepo** monorepo to manage dependencies and build pipelines efficiently:
* **Root Level:** Contains `turbo.json`, root `package.json`, and `.env` secrets.
* **`apps/mobile`:** The React Native (Expo) application.
* **`packages/firebase`:** (Renamed from just 'firebase' to fit standard monorepo structure, or kept as root `firebase` folder if preferred, but `packages/` is standard for Turbo). *For this specific request, we will keep the user's preference of a specific folder if distinct, but typically Turbo expects workspaces.*
    * **Adjustment:** We will treat the root `firebase` folder as a workspace or standalone backend folder as requested.
* **`apps/mobile`:** Contains all React Native code.
* **`firebase`:** Contains Cloud Functions, Firestore rules, and storage configurations.

## Key Features
* **Multi-Angle Identity:** Uses 4 input photos for high-fidelity face preservation (not just a simple face swap).
* **Dual Gender Support:** Specific prompts and models tuned for both male and female styles.
* **Beard & Hair Integration:** The AI must generate hair and beard simultaneously to ensure they blend naturally on the face.
* **Privacy First:** User photos are stored securely and only used for their specific generation sessions.