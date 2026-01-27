
# Project Overview: AI Hairstyle & Beard Try-On App

## Core Value Proposition
A cross-platform mobile application built with **Flutter** that enables users to generate hyper-realistic images of themselves with different hairstyles and beard styles. The app uses AI to preserve the user's facial identity while modifying hair and facial hair based on user selection. Backend services are powered by **Firebase** (Cloud Functions, Firestore, Storage).

## User Flow
1.  **Onboarding & Capture:**
    * User signs up/logs in.
    * **Face Capture:** User uploads or takes 4 distinct photos of their face (Front, Left Profile, Right Profile, Angled) to build a consistent identity model.
2.  **Transformation Studio:**
    * User selects a target style (e.g., "Buzz Cut + Stubble", "Long Wavy Hair", "Goatee").
    * User hits "Generate".
    * App sends the 4 reference photos + style prompts to the AI backend (Firebase Cloud Functions).
3.  **Result & Interaction:**
    * User views the generated image.
    * Options to save, share, or regenerate with tweaked settings.

## Folder Structure Strategy (Monorepo)
This project uses a **Turborepo** monorepo for efficient dependency and build management:

* **Root Level:** Contains `turbo.json`, root `package.json`, and environment/config files.
* **`apps/barbcut`:** The **Flutter** mobile application (iOS, Android, Web, Desktop supported).
* **`firebase`:** Backend folder containing Cloud Functions, Firestore rules, and storage configurations. (Kept as `firebase/` at root for clarity.)

## Key Features
* **Multi-Angle Identity:** Uses 4 input photos for high-fidelity face preservation (not just a simple face swap).
* **Dual Gender Support:** Specific prompts and models tuned for both male and female styles.
* **Beard & Hair Integration:** The AI generates hair and beard together for natural blending.
* **Privacy First:** User photos are stored securely in Firebase Storage and only used for their specific generation sessions.