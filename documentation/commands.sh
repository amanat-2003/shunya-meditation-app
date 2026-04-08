#!/bin/bash
# ============================================================
#  Shunya — Ready-to-Run Commands
# ============================================================
#  Usage: Copy-paste any command into your terminal, or run
#         sections with: bash scripts/commands.sh
#
#  All environment variables are pre-filled with your actual
#  values. Just copy and paste.
# ============================================================

# ========================
#  ENVIRONMENT VARIABLES
# ========================
export GOOGLE_WEB_CLIENT_ID="182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com"
export GOOGLE_IOS_CLIENT_ID="YOUR_IOS_CLIENT_ID_HERE"   # Replace when you get Apple Developer account
export APPLE_SIGN_IN_ENABLED="false"

# Common dart-define flags (reused in all commands below)
DART_DEFINES="--dart-define=GOOGLE_WEB_CLIENT_ID=$GOOGLE_WEB_CLIENT_ID"
DART_DEFINES_IOS="$DART_DEFINES --dart-define=GOOGLE_IOS_CLIENT_ID=$GOOGLE_IOS_CLIENT_ID"
DART_DEFINES_IOS_FULL="$DART_DEFINES_IOS --dart-define=APPLE_SIGN_IN_ENABLED=$APPLE_SIGN_IN_ENABLED"


# ============================================================
#  1. SETUP
# ============================================================

# Install dependencies
# flutter pub get

# Run static analysis
# flutter analyze

# Run tests
# flutter test


# ============================================================
#  2. LIST DEVICES
# ============================================================

# List all connected devices (emulators, simulators, real)
# flutter devices

# List available emulators
# flutter emulators


# ============================================================
#  3. START EMULATORS / SIMULATORS
# ============================================================

# --- Android Emulator ---
# List available Android emulators
# flutter emulators

# Launch a specific Android emulator (replace name)
# flutter emulators --launch Pixel_7_API_35

# Create a new Android emulator
# flutter emulators --create --name Pixel_8_API_35

# --- iOS Simulator ---
# Open Simulator app
# open -a Simulator

# List all available iOS simulators
# xcrun simctl list devices available

# Boot a specific simulator (replace UUID)
# xcrun simctl boot "iPhone 16 Pro"


# ============================================================
#  4. RUN — ANDROID EMULATOR
# ============================================================

# Debug mode (hot reload enabled)
# flutter run $DART_DEFINES

# Debug mode on a specific device (get device-id from `flutter devices`)
# flutter run -d emulator-5554 $DART_DEFINES

# Release mode (for performance testing)
# flutter run --release $DART_DEFINES

# Profile mode (for profiling performance)
# flutter run --profile $DART_DEFINES


# ============================================================
#  5. RUN — ANDROID REAL DEVICE (USB)
# ============================================================

# Make sure USB debugging is enabled on your phone
# Then connect via USB and run:

# Debug mode
# flutter run $DART_DEFINES

# Release mode
# flutter run --release $DART_DEFINES

# Specific device (get ID from `flutter devices`)
# flutter run -d <device-id> $DART_DEFINES


# ============================================================
#  6. RUN — iOS SIMULATOR
# ============================================================

# Debug mode
# flutter run $DART_DEFINES_IOS

# Specific simulator
# flutter run -d "iPhone 16 Pro" $DART_DEFINES_IOS

# Release mode (not available on simulator, use profile instead)
# flutter run --profile $DART_DEFINES_IOS


# ============================================================
#  7. RUN — iOS REAL DEVICE (USB)
# ============================================================

# First: Open Xcode, select team for signing:
#   open ios/Runner.xcworkspace
#   Runner > Signing & Capabilities > Team > Your Account

# Debug mode
# flutter run $DART_DEFINES_IOS

# Release mode
# flutter run --release $DART_DEFINES_IOS_FULL


# ============================================================
#  8. BUILD — ANDROID
# ============================================================

# Debug APK (for testing)
# flutter build apk --debug $DART_DEFINES

# Release APK (universal, for sideloading)
# flutter build apk --release $DART_DEFINES
# Output: build/app/outputs/flutter-apk/app-release.apk

# Release APK split by ABI (smaller files)
# flutter build apk --release --split-per-abi $DART_DEFINES
# Output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (etc.)

# App Bundle (for Google Play Store upload)
# flutter build appbundle --release $DART_DEFINES
# Output: build/app/outputs/bundle/release/app-release.aab


# ============================================================
#  9. BUILD — iOS
# ============================================================

# Build iOS (creates Runner.app)
# flutter build ios --release $DART_DEFINES_IOS_FULL
# Then archive in Xcode: Product > Archive > Distribute

# Build iOS without codesign (CI/CD)
# flutter build ios --release --no-codesign $DART_DEFINES_IOS_FULL


# ============================================================
# 10. BUILD — iOS IPA (Direct export)
# ============================================================

# Export IPA for App Store
# flutter build ipa --release $DART_DEFINES_IOS_FULL
# Output: build/ios/ipa/shunya.ipa

