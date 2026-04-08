# Publishing Shunya to the Apple App Store

This guide details the step-by-step implementation for publishing Shunya to the Apple App Store. Since you are new to this process, we will go through each prerequisite systematically. Unlike Android, Apple’s ecosystem requires an active Apple Developer Program membership ($99/year) and manual management through Xcode and App Store Connect.

## User Review Required

> [!WARNING]
> You must have an active Apple Developer Account. The standard Apple ID doesn't qualify for App Store publishing. If you haven't yet, you must enroll at [developer.apple.com](https://developer.apple.com/programs/enroll/).

> [!IMPORTANT]
> The steps below involve some actions I (the AI) can run for you on your Mac, and some actions you will need to perform in the web browser or Xcode UI due to Apple's security policies. Please read through and verify you are ready to begin.

## Expected Steps for Publishing

### Phase 1: Pre-requisites & Account Setup (User Manual Action)
1. **Enroll in the Apple Developer Program**: Make sure your Apple ID is enrolled.
2. **Accept Agreements**: Log in to [App Store Connect](https://appstoreconnect.apple.com/) and accept any pending legal or developer agreements.
3. **Register App ID**: We will verify that `com.anamiapps.shunya` is registered on your Apple Developer portal.
4. **Create App in App Store Connect**: You will need to create a new App entry on App Store Connect and assign the `com.anamiapps.shunya` Bundle ID to it.

### Phase 2: Xcode Signing & Capabilities (AI & User Action)
1. I will open your iOS workspace in Xcode (`open ios/Runner.xcworkspace`).
2. You will need to select the **Runner** target, navigate to **Signing & Capabilities**.
3. You will check **Automatically manage signing** and select your Team (your personal developer name) from the drop-down. 
4. This action provisions the certificate and profile automatically.

### Phase 3: Building the Archive (AI Action)
1. I will trigger the Flutter build engine for iOS by running the command:
   ```bash
   flutter build ipa --release
   ```
   *(Note: This might take a few minutes).*
2. This generates the `Shunya.xcarchive` bundle.

### Phase 4: Validating and Uploading (AI & User Action)
1. Once the `ipa` archive is successfully built, I will open the Xcode Organizer for you:
   ```bash
   open build/ios/archive/Runner.xcarchive
   ```
2. In the Organizer window, you will click **Distribute App** -> **App Store Connect** -> **Upload**.
3. Xcode will validate the binary and securely transmit it to Apple's servers.

### Phase 5: App Store Connect Store Listing (User Manual Action)
1. Go to [App Store Connect](https://appstoreconnect.apple.com/) web interface.
2. Under the TestFlight tab, you will see the build processing.
3. Once processed, you will need to:
   - Provide Screenshots (can be generated easily or grabbed from the app).
   - Enter App Description, Keywords, and Promotional Text.
   - Enter your Privacy Policy URL (e.g., https://shunya.com/privacy or the hosted version).
   - Answer the Data Privacy algorithm queries.
4. Click **Submit for Review**.

## Open Questions

- Have you already paid the $99/year Apple Developer enrollment, or do you still need to set that up?
- Would you like me to start the process by opening Xcode for you to configure the Signing capabilities? 

## Verification Plan

We will know the publishing setup was a success when the binary appears in the **TestFlight** tab on your App Store Connect account, ready for internal testing or production App Store review!
