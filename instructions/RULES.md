# Development Rules & Coding Guidelines

## 1. Package Management Enforcement
* **RULE:** You must use `npm` for all installation commands.
* **FORBIDDEN:** Do not generate commands using `yarn`, `pnpm`, or `bun`.
* **Monorepo:** Use npm workspaces. To install a package for the mobile app specifically, use: `npm install <package> -w apps/barbcut`.

## 2. Monorepo & Turborepo Usage
* **Management:** Use Turborepo for running scripts.
    * Example: `npx turbo run dev` to start all apps.
    * Example: `npx turbo run build` to build.
* **Folder Structure Strictness:**
    * All mobile application code **MUST** reside strictly inside `apps/barbcut`.
    * All Firebase backend code (Functions, Rules) **MUST** reside strictly inside `firebase`.
    * Do not create files at the root level unless they are global config files (e.g., `.gitignore`, `turbo.json`).

## 3. Version Control Strategy (Git)
* **COMMIT OFTEN:** You must commit your changes after **every single logical step** or completed task.
* **Message Format:** Use semantic commit messages (e.g., `feat: setup firebase auth`, `fix: correct layout padding`, `chore: update dependencies`).
* **Process:**
    1. Implement a small feature.
    2. Verify it works.
    3. Run `git add .` and `git commit -m "..."`.
    4. Proceed to the next step.

## 4. Secret Management
* **NEVER** hardcode API keys or secrets in the code.
* All secrets (Firebase Config, Replicate API Tokens) must be loaded from a `.env` file.
* Reference secrets using `process.env.VARIABLE_NAME`.
* Ensure `.env` is added to `.gitignore`.

## 5. Coding Style (React Native)
* Use **Functional Components** with Hooks only. No Class components.
* Use strict **TypeScript** interfaces for all props and state.
* Avoid inline styles where possible; use defined style constants or Tailwind classes.
* **Error Handling:** Every async operation (API call, Firebase interaction) must be wrapped in `try/catch` blocks with user-visible error feedback.

## 6. AI Implementation Rules
* **Privacy:** When uploading user photos to Storage, store them in a restricted bucket path: `users/{userId}/source_photos/`.
* **Generation Logic:** The mobile app should NOT call the AI API directly. It must call a Firebase Cloud Function (`generateHairstyle`). The Cloud Function then handles the secure call to the AI provider.

## 7. Vibe Coding Behavior
* When asked to implement a feature, first check the folder structure context.
* If modifying the backend, output the code for `firebase/functions/index.ts`.
* If modifying the frontend, output the code for `apps/barbcut/src/...`.
* Keep components small and modular.