# Build Automation Scripts

## Overview

This directory contains automated build scripts for generating production-ready builds of ExpenseTracker for both iOS and Android platforms.

---

## Available Scripts

### 1. iOS IPA Builder
**File:** `build_ios_ipa.sh`  
**Platform:** macOS only  
**Output:** Signed IPA file ready for App Store submission

**Features:**
- Automated clean and dependency installation
- Flutter iOS release build
- Xcode archive creation
- IPA export with signing
- Verification and validation

**Usage:**
```bash
chmod +x scripts/build_ios_ipa.sh
./scripts/build_ios_ipa.sh
```

**Prerequisites:**
- macOS with Xcode installed
- Valid Apple Developer account
- Signing certificates configured
- Provisioning profiles installed

**Output Location:**
```
build/ios/ipa/Runner.ipa
```

---

### 2. Android AAB Builder (Unix/Linux/macOS)
**File:** `build_android_aab.sh`  
**Platform:** macOS, Linux  
**Output:** Signed AAB file ready for Play Store submission

**Features:**
- Automated clean and dependency installation
- Keystore verification
- Flutter Android release build
- AAB signature verification
- Optional universal APK generation

**Usage:**
```bash
chmod +x scripts/build_android_aab.sh
./scripts/build_android_aab.sh
```

**Prerequisites:**
- Flutter SDK installed
- Android SDK installed
- Java JDK 11+ installed
- Keystore configured (see `ANDROID_RELEASE_SIGNING_GUIDE.md`)
- `android/key.properties` file created

**Output Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

---

### 3. Android AAB Builder (Windows)
**File:** `build_android_aab.bat`  
**Platform:** Windows  
**Output:** Signed AAB file ready for Play Store submission

**Features:**
- Same as Unix version but for Windows
- Automated clean and dependency installation
- Keystore verification
- AAB signature verification

**Usage:**
```cmd
scripts\build_android_aab.bat
```

**Prerequisites:**
- Same as Unix version
- Windows 10/11
- PowerShell or Command Prompt

**Output Location:**
```
build\app\outputs\bundle\release\app-release.aab
```

---

## Setup Instructions

### First-Time Setup

#### For iOS:

1. **Complete iOS Configuration:**
   - Follow `IOS_BUNDLE_ID_SETUP_GUIDE.md`
   - Ensure signing certificates are installed
   - Verify provisioning profiles are configured

2. **Update ExportOptions.plist:**
   ```bash
   # Edit ios/ExportOptions.plist
   # Update YOUR_TEAM_ID with your actual Team ID
   ```

3. **Test Build:**
   ```bash
   ./scripts/build_ios_ipa.sh
   ```

#### For Android:

1. **Generate Keystore:**
   - Follow `ANDROID_RELEASE_SIGNING_GUIDE.md`
   - Use automated script or manual generation

2. **Create key.properties:**
   ```bash
   # Create android/key.properties
   cat > android/key.properties << EOF
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=expensetracker-key-alias
   storeFile=/path/to/your/keystore.jks
   EOF
   ```

3. **Test Build:**
   ```bash
   ./scripts/build_android_aab.sh
   ```

---

## Script Features

### Error Handling
- All scripts exit on first error
- Clear error messages with troubleshooting hints
- Prerequisite validation before build

### Progress Tracking
- Color-coded output (INFO, SUCCESS, ERROR, WARNING)
- Step-by-step progress indicators
- Build time estimation

### Verification
- Automatic signature verification
- File integrity checks
- Output validation

### Cleanup
- Automatic cleanup of previous builds
- Dependency cache refresh
- Build artifact organization

---

## Common Issues

### iOS Build Issues

**Error: "No signing certificate found"**
```bash
# Solution: Install certificates
open ~/Library/MobileDevice/Provisioning\ Profiles/
# Double-click provisioning profiles to install
```

**Error: "Archive failed"**
```bash
# Solution: Clean and rebuild
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
./scripts/build_ios_ipa.sh
```

### Android Build Issues

**Error: "key.properties not found"**
```bash
# Solution: Create key.properties file
# See ANDROID_RELEASE_SIGNING_GUIDE.md
```

**Error: "Keystore was tampered with"**
```bash
# Solution: Verify password in key.properties
# Check keystore file path is correct
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/keystore.jks
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=../keystore.jks" >> android/key.properties
      - name: Build AAB
        run: ./scripts/build_android_aab.sh
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: release-aab
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Install certificates
        run: |
          # Import certificates and provisioning profiles
          # See GitHub Actions documentation for details
      - name: Build IPA
        run: ./scripts/build_ios_ipa.sh
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: release-ipa
          path: build/ios/ipa/Runner.ipa
```

---

## Testing Builds

### Test iOS IPA

```bash
# Install on connected device
xcrun devicectl device install app --device <DEVICE_ID> build/ios/ipa/Runner.ipa

# Or use Xcode Devices window
open -a "Devices and Simulators"
```

### Test Android AAB

```bash
# Generate universal APK for testing
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app.apks \
  --mode=universal

# Extract APK
unzip -p app.apks universal.apk > app-universal.apk

# Install on device
adb install app-universal.apk
```

---

## Build Checklist

Before running build scripts:

### iOS
- [ ] Xcode installed and updated
- [ ] Apple Developer account active
- [ ] Signing certificates installed
- [ ] Provisioning profiles configured
- [ ] Bundle ID matches Developer Portal
- [ ] ExportOptions.plist updated with Team ID
- [ ] Version and build number incremented

### Android
- [ ] Flutter SDK installed
- [ ] Android SDK installed
- [ ] Java JDK 11+ installed
- [ ] Keystore file created and backed up
- [ ] key.properties file configured
- [ ] Version code and version name incremented
- [ ] ProGuard rules tested (if using minification)

---

## Next Steps

After successful builds:

1. **Test Builds:**
   - Install on physical devices
   - Test all critical features
   - Verify signing and permissions

2. **Upload to Stores:**
   - iOS: Upload to App Store Connect
   - Android: Upload to Play Console

3. **Beta Testing:**
   - Distribute via TestFlight (iOS)
   - Distribute via Internal Testing (Android)

4. **Submit for Review:**
   - Complete store listings
   - Submit for review
   - Monitor review status

---

## Support

For issues with build scripts:
- Check script output for specific error messages
- Review platform-specific setup guides
- Verify all prerequisites are met
- Contact: support@expensetracker.app

---

**Last Updated:** February 21, 2026  
**Version:** 1.0.0