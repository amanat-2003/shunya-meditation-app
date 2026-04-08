# Shunya Deployment & Publishing Guide

This document aggregates every essential step required to build, sign, and publish the Shunya application to both the **Google Play Store (Android)** and the **App Store (iOS)** natively. 

## 1. App Versioning (Pre-requisite for both)
Before compiling **any** release, you must bump the application version natively so that the App Stores do not reject your binary for matching an existing build number.
1. Open the root `pubspec.yaml`.
2. Find the version string (e.g., `version: 1.0.0+1`).
3. Increment the semantic version or the build number.
   - Example to bump the build number: `version: 1.0.0+2`
   - Example to bump the semantic version: `version: 1.1.0+3`
4. In your terminal, run: `flutter clean` then `flutter pub get` to enforce the new version across the native folders.

---

## 2. Google Play Store (Android)

### App Signing Requirements
To upload an Android App, it must be signed by a release Keystore (`.jks`). We have configured the gradle to do this organically without exposing secrets.
1. Ensure your `android/app/upload-keystore.jks` exists locally on your machine.
2. Ensure you have the `android/key.properties` configuration file locally on your machine. **(These files should NEVER be pushed to Git)**.
   *Example `key.properties` structure:*
   ```ini
   storePassword=<YourPassword>
   keyPassword=<YourPassword>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

### Building the Release
1. Open up your terminal in the root Shunya folder.
2. Run the specialized format required by Google Play (the App Bundle):
   ```bash
   flutter build appbundle
   ```
3. Once compiled, your artifact exists precisely at:
   `build/app/outputs/bundle/release/app-release.aab`

### Play Store Upload
1. Log into the Google Play Developer Console.
2. Navigate to your app `Shunya`.
3. Scroll the left sidebar mapping to **Release > Production** (or Internal Testing).
4. Click **Create new release**.
5. Drag and drop your newly built `app-release.aab` into the App bundles container.
6. Outline your release notes and press **Save**, then **Review release**, and **Rollout**.

---

## 3. Apple App Store (iOS)

### App Signing Requirements
Unlike Android, Apple utilizes fully managed remote certificates attached to your Developer Profile and Xcode.
1. Ensure you have accepted all Developer Agreements inside your Apple Developer Account (`developer.apple.com`).
2. You must have Xcode installed on your Mac.
3. Open the iOS module inside Xcode natively by typing this in your terminal:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. Click the `Runner` project on the left column -> `Signing & Capabilities`.
5. Check the box that says **"Automatically manage signing"**.
6. Select your Apple Developer Account under the **Team** dropdown. Ensure your Bundle Identifier perfectly matches `com.anamiapps.shunya` (or whatever ID you configured Apple to accept).

### Building the Release
Apple enforces that production uploads occur as an IPA Archive securely created through Xcode. You can orchestrate the heavy lifting using Flutter.
1. Run the specialized build command in your terminal:
   ```bash
   flutter build ipa
   ```
2. This runs a complex packaging engine and automatically spits out an `.xcarchive` file.

### App Store Connect Upload
1. You can manually upload the IPA, but the industry standard is right through Xcode.
2. After running `flutter build ipa`, open Xcode.
3. In the top Menu Bar, click **Window -> Organizer**.
4. You will explicitly see your latest Shunya build waiting under the **Archives** tab!
5. Select the build, click **Distribute App...** on the right side.
6. Follow the flow (Select App Store Connect -> Upload -> Next).
7. Once successfully uploaded securely to Apple's endpoints, go to your Browser and load `appstoreconnect.apple.com`.
8. Check the **TestFlight** tab to see your new build magically processing! Once processed, you can distribute it to Production.

---

## 4. Helpful Reminders

- **Supabase Authentication**: If you change the Bundle ID on iOS or Android, you *must* duplicate those edits inside the Supabase Developer Dashboard under Authentication -> URL Configuration so OAuth Sign-in redirects aren't blocked!
- **Google Cloud Auth**: If the Bundle ID changes, or you switch to a new laptop/keystore fingerprint, Google Sign-in will completely fail unless you update your OAuth 2.0 Credentials Dashboard manually inside Google Cloud Console.
