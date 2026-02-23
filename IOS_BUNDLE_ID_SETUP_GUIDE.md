# iOS Bundle ID & Provisioning Profile Setup Guide

## Complete Guide to Configuring iOS App Identity and Code Signing

This guide walks you through setting up your iOS Bundle ID, creating provisioning profiles, and configuring code signing for App Store submission.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Apple Developer Account Setup](#apple-developer-account-setup)
3. [Bundle ID Configuration](#bundle-id-configuration)
4. [App ID Capabilities](#app-id-capabilities)
5. [Certificate Management](#certificate-management)
6. [Provisioning Profiles](#provisioning-profiles)
7. [Xcode Configuration](#xcode-configuration)
8. [Automated Signing vs Manual Signing](#automated-signing-vs-manual-signing)
9. [Testing Your Configuration](#testing-your-configuration)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- ✅ macOS computer (required for iOS development)
- ✅ Xcode 14.0 or higher installed
- ✅ Apple Developer Account ($99/year)
- ✅ Flutter SDK installed
- ✅ Valid Apple ID with Two-Factor Authentication enabled

**Verify Xcode Installation:**
```bash
xcode-select --version
xcodebuild -version
```

---

## Apple Developer Account Setup

### Step 1: Enroll in Apple Developer Program

1. Go to https://developer.apple.com/programs/
2. Click "Enroll"
3. Sign in with your Apple ID
4. Complete enrollment ($99/year)
5. Wait for approval (usually 24-48 hours)

### Step 2: Enable Two-Factor Authentication

1. Go to https://appleid.apple.com/
2. Sign in with your Apple ID
3. Navigate to Security section
4. Enable Two-Factor Authentication
5. Add trusted phone number

### Step 3: Accept Developer Agreement

1. Go to https://developer.apple.com/account/
2. Sign in
3. Accept latest Developer Agreement
4. Complete any pending actions

---

## Bundle ID Configuration

### What is a Bundle ID?

A Bundle ID uniquely identifies your app on iOS devices and the App Store. It uses reverse-domain notation:

```
com.yourcompany.appname
```

**For ExpenseTracker, recommended Bundle ID:**
```
com.expensetracker.app
```

### Step 1: Register Bundle ID in Apple Developer Portal

1. **Go to Apple Developer Portal:**
   - Visit https://developer.apple.com/account/
   - Sign in with your Apple ID

2. **Navigate to Identifiers:**
   - Click "Certificates, Identifiers & Profiles"
   - Select "Identifiers" from left sidebar
   - Click the "+" button (top right)

3. **Register New Identifier:**
   - Select "App IDs"
   - Click "Continue"

4. **Select Type:**
   - Choose "App" (not App Clip)
   - Click "Continue"

5. **Configure App ID:**
   ```
   Description: ExpenseTracker
   Bundle ID: Explicit
   Bundle ID: com.expensetracker.app
   ```

6. **Select Capabilities** (see next section)

7. **Review and Register:**
   - Review all settings
   - Click "Register"

### Step 2: Update Bundle ID in Xcode Project

**Option A: Using Xcode GUI**

1. Open Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select "Runner" project in navigator

3. Select "Runner" target

4. Go to "Signing & Capabilities" tab

5. Update Bundle Identifier:
   ```
   com.expensetracker.app
   ```

**Option B: Edit Info.plist Directly**

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

Then edit `ios/Runner.xcodeproj/project.pbxproj` and search for `PRODUCT_BUNDLE_IDENTIFIER` and update all occurrences:

```
PRODUCT_BUNDLE_IDENTIFIER = com.expensetracker.app;
```

**Option C: Automated Script**

Create `update_bundle_id.sh`:

```bash
#!/bin/bash

NEW_BUNDLE_ID="com.expensetracker.app"
PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"

echo "Updating Bundle ID to: $NEW_BUNDLE_ID"

# Backup original file
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup"

# Update Bundle ID
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $NEW_BUNDLE_ID;/g" "$PROJECT_FILE"

echo "✅ Bundle ID updated successfully!"
echo "Backup saved to: ${PROJECT_FILE}.backup"
```

Run:
```bash
chmod +x update_bundle_id.sh
./update_bundle_id.sh
```

---

## App ID Capabilities

### Required Capabilities for ExpenseTracker

When registering your Bundle ID, enable these capabilities:

#### ✅ Essential Capabilities

1. **Push Notifications**
   - For budget alerts and reminders
   - Enable in Developer Portal

2. **iCloud** (if using cloud sync)
   - For data backup and sync
   - Select "CloudKit" container

3. **Sign in with Apple** (if implementing)
   - For authentication
   - Required if offering third-party login

4. **App Groups** (if using widgets)
   - For sharing data with widgets
   - Create group: `group.com.expensetracker.app`

#### ⚠️ Optional Capabilities

5. **Associated Domains** (for universal links)
6. **HealthKit** (if tracking health-related expenses)
7. **HomeKit** (not needed for ExpenseTracker)

### Enable Capabilities in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" button
5. Add required capabilities:

```
+ Push Notifications
+ iCloud (if needed)
+ Sign in with Apple (if needed)
+ App Groups (if using widgets)
```

---

## Certificate Management

### Types of Certificates

1. **Development Certificate**
   - For testing on physical devices
   - Valid for 1 year

2. **Distribution Certificate**
   - For App Store submission
   - Valid for 1 year

### Step 1: Create Certificate Signing Request (CSR)

1. **Open Keychain Access** (macOS)
   - Applications → Utilities → Keychain Access

2. **Request Certificate:**
   - Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority

3. **Fill in Information:**
   ```
   User Email Address: your-email@example.com
   Common Name: Your Name
   CA Email Address: (leave empty)
   Request is: Saved to disk
   ```

4. **Save CSR:**
   - Save as `CertificateSigningRequest.certSigningRequest`
   - Location: Desktop or Documents

### Step 2: Create Distribution Certificate

1. **Go to Apple Developer Portal:**
   - https://developer.apple.com/account/
   - Certificates, Identifiers & Profiles → Certificates

2. **Create New Certificate:**
   - Click "+" button
   - Select "Apple Distribution"
   - Click "Continue"

3. **Upload CSR:**
   - Choose the CSR file you created
   - Click "Continue"

4. **Download Certificate:**
   - Download the certificate (.cer file)
   - Double-click to install in Keychain

### Step 3: Verify Certificate Installation

1. Open Keychain Access
2. Select "My Certificates"
3. Look for "Apple Distribution: Your Name (Team ID)"
4. Expand to see private key

**If private key is missing:**
- You used wrong CSR
- Create new CSR and certificate

---

## Provisioning Profiles

### What is a Provisioning Profile?

A provisioning profile links:
- Your App ID (Bundle ID)
- Your Certificate
- Authorized devices (for development)

### Step 1: Create App Store Provisioning Profile

1. **Go to Developer Portal:**
   - Certificates, Identifiers & Profiles → Profiles
   - Click "+" button

2. **Select Profile Type:**
   - Choose "App Store"
   - Click "Continue"

3. **Select App ID:**
   - Choose "com.expensetracker.app"
   - Click "Continue"

4. **Select Certificate:**
   - Choose your Distribution Certificate
   - Click "Continue"

5. **Name Profile:**
   ```
   ExpenseTracker App Store
   ```
   - Click "Generate"

6. **Download Profile:**
   - Download the profile (.mobileprovision)
   - Double-click to install

### Step 2: Create Development Provisioning Profile

1. **Create Profile:**
   - Select "iOS App Development"
   - Follow same steps as above

2. **Select Devices:**
   - Choose test devices
   - Click "Continue"

3. **Name Profile:**
   ```
   ExpenseTracker Development
   ```

### Step 3: Verify Profile Installation

```bash
# List installed profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# View profile details
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/PROFILE_UUID.mobileprovision
```

---

## Xcode Configuration

### Option 1: Automatic Signing (Recommended for Beginners)

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Runner Target:**
   - Click "Runner" in project navigator
   - Select "Runner" target

3. **Configure Signing:**
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team from dropdown
   - Bundle Identifier: `com.expensetracker.app`

4. **Verify Configuration:**
   - Xcode will automatically:
     - Create certificates (if needed)
     - Create provisioning profiles
     - Download and install profiles

### Option 2: Manual Signing (Recommended for Production)

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Disable Automatic Signing:**
   - Uncheck "Automatically manage signing"

3. **Configure Debug:**
   ```
   Provisioning Profile: ExpenseTracker Development
   Signing Certificate: Apple Development
   ```

4. **Configure Release:**
   ```
   Provisioning Profile: ExpenseTracker App Store
   Signing Certificate: Apple Distribution
   ```

### Verify Signing Configuration

```bash
# Check signing settings
xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release | grep -i "code_sign"
```

---

## Automated Signing vs Manual Signing

### Automatic Signing

**Pros:**
- ✅ Easy setup
- ✅ Xcode manages everything
- ✅ Good for solo developers
- ✅ Automatic certificate renewal

**Cons:**
- ❌ Less control
- ❌ Can cause issues in CI/CD
- ❌ Team coordination harder

**Best for:**
- Individual developers
- Small teams
- Quick prototyping

### Manual Signing

**Pros:**
- ✅ Full control
- ✅ Better for teams
- ✅ Works well with CI/CD
- ✅ Consistent across machines

**Cons:**
- ❌ More setup required
- ❌ Manual certificate management
- ❌ Need to renew certificates

**Best for:**
- Production apps
- Team environments
- CI/CD pipelines

---

## Testing Your Configuration

### Step 1: Build for Device

```bash
# Clean build
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release
```

### Step 2: Archive in Xcode

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Device:**
   - Product → Destination → Any iOS Device (arm64)

3. **Create Archive:**
   - Product → Archive
   - Wait for build to complete

4. **Verify Archive:**
   - Archives window should open
   - Archive should appear with no errors

### Step 3: Validate Archive

1. **In Archives Window:**
   - Select your archive
   - Click "Validate App"

2. **Select Distribution Method:**
   - Choose "App Store Connect"
   - Click "Next"

3. **Select Options:**
   - Upload symbols: Yes
   - Manage Version and Build Number: Automatic
   - Click "Next"

4. **Review and Validate:**
   - Review signing certificate
   - Click "Validate"

**Expected Result:**
```
✅ App validation successful
```

---

## Troubleshooting

### Error: "No signing certificate found"

**Solution:**
1. Open Keychain Access
2. Check "My Certificates" for Apple Distribution certificate
3. Ensure private key is present
4. If missing, create new certificate with CSR

### Error: "Provisioning profile doesn't match Bundle ID"

**Solution:**
1. Verify Bundle ID in Xcode matches Developer Portal
2. Regenerate provisioning profile
3. Download and install new profile
4. Clean build folder: Product → Clean Build Folder

### Error: "The executable was signed with invalid entitlements"

**Solution:**
1. Check capabilities in Xcode match App ID capabilities
2. Regenerate provisioning profile with correct capabilities
3. Ensure entitlements file is correct

### Error: "Failed to register bundle identifier"

**Solution:**
1. Bundle ID already exists
2. Choose different Bundle ID
3. Or use existing Bundle ID if you own it

### Error: "Your account already has a valid certificate"

**Solution:**
1. You can only have 2 distribution certificates
2. Revoke old certificate if not needed
3. Or use existing certificate

### Xcode Can't Find Provisioning Profile

**Solution:**
```bash
# Refresh profiles
xcodebuild -downloadAllPlatforms

# Or manually download from Developer Portal
# Then double-click to install
```

---

## Quick Reference Commands

```bash
# Open Xcode workspace
open ios/Runner.xcworkspace

# Build iOS release
flutter build ios --release

# Clean build
flutter clean
cd ios && rm -rf Pods Podfile.lock && cd ..
flutter pub get
cd ios && pod install && cd ..

# List installed profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# View profile details
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision

# Check signing settings
xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner

# Create archive
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/Runner.xcarchive
```

---

## Checklist

Before proceeding to App Store submission:

- [ ] Apple Developer Account active and paid
- [ ] Two-Factor Authentication enabled
- [ ] Bundle ID registered in Developer Portal
- [ ] All required capabilities enabled
- [ ] Distribution certificate created and installed
- [ ] App Store provisioning profile created and installed
- [ ] Xcode signing configuration complete
- [ ] Test build successful
- [ ] Archive validation successful
- [ ] Bundle ID matches across all configurations

---

## Next Steps

After completing iOS configuration:

1. ✅ Build and test on physical device
2. ✅ Create archive and validate
3. ✅ Upload to App Store Connect
4. ✅ Complete app metadata
5. ✅ Submit for TestFlight beta testing

Refer to:
- `IOS_BUILD_AUTOMATION.md` for automated build scripts
- `APP_STORE_CONNECT_GUIDE.md` for store configuration
- `BETA_TESTING_GUIDE.md` for TestFlight setup

---

## Resources

- Apple Developer Portal: https://developer.apple.com/account/
- Code Signing Guide: https://developer.apple.com/support/code-signing/
- App Store Connect: https://appstoreconnect.apple.com/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios

---

**Last Updated:** February 21, 2026  
**Version:** 1.0.0