# Export IPA for Ad Hoc distribution
# flutter build ipa --release --export-method ad-hoc $DART_DEFINES_IOS_FULL


# ============================================================
# 11. INSTALL ON DEVICE (after building)
# ============================================================

# Install APK on connected Android device
# flutter install

# Install on specific Android device
# flutter install -d <device-id>

# Install specific APK file
# adb install build/app/outputs/flutter-apk/app-release.apk


# ============================================================
# 12. CLEAN & RESET
# ============================================================

# Clean build cache
# flutter clean

# Rebuild everything from scratch
# flutter clean && flutter pub get && flutter run $DART_DEFINES

# Clean iOS pods and rebuild
# cd ios && pod deintegrate && pod install --repo-update && cd ..

# Reset Hive data (clear app data on device)
# Android: adb shell pm clear com.anamiapps.shunya
# iOS: Delete and reinstall the app


# ============================================================
# 13. DEBUGGING
# ============================================================

# Run with verbose logging
# flutter run --verbose $DART_DEFINES

# Attach debugger to a running app
# flutter attach -d <device-id> $DART_DEFINES

# Open DevTools (run this while app is running)
# flutter pub global activate devtools
# dart devtools

# View app logs
# flutter logs


# ============================================================
# 14. TESTING
# ============================================================

# Run all tests
# flutter test

# Run specific test file
# flutter test test/widget_test.dart

# Run tests with coverage
# flutter test --coverage

# View coverage report (after running with --coverage)
# genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html


# ============================================================
# 15. CODE QUALITY
# ============================================================

# Static analysis
# flutter analyze

# Format all Dart files
# dart format lib/

# Check for outdated packages
# flutter pub outdated

# Upgrade packages (compatible versions)
# flutter pub upgrade

# Upgrade packages (major versions)
# flutter pub upgrade --major-versions


# ============================================================
# 16. GIT — COMMON OPERATIONS
# ============================================================

# Status
# git status

# Stage all and commit
# git add -A && git commit -m "feat: your message"

# Push to GitHub
# git push origin main

# Pull latest
# git pull origin main

# Create feature branch
# git checkout -b feature/my-feature

# Merge feature branch back
# git checkout main && git merge feature/my-feature


# ============================================================
# 17. RELEASE WORKFLOW (full sequence)
# ============================================================

# --- Android Play Store Release ---
# 1. Update version in pubspec.yaml
# 2. flutter clean
# 3. flutter pub get
# 4. flutter analyze
# 5. flutter test
# 6. flutter build appbundle --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com
# 7. Upload build/app/outputs/bundle/release/app-release.aab to Play Console

# --- iOS App Store Release ---
# 1. Update version in pubspec.yaml
# 2. flutter clean
# 3. flutter pub get
# 4. cd ios && pod install && cd ..
# 5. flutter analyze
# 6. flutter test
# 7. flutter build ipa --release --dart-define=GOOGLE_WEB_CLIENT_ID=182112252228-9n3rivl47a9lnf74lgvnbfr84oim2qhd.apps.googleusercontent.com --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID_HERE --dart-define=APPLE_SIGN_IN_ENABLED=true
# 8. Upload build/ios/ipa/shunya.ipa via Transporter or Xcode


# ============================================================
# 18. SUPABASE DATABASE
# ============================================================

# Run migration (paste into Supabase SQL Editor):
# File: supabase/migrations/001_create_tables.sql

# Quick Supabase dashboard links:
# Dashboard:    https://supabase.com/dashboard/project/bxctadqcjxhrtajvktun
# SQL Editor:   https://supabase.com/dashboard/project/bxctadqcjxhrtajvktun/sql
# Auth:         https://supabase.com/dashboard/project/bxctadqcjxhrtajvktun/auth/users
# Table Editor: https://supabase.com/dashboard/project/bxctadqcjxhrtajvktun/editor


# ============================================================
# 19. SIGNING — ANDROID (one-time setup)
# ============================================================

# Generate release keystore
# keytool -genkey -v -keystore ~/shunya-release.keystore -alias shunya -keyalg RSA -keysize 2048 -validity 10000

# Get SHA-1 for debug keystore (needed for Google OAuth)
# keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:"

# Get SHA-1 for release keystore
# keytool -list -v -keystore ~/shunya-release.keystore -alias shunya | grep "SHA1:"

# Get SHA-256 for release keystore (Play App Signing)
# keytool -list -v -keystore ~/shunya-release.keystore -alias shunya | grep "SHA256:"


echo ""
echo "============================================"
echo "  Shunya Commands File"
echo "============================================"
echo "  This file contains all commands for the"
echo "  Shunya meditation app."
echo ""
echo "  Usage: Copy-paste individual commands"
echo "  into your terminal."
echo ""
echo "  Environment variables loaded:"
echo "    GOOGLE_WEB_CLIENT_ID = $GOOGLE_WEB_CLIENT_ID"
echo "    GOOGLE_IOS_CLIENT_ID = $GOOGLE_IOS_CLIENT_ID"
echo "    APPLE_SIGN_IN_ENABLED = $APPLE_SIGN_IN_ENABLED"
echo "============================================"
