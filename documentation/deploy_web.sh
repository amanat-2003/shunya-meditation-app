#!/usr/bin/env bash
# Exit on any error
set -e

echo "🚀 Starting Shunya Web App Deployment"
echo ""

# 1. Build the Flutter Web App
echo "📦 Building Flutter web release..."
flutter build web --release --base-href /shunya-meditation-app/

echo "✅ Build successful"
echo ""

# 2. Backup Privacy Policy
echo "🔒 Backing up privacy_policy.html..."
if [ -f "build_deploy/privacy_policy.html" ]; then
  cp build_deploy/privacy_policy.html /tmp/shunya_privacy_policy.html
  echo "✅ Backup created"
else
  echo "⚠️ Warning: privacy_policy.html not found in build_deploy/. Script will continue, but ensure it exists."
fi

# 3. Clear existing deployment files (except Git stuff)
echo "🧹 Cleaning previous build..."
rm -rf build_deploy/*

# 4. Copy new build
echo "📂 Copying new build files..."
cp -r build/web/* build_deploy/

# 5. Restore Privacy Policy and config
echo "📝 Restoring configuration..."
if [ -f "/tmp/shunya_privacy_policy.html" ]; then
  cp /tmp/shunya_privacy_policy.html build_deploy/privacy_policy.html
  echo "✅ Privacy policy restored"
fi

# Ensure GitHub Pages bypasses Jekyll (needed for Flutter file names starting with _)
touch build_deploy/.nojekyll

echo "✅ Files copied to build_deploy folder"
echo ""

# 6. Commit and Push
echo "⬆️ Pushing updates to GitHub..."
git add .
git commit -m "deploy: update web build and configurations for GitHub Pages" || echo "No changes to commit."
git push origin main

echo ""
echo "🎉 Deployment successful!"
echo "If you have configured GitHub Pages to use GitHub Actions, the new version will be live soon at:"
echo "https://amanat-2003.github.io/shunya-meditation-app/"
