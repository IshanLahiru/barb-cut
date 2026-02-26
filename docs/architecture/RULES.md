
# Development Rules & Coding Guidelines (Flutter + Firebase)

## 1. Package Management Enforcement
* **Flutter App:** Use `flutter pub` for all Dart/Flutter dependencies. Do not use npm/yarn/pnpm for Flutter code.
* **Firebase Backend:** Use `npm` for Node.js Cloud Functions and backend dependencies inside `firebase/` only.
* **Monorepo:** Use Turborepo for orchestrating builds and scripts across the monorepo.

## 2. Monorepo & Turborepo Usage
* **Management:** Use Turborepo for running scripts.
    * Example: `npx turbo run build` to build all apps.
    * Example: `npx turbo run lint` to lint all codebases.
* **Folder Structure Strictness:**
    * All Flutter app code **MUST** reside strictly inside `apps/barbcut`.
    * All Firebase backend code (Functions, Rules) **MUST** reside strictly inside `firebase`.
    * Do not create files at the root level unless they are global config files (e.g., `.gitignore`, `turbo.json`).

## 3. Version Control Strategy (Git)
* **COMMIT OFTEN:** Commit changes after every logical step or completed task.
* **Message Format:** Use semantic commit messages (e.g., `feat: add login screen`, `fix: image upload bug`, `chore: update dependencies`).
* **Process:**
    1. Implement a small feature.
    2. Verify it works (run on simulator/emulator or test backend).
    3. Run `git add .` and `git commit -m "..."`.
    4. Proceed to the next step.

## 4. Secret Management
* **NEVER** hardcode API keys or secrets in code.
* All secrets (Firebase Config, Replicate API Tokens) must be loaded from a `.env` file or via Flutter's build-time environment variables.
* For backend, use `process.env.VARIABLE_NAME` in Node.js Cloud Functions.
* Ensure `.env` is added to `.gitignore`.

## 5. Coding Style (Flutter/Dart)
* Use **StatelessWidget** and **StatefulWidget** as appropriate. Prefer small, composable widgets.
* Use Dart's strong typing and null safety.
* Use `const` constructors where possible for performance.
* Use `ThemeData` and centralized style/theme management.
* **Error Handling:** All async operations (API calls, Firebase interaction) must use `try/catch` with user-visible error feedback (e.g., SnackBar, dialogs).

## 6. AI Implementation Rules
* **Privacy:** When uploading user photos to Storage, store them in a restricted bucket path: `users/{userId}/source_photos/`.
* **Generation Logic:** The Flutter app must NOT call the AI API directly. It must call a Firebase Cloud Function (e.g., `generateHairstyle`). The Cloud Function then handles the secure call to the AI provider.

## 7. Coding Behavior
* When asked to implement a feature, first check the folder structure context.
* If modifying the backend, update code in `firebase/functions/`.
* If modifying the frontend, update code in `apps/barbcut/lib/`.
* Keep widgets and functions small and modular.