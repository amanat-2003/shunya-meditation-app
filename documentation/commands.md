# 🕉️ Shunya — Ready-to-Run Commands

> **Usage:** This file contains all the commands you might ever need for developing, testing, building, and deploying the Shunya app.

## Environment Variables
The app uses Google Sign-In and Supabase, which requires Client IDs. The commands below use these pre-filled environment variables:

```bash
export GOOGLE_WEB_CLIENT_ID="182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com"
export GOOGLE_IOS_CLIENT_ID="YOUR_IOS_CLIENT_ID_HERE"   # Replace when you get Apple Developer account
export APPLE_SIGN_IN_ENABLED="false"

# Reusable command payloads
DART_DEFINES="--dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID"
DART_DEFINES_IOS="$DART_DEFINES --dart-define=GOOGLE_IOS_CLIENT_ID=$GOOGLE_IOS_CLIENT_ID"
DART_DEFINES_IOS_FULL="$DART_DEFINES_IOS --dart-define=APPLE_SIGN_IN_ENABLED=$APPLE_SIGN_IN_ENABLED"
```

---

## 1. Setup & Checks

Install dependencies:
```bash
flutter pub get
```

Run static analysis:
```bash
flutter analyze
```

Run tests:
```bash
flutter test
```

---

## 2. Emulators & Simulators

List all connected devices:
```bash
flutter devices
```

List available emulators:
```bash
flutter emulators
```

Launch Android emulator (replace name with one from `flutter emulators`):
```bash
flutter emulators --launch Pixel_7_API_35
```

Boot iOS Simulator:
```bash
open -a Simulator
```

---

## 3. Run Commands

### Android Emulator & Real Device
Debug mode (hot reload enabled):
```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com
```

Specific Android device (get ID from `flutter devices`):
```bash
flutter run -d <device-id> --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com
```

Release mode (for testing production performance):
```bash
flutter run --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com
```

### iOS Simulator & Real Device
*Note: Before running on an iOS real device, open `ios/Runner.xcworkspace` in Xcode to configure your development team.*

Debug mode:
```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID_HERE
```

Specific iOS simulator:
```bash
flutter run -d "iPhone 16 Pro" --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID_HERE
```

---

## 4. Build for Production

### Android

1. Universal APK (for testing release without Play Store):
```bash
flutter build apk --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

2. App Bundle (AAB - for Google Play Console):
```bash
flutter build appbundle --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com
```
*Output: `build/app/outputs/bundle/release/app-release.aab`*

### iOS

1. Built iOS Archive (for App Store Connect):
```bash
flutter build ios --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID_HERE --dart-define=APPLE_SIGN_IN_ENABLED=false
```
*Next step: Archive in Xcode via Product > Archive > Distribute*

2. Direct IPA Export:
```bash
flutter build ipa --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID_HERE --dart-define=APPLE_SIGN_IN_ENABLED=false
```
*Output: `build/ios/ipa/shunya.ipa`*

---

## 5. Maintenance & Cleaning

Deep clean the project (fixes 90% of weird compilation errors):
```bash
flutter clean && flutter pub get
```

Deep clean iOS Cocoapods:
```bash
cd ios && pod deintegrate && pod install --repo-update && cd ..
```

Format code:
```bash
dart format lib/
```

Check dependencies for updates:
```bash
flutter pub outdated
```

---

## 6. Supabase Commands / Reference

Your Database URL is: `https://bxctadqcjxhrtajvktun.supabase.co`

Whenever you change the database schema, migrate your database by running the script in:
`supabase/migrations/001_create_tables.sql`
inside the [Supabase SQL Editor](https://supabase.com/dashboard/project/bxctadqcjxhrtajvktun/sql).
