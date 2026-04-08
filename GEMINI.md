# Shunya Project Context (AI Instructions)

> **AI Assistant Note:** Read this document immediately upon starting a new chat context. This file contains the architectural rules, deployment parameters, and critical context for the Shunya backend and frontend.

## 1. Project Overview
- **App Name:** Shunya
- **Description:** A minimalist, offline-first, dark-mode meditation and Jaap (mantra) tracker.
- **Tech Stack:** Flutter, Riverpod (State Management), Hive (Local DB/Offline-First), Supabase (Auth & Cloud Database).

## 2. Core Identifiers & Configurations
- **Android Package Name / Application ID:** `com.anamiapps.shunya`
- **iOS Bundle Identifier:** `com.anamiapps.shunya`
- **Deep Link Schema:** `com.anamiapps.shunya://`
- **Google Cloud Auth:** We use OAuth 2.0 Client IDs for Android & Web. The Web Client ID must be passed during build using `--dart-define=GOOGLE_WEB_CLIENT_ID=<id>`.

## 3. Architecture & Strict Rules
1. **Offline-First Mandate:** Shunya operates fundamentally offline. Data is saved natively to `Hive` boxes (`meditation_sessions`, `user_settings`, `app_state`).
2. **Cloud Sync:** Do *not* write directly to Supabase during normal session updates. Instead, rely on the discrete background sync architecture (`sync_providers.dart`) triggered manually or periodically.
3. **State Management:** Strict usage of modern `Riverpod` (Annotations with `@riverpod`). Prevent cross-account data bleeding by running explicit `ref.invalidate()` and Hive `box.clear()` routines inside `AuthRepository.signOut()`.
4. **UI/UX Aesthetics:** The app relies on "Pure Dark Mode" and a custom "Bright Mode" in the meditation tracker, disabling screen dimming and silencing prompts based strictly on the user's settings. 

## 4. Deployment Pipeline
- **Google Play:** Uses Android App Bundle (`app-release.aab`).
- **Release Key:** Signed exclusively utilizing the local secure keystore (`upload-keystore.jks`).
- **Build Command:** `flutter build appbundle --release --dart-define=GOOGLE_WEB_CLIENT_ID=...`
- *Never push keystore files or passwords into the Git repository. They are explicitly blocked in `.gitignore`.*
