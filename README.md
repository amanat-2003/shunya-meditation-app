# 🕉️ Shunya — Minimalist Haptic Meditation & Jaap Tracker

A "Screen-Off" meditation experience built with Flutter & Supabase. The app uses a pitch-black UI to minimize light pollution. Users interact via taps on the screen, receiving haptic feedback (vibration) for each count.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Secrets & Keys](#getting-secrets--keys)
- [Project Setup](#project-setup)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Building for Release](#building-for-release)
- [Deployment](#deployment)
- [Updating the App](#updating-the-app)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Tool | Version | Check Command |
|------|---------|--------------|
| Flutter SDK | 3.41+ | `flutter --version` |
| Dart SDK | 3.11+ | `dart --version` |
| Android Studio | Latest | Required for Android SDK & emulators |
| Xcode | 16+ | `xcode-select --print-path` (macOS only) |
| CocoaPods | Latest | `pod --version` (macOS only) |
| Git | Latest | `git --version` |

### Verify Your Setup

```bash
flutter doctor -v
```

All checkmarks should be green for Android and iOS toolchains.

---

## Getting Secrets & Keys

### 1. Supabase Project

The app uses Supabase for authentication and cloud storage.

| Key | Where to Find |
|-----|--------------|
| **Project URL** | [Supabase Dashboard](https://supabase.com/dashboard) → Your Project → Settings → API → Project URL |
| **Anon Key** | Same page → `anon` / `public` key |

These are already configured in `lib/main.dart`. If you need to change them:

```dart
// lib/main.dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

> ⚠️ **Security Note**: For production, move these to `--dart-define` env vars or a `.env` file (excluded from git). Never commit real keys to a public repo.

### 2. Google Sign-In (OAuth)

You need **two** sets of credentials:

#### A. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select existing)
3. Go to **APIs & Services → Credentials**
4. Click **Create Credentials → OAuth 2.0 Client IDs**

**For Android:**
- Application type: **Android**
- Package name: `com.shunya.shunya`
- SHA-1 fingerprint:
  ```bash
  # Debug keystore (for development)
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:"

  # Release keystore (for production) — see Signing section below
  keytool -list -v -keystore /path/to/release.keystore -alias your-alias
  ```

**For iOS:**
- Application type: **iOS**
- Bundle ID: `com.shunya.shunya`

**For Web (required for Supabase OAuth flow):**
- Application type: **Web application**
- Authorized redirect URIs: `https://bxctadqcjxhrtajvktun.supabase.co/auth/v1/callback`

#### B. Supabase Google Provider Setup

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) → Auth → Providers → Google
2. Enable Google provider
3. Enter your **Web Client ID** and **Web Client Secret** from Google Cloud Console
4. Save

#### C. Summary of Client IDs You'll Need

| Platform | Client ID Type | Where It Goes |
|----------|---------------|---------------|
| Android | Android OAuth Client ID | Auto-detected via SHA-1 |
| iOS | iOS OAuth Client ID | `--dart-define=GOOGLE_IOS_CLIENT_ID=...` |
| Web/Supabase | Web OAuth Client ID | `--dart-define=GOOGLE_WEB_CLIENT_ID=...` and Supabase Dashboard |

### 3. Apple Sign-In (Optional)

Only needed when building for iOS App Store:

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) → Identifiers
2. Enable **Sign in with Apple** for your App ID (`com.shunya.shunya`)
3. Create a **Services ID** for web-based redirect
4. Configure the redirect URL in Supabase Dashboard → Auth → Providers → Apple
5. Pass the flag when building:
   ```bash
   flutter build ios --dart-define=APPLE_SIGN_IN_ENABLED=true
   ```

### 4. Database Migration

Run the SQL migration in your Supabase SQL Editor:

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) → SQL Editor
2. Open and run: `supabase/migrations/001_create_tables.sql`

This creates:
- `meditation_sessions` table (with RLS policies)
- `user_settings` table (with RLS policies)
- Required indexes

---

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/amanat-2003/shunya-meditation-app.git
cd shunya-meditation-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter analyze   # Should show: No issues found!
flutter test      # Should pass
```

---

## Running the App

### Environment Variables

All runs require the Google Web Client ID. Create a convenience script or use `--dart-define`:

```bash
# Required
--dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id

# Optional (iOS only)
--dart-define=GOOGLE_IOS_CLIENT_ID=your-ios-client-id

# Optional (enable Apple Sign-In)
--dart-define=APPLE_SIGN_IN_ENABLED=true
```

---

### Android Emulator

#### Setup Emulator

```bash
# List available emulators
flutter emulators

# Create a new emulator (if none exist)
flutter emulators --create --name Pixel_7_API_35

# Launch emulator
flutter emulators --launch Pixel_7_API_35

# OR use Android Studio:
# Android Studio → Device Manager → Create Virtual Device → Pixel 7 → API 35 → Finish → ▶
```

#### Run on Emulator

```bash
# Check device is connected
flutter devices

# Run
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id
```

> **Tip**: Google Sign-In works on the emulator but may require Google Play Services. Use a "Google APIs" system image when creating the emulator.

---

### Android Real Device

1. **Enable Developer Mode** on your phone:
   - Settings → About Phone → Tap "Build Number" 7 times
2. **Enable USB Debugging**:
   - Settings → Developer Options → USB Debugging → On
3. **Connect via USB** and authorize the computer on the phone
4. **Verify**:
   ```bash
   flutter devices
   # Should list your device
   ```
5. **Run**:
   ```bash
   flutter run \
     --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id
   ```

> **Wireless Debugging (Android 11+)**:
> ```bash
> # On the device: Developer Options → Wireless Debugging → Pair
> adb pair <ip>:<port>    # Enter pairing code
> adb connect <ip>:<port> # Connect
> ```

---

### iOS Simulator

#### Setup Simulator

```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator
open -a Simulator
# Then: File → Open Simulator → iPhone 16 Pro
```

#### Run on Simulator

```bash
# First time: install CocoaPods dependencies
cd ios && pod install && cd ..

# Run
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id \
  --dart-define=GOOGLE_IOS_CLIENT_ID=your-ios-client-id
```

> ⚠️ **Note**: Google Sign-In does NOT work on the iOS Simulator (no Google services). Test auth flow on a real device. On the simulator, you can test all other features.

---

### iOS Real Device

1. **Connect iPhone via USB** (or use wireless debugging in Xcode)
2. **Open Xcode**: `open ios/Runner.xcworkspace`
3. **Select your team**:
   - Runner → Signing & Capabilities → Team → Select your Apple Developer account
4. **Trust the developer** on the iPhone:
   - Settings → General → VPN & Device Management → Trust your developer certificate
5. **Run**:
   ```bash
   flutter run \
     --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id \
     --dart-define=GOOGLE_IOS_CLIENT_ID=your-ios-client-id
   ```

---

## Testing

### Static Analysis

```bash
flutter analyze
```

### Unit Tests

```bash
flutter test
```

### Run on Multiple Devices

```bash
# List all connected devices
flutter devices

# Run on a specific device
flutter run -d <device-id> \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id
```

### Manual Test Checklist

| Feature | What to Test |
|---------|-------------|
| **Auth** | Google Sign-In → lands on Dashboard |
| **Dashboard** | Quote displays, goal progress shows, stats cards render |
| **Meditation** | Tap counting, haptic feedback, timer runs, screen stays black |
| **Exit Gesture** | Long press 3 sec → progress bar → release → session ends |
| **Failsafe Hint** | Tap 5+ times rapidly → hint appears at 10% opacity |
| **Auto-Save** | Kill app mid-session → relaunch → pending session prompt |
| **Offline Sync** | Airplane mode → meditate → disable airplane → sessions sync |
| **Settings** | Change goal, haptic interval, audio toggle |
| **Stats** | Bar chart shows weekly data, heatmap shows monthly |
| **Sign Out** | Confirmation dialog → signs out → redirects to login |

---

## Building for Release

### Android APK (Universal)

```bash
flutter build apk --release \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS Build

```bash
flutter build ios --release \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id \
  --dart-define=GOOGLE_IOS_CLIENT_ID=your-ios-client-id \
  --dart-define=APPLE_SIGN_IN_ENABLED=true
```

Then archive in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Product → Archive
3. Distribute App → App Store Connect

---

### Android Signing for Release

#### 1. Generate a keystore (one-time)

```bash
keytool -genkey -v \
  -keystore ~/shunya-release.keystore \
  -alias shunya \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> 🔒 **NEVER commit the keystore file to git.** Store it securely (password manager, etc.)

#### 2. Create `android/key.properties`

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=shunya
storeFile=/Users/you/shunya-release.keystore
```

> Add `android/key.properties` to `.gitignore` (already added below)

#### 3. Update `android/app/build.gradle.kts`

Add before `android {`:
```kotlin
val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}
```

Inside `android {`, add:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

Update `buildTypes`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

---

## Deployment

### Google Play Store

1. **Create App** in [Google Play Console](https://play.google.com/console)
2. **Build AAB**: `flutter build appbundle --release --dart-define=...`
3. **Upload AAB**: Play Console → Release → Production → Create Release → Upload
4. **Fill Store Listing**: Screenshots, description, category (Health & Fitness)
5. **Content Rating**: Complete the questionnaire
6. **Pricing**: Set as Free
7. **Review**: Submit for review (usually 1–7 days)

### Apple App Store

1. **Create App** in [App Store Connect](https://appstoreconnect.apple.com)
2. **Archive in Xcode**: Product → Archive → Distribute → App Store Connect
3. **Fill App Information**: Screenshots (6.7" and 5.5"), description, keywords
4. **App Review Information**: Provide demo credentials if needed
5. **Submit for Review**: Usually 1–3 days

### Versioning

Update version in `pubspec.yaml` before each release:

```yaml
version: 1.0.1+2
#        ^^^^^ ^^
#        |     |
#        |     +-- Build number (increment every release)
#        +-------- Version name (semver: major.minor.patch)
```

---

## Updating the App

### Adding New Features

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Implement changes in the appropriate `lib/features/` directory
3. Run `flutter analyze` and `flutter test`
4. Create a pull request

### Updating Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update to latest compatible versions
flutter pub upgrade

# Update to latest major versions (⚠️ may break things)
flutter pub upgrade --major-versions
```

### Database Migrations

For schema changes:
1. Create a new file: `supabase/migrations/002_your_change.sql`
2. Run it in the Supabase SQL Editor
3. Update the corresponding Dart models and repositories
4. If you change Hive models, increment the `typeId` or handle migration in code

### Updating Flutter SDK

```bash
flutter upgrade
flutter pub get
cd ios && pod install && cd .. # For iOS
flutter analyze  # Check for deprecations
```

---

## Architecture

```
lib/
├── main.dart                          # Entry: Hive + Supabase init
├── app.dart                           # MaterialApp.router + theme
├── core/
│   ├── constants/app_constants.dart   # Timing, quotes, config
│   ├── theme/app_theme.dart           # Pitch-black dark theme
│   └── router/app_router.dart         # GoRouter with auth guard
├── features/
│   ├── auth/                          # Google Sign-In + Supabase
│   ├── meditation/                    # Core meditation logic & UI
│   │   ├── data/
│   │   │   ├── models/               # MeditationSession (Hive)
│   │   │   ├── repositories/         # Local + remote data access
│   │   │   └── services/             # Haptic, Audio, Meditation
│   │   ├── presentation/screens/     # PreSession, Meditation, Summary
│   │   └── providers/                # Riverpod state
│   ├── dashboard/                     # Home screen + Stats + Charts
│   ├── settings/                      # User preferences
│   └── sync/                          # Offline-first sync engine
└── shared/widgets/                    # Bottom nav shell
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Riverpod** over Bloc | Simpler API, better for reactive providers and dependency injection |
| **Hive** over SQLite | Faster for key-value style session storage, zero native dependencies |
| **Manual Hive adapters** | Avoids `hive_generator` / `build_runner` version conflicts |
| **GoRouter** | Declarative routing with auth redirect guards |
| **Custom heatmap** over `fl_heatmap` | More control over the calendar grid styling |
| **Offline-first** | Users meditate in airplane mode; local storage is the source of truth |

---

## Troubleshooting

### "No supported devices connected"

The project is configured for **Android and iOS only**. You need either:
- An Android emulator / device
- An iOS simulator / device

```bash
# See what platforms are supported
flutter devices

# If you see macOS/Chrome but not Android/iOS,
# start an emulator or connect a device
flutter emulators --launch <emulator-name>
```

### Google Sign-In Fails

1. ✅ Verify SHA-1 fingerprint matches Google Cloud Console
2. ✅ Verify Web Client ID is passed with `--dart-define`
3. ✅ Verify Google is enabled in Supabase Auth Providers
4. ✅ Verify redirect URL in Google Cloud Console matches Supabase callback

### iOS Build Fails — CocoaPods

```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter run
```

### Hive Box Corruption

If you get Hive errors after a model change:

```bash
# On the device, clear app data:
# Android: Settings → Apps → Shunya → Clear Data
# iOS: Delete and reinstall the app
```

### Build Takes Too Long

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

---

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `GOOGLE_WEB_CLIENT_ID` | ✅ Yes | `''` | Google OAuth Web Client ID |
| `GOOGLE_IOS_CLIENT_ID` | iOS only | `''` | Google OAuth iOS Client ID |
| `APPLE_SIGN_IN_ENABLED` | No | `false` | Enable Apple Sign-In button |

Pass via `--dart-define`:
```bash
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxx \
  --dart-define=GOOGLE_IOS_CLIENT_ID=yyy \
  --dart-define=APPLE_SIGN_IN_ENABLED=true
```

---

## License

This project is private. All rights reserved.
