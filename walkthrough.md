# Shunya Publishing Guide

This document outlines the essential steps to configure third-party services following the Application ID change to `com.anamiapps.shunya` and the process for submitting the app to the Google Play Store.

---

## Part 1: Configuring Services for the New Bundle ID

Because the Android Application ID was changed to `com.anamiapps.shunya`, the authentication services (Google Sign-In and Apple Sign-In via Supabase) will reject logins until they are updated with the new identifier and the keystore's SHA-1 fingerprint.

### 1. Extract Your Keystore SHA-1 Fingerprint
To authenticate with Google Cloud, you need the SHA-1 fingerprint of the newly generated production keystore. Run the following command in your terminal from the Shunya directory:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```
*When prompted for the password, enter: `ShunyaApp2026!`*
Copy the `SHA1` value printed in the output.

### 2. Update Google Cloud Console (Google Sign-In)
1. Go to the [Google Cloud Console](https://console.cloud.google.com/) and open the project associated with Shunya.
2. Navigate to **APIs & Services > Credentials**.
3. Edit your existing Android OAuth 2.0 Client ID (or create a new one).
4. Set the **Package name** to: `com.anamiapps.shunya`
5. Paste the **SHA-1 certificate fingerprint** you copied in Step 1.
6. Save the changes. *(Note: If you create a new Web Client ID or iOS Client ID during this process, ensure you update the environmental variables in Flutter if required).*

### 3. Update Supabase Authentication Settings
1. Go to your [Supabase Dashboard](https://supabase.com/dashboard).
2. Open the Shunya project and navigate to **Authentication > URL Configuration**.
3. Under **Site URL**, ensure your primary site URL is correct.
4. Under **Redirect URLs**, add the following deep link schema exactly:
   ```text
   com.anamiapps.shunya://login-callback/
   ```
5. Ensure that the Google OAuth provider settings in Supabase have the correct Web Client ID and secret from the Google Cloud Console.

---

## Part 2: Publishing to the Google Play Store

### 1. Enable GitHub Pages for your Privacy Policy
1. Go to your GitHub repository for Shunya (`amanat-2003/shunya-meditation-app`).
2. Navigate to **Settings > Pages** (on the left sidebar).
3. Under **Build and deployment**, set the Source to **Deploy from a branch**.
4. Select the `main` branch and the `/docs` folder, then click **Save**.
5. Wait a few minutes. GitHub will provide a live URL (e.g., `https://amanat-2003.github.io/shunya-meditation-app/privacy_policy.html`). Keep this URL handy for the Play Console.

### 2. Prepare the Google Play Console
1. Log in to the [Google Play Console](https://play.google.com/console).
2. Click **Create app** (or select Shunya if already created). Enter the App name ("Shunya"), default language, and confirm whether it is an App or Game, and Free or Paid. Accept the Developer Program Policies.

### 3. Complete App Declaration Tasks
On the dashboard, complete all initial setup tasks under "Set up your app":
- **App access:** Specify if login is required. Provide test credentials so reviewers can check the app.
- **Ads:** Indicate whether the app contains ads (No).
- **Content rating:** Fill out the questionnaire to receive a rating (usually Everyone).
- **Target audience:** Select the appropriate age groups.
- **News apps:** Confirm it is not a news app.
- **Data safety:** Fill this out based on what data is collected. Mention that data is encrypted in transit and users can request deletion (as stated in the Privacy Policy).

### 4. Setup the Store Listing
Navigate to **Grow > Store presence > Main store listing**:
- Provide a Short description and Full description for the app.
- Upload high-res icons (512x512) and feature graphics (1024x500).
- Upload screenshots of the app across different formats (Phone, Tablet).
- Upload a video demonstrating the UI (optional but recommended).

### 5. Upload the App Bundle
1. Navigate to **Release > Testing > Internal testing** (or directly to **Production**).
2. Create a new release.
3. Upload the `.aab` file located at on your machine:
   `/Users/amanatsingh/Development/Shunya/build/app/outputs/bundle/release/app-release.aab`
4. Google Play App Signing will prompt you. If this is a new app entry, opt-in to let Google manage your signing keys (it uses the `.jks` we built as your local upload key).
5. Add release notes.

### 6. Submit for Review
Go to the **Publishing overview** screen, ensure there are no errors, and send your changes in for review. Google Play review usually takes between 1-5 days.
