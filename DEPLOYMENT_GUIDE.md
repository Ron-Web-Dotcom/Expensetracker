# Complete Deployment Documentation

## ExpenseTracker Production Deployment Guide

This comprehensive guide covers the entire deployment process from development to production release on both Apple App Store and Google Play Store.

---

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Code Preparation](#code-preparation)
4. [Platform-Specific Configuration](#platform-specific-configuration)
5. [Build Process](#build-process)
6. [Testing Phase](#testing-phase)
7. [Store Submission](#store-submission)
8. [Post-Launch Monitoring](#post-launch-monitoring)
9. [Update Process](#update-process)
10. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

### Development Complete

- [ ] All features implemented and tested
- [ ] No critical bugs or crashes
- [ ] Code reviewed and approved
- [ ] Performance optimized
- [ ] Memory leaks fixed
- [ ] Security audit passed
- [ ] Accessibility features implemented
- [ ] Dark mode tested (if applicable)
- [ ] All device sizes tested
- [ ] Offline functionality verified

### Legal & Compliance

- [ ] Privacy Policy created and hosted
- [ ] Terms of Service created and hosted
- [ ] GDPR compliance verified
- [ ] CCPA compliance verified
- [ ] App Store guidelines reviewed
- [ ] Play Store policies reviewed
- [ ] Age rating determined
- [ ] Content rating completed

### Assets & Media

- [ ] App icon (all sizes) ready
- [ ] Screenshots captured (all required sizes)
- [ ] Feature graphic created (Play Store)
- [ ] Promotional images ready
- [ ] App preview video (optional)
- [ ] Store listing text written
- [ ] Keywords researched
- [ ] Localized content prepared (if applicable)

### Accounts & Access

- [ ] Apple Developer Account active ($99/year)
- [ ] Google Play Developer Account active ($25 one-time)
- [ ] App Store Connect access configured
- [ ] Play Console access configured
- [ ] Team members added with appropriate roles
- [ ] Payment information verified

---

## Environment Setup

### Development Environment

**Required Software:**
```bash
# Flutter SDK
flutter --version  # Should be 3.16.0 or higher

# For iOS (macOS only)
xcode-select --version
xcodebuild -version  # Xcode 14.0 or higher

# For Android
java -version  # JDK 11 or higher
keytool -help
```

**Install Dependencies:**
```bash
cd /path/to/expensetracker
flutter pub get
flutter doctor -v
```

**Resolve Issues:**
```bash
# Fix any issues reported by flutter doctor
flutter doctor
```

### iOS Setup (macOS Required)

**1. Install CocoaPods:**
```bash
sudo gem install cocoapods
pod --version
```

**2. Install iOS Dependencies:**
```bash
cd ios
pod install
cd ..
```

**3. Configure Signing:**
- Follow `IOS_BUNDLE_ID_SETUP_GUIDE.md`
- Ensure certificates installed
- Verify provisioning profiles

### Android Setup

**1. Generate Keystore:**
```bash
# Use automated script
./scripts/generate_keystore.sh

# Or follow ANDROID_RELEASE_SIGNING_GUIDE.md
```

**2. Configure Signing:**
```bash
# Create android/key.properties
cat > android/key.properties << EOF
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=expensetracker-key-alias
storeFile=/path/to/keystore.jks
EOF
```

**3. Verify Configuration:**
```bash
# Test build
flutter build apk --release
```

---

## Code Preparation

### Version Management

**1. Update Version Number:**
```bash
# Use automated script
./scripts/bump_version.sh patch  # or minor, major

# Or manually edit pubspec.yaml
version: 1.0.0+1
```

**2. Update CHANGELOG.md:**
```markdown
## [1.0.0] - 2026-02-21

### Added
- Initial release
- Expense tracking
- Budget management
- Receipt scanning
- Analytics dashboard

### Features
- Biometric authentication
- Data export
- Dark mode
```

### Code Quality

**1. Run Linter:**
```bash
flutter analyze
```

**2. Fix All Issues:**
```bash
# Fix formatting
flutter format .

# Fix analysis issues
# Address all warnings and errors
```

**3. Run Tests:**
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/
```

**4. Test Coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Security Audit

**1. Check for Hardcoded Secrets:**
```bash
grep -r "api_key" lib/
grep -r "password" lib/
grep -r "secret" lib/
```

**2. Verify Environment Variables:**
```bash
# Ensure all sensitive data uses String.fromEnvironment
grep -r "String.fromEnvironment" lib/
```

**3. Review Permissions:**
```bash
# iOS
cat ios/Runner/Info.plist | grep -A 1 "UsageDescription"

# Android
cat android/app/src/main/AndroidManifest.xml | grep "uses-permission"
```

---

## Platform-Specific Configuration

### iOS Configuration

**1. Bundle ID:**
```
com.expensetracker.app
```

**2. App Name:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>ExpenseTracker</string>
```

**3. Version Info:**
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

**4. Permissions:**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan receipts</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to attach receipt images</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to tag expenses (optional)</string>
```

**5. Capabilities:**
- Push Notifications (if using)
- Background Modes (if needed)
- App Groups (if using widgets)

### Android Configuration

**1. Package Name:**
```
com.expensetracker.app
```

**2. App Name:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:label="ExpenseTracker"
    ...>
```

**3. Version Info:**
```gradle
// android/app/build.gradle
defaultConfig {
    versionCode 1
    versionName "1.0.0"
}
```

**4. Permissions:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**5. Target SDK:**
```gradle
targetSdkVersion 34  // Latest Android version
```

---

## Build Process

### iOS Build

**1. Clean Build:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

**2. Build Release:**
```bash
flutter build ios --release
```

**3. Create Archive:**
```bash
# Use automated script
./scripts/build_ios_ipa.sh

# Or manually in Xcode
open ios/Runner.xcworkspace
# Product → Archive
```

**4. Verify Build:**
```bash
# Check IPA location
ls -lh build/ios/ipa/Runner.ipa
```

### Android Build

**1. Clean Build:**
```bash
flutter clean
flutter pub get
```

**2. Build Release AAB:**
```bash
# Use automated script
./scripts/build_android_aab.sh

# Or manually
flutter build appbundle --release
```

**3. Verify Signature:**
```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

**4. Build APK (for testing):**
```bash
flutter build apk --release
```

---

## Testing Phase

### Internal Testing

**iOS - TestFlight:**

1. Upload build to App Store Connect
2. Add internal testers (up to 100)
3. Distribute build
4. Collect feedback
5. Fix issues
6. Repeat

**Android - Internal Testing:**

1. Upload AAB to Play Console
2. Create internal testing track
3. Add testers (up to 100)
4. Distribute build
5. Collect feedback
6. Fix issues
7. Repeat

### External Testing

**iOS - TestFlight External:**

1. Submit for Beta App Review
2. Wait for approval (24-48 hours)
3. Add external testers (up to 10,000)
4. Distribute via email or public link
5. Monitor feedback
6. Track metrics

**Android - Closed Testing:**

1. Create closed testing track
2. Add testers via email list
3. Distribute build
4. Monitor feedback
5. Track metrics

### Testing Checklist

- [ ] App launches successfully
- [ ] All features work as expected
- [ ] No crashes or freezes
- [ ] Performance is acceptable
- [ ] UI displays correctly on all devices
- [ ] Permissions work properly
- [ ] Data persists correctly
- [ ] Export/import functions work
- [ ] Biometric authentication works
- [ ] Notifications work
- [ ] Offline mode works
- [ ] Dark mode works (if applicable)
- [ ] Accessibility features work

---

## Store Submission

### iOS App Store Submission

**1. Complete App Information:**
- Follow `APP_STORE_CONNECT_GUIDE.md`
- Fill all required fields
- Upload screenshots
- Set pricing
- Configure privacy

**2. Upload Build:**
```bash
# Via Xcode Organizer
open -a "Xcode"
# Window → Organizer → Distribute App

# Or via command line
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/Runner.ipa \
  --username your-apple-id@example.com \
  --password your-app-specific-password
```

**3. Select Build:**
- In App Store Connect
- Go to version page
- Select uploaded build

**4. Submit for Review:**
- Review all information
- Click "Submit for Review"
- Wait for approval (24-48 hours typically)

### Android Play Store Submission

**1. Complete Store Listing:**
- Follow `PLAY_CONSOLE_SETUP_GUIDE.md`
- Fill all required fields
- Upload screenshots
- Set pricing
- Configure privacy

**2. Upload AAB:**
```bash
# Via Play Console web interface
# Production → Create new release → Upload
```

**3. Complete Release:**
- Add release notes
- Review warnings
- Set rollout percentage

**4. Submit for Review:**
- Review release
- Click "Review release"
- Click "Start rollout to Production"
- Wait for approval (few hours to 7 days)

---

## Post-Launch Monitoring

### Metrics to Track

**App Store Connect:**
- Downloads
- Impressions
- Conversion rate
- Crashes
- User ratings
- Reviews

**Play Console:**
- Installs
- Uninstalls
- Crashes
- ANRs
- User ratings
- Reviews

### Monitoring Tools

**1. Crash Reporting:**
```dart
// Already implemented in app
CrashlyticsService.recordError(error, stackTrace);
```

**2. Analytics:**
```dart
// Already implemented in app
AnalyticsService.logEvent('screen_view', {'screen': 'dashboard'});
```

**3. Performance:**
```dart
// Already implemented in app
PerformanceMonitoringService.trackMetric('app_launch_time');
```

### Response Plan

**Critical Issues (Crashes, Data Loss):**
1. Identify issue immediately
2. Fix in code
3. Test thoroughly
4. Submit emergency update
5. Request expedited review

**Major Issues (Broken Features):**
1. Assess impact
2. Fix in code
3. Test thoroughly
4. Submit update within 24-48 hours

**Minor Issues (UI Bugs):**
1. Log for next update
2. Fix in regular update cycle
3. Include in next release

---

## Update Process

### Planning Updates

**1. Version Strategy:**
- Patch (1.0.X): Bug fixes only
- Minor (1.X.0): New features, improvements
- Major (X.0.0): Major redesign, breaking changes

**2. Update Frequency:**
- Bug fixes: As needed (1-2 weeks)
- Feature updates: Monthly or bi-monthly
- Major updates: Quarterly or bi-annually

### Releasing Updates

**1. Prepare Update:**
```bash
# Bump version
./scripts/bump_version.sh patch

# Update CHANGELOG.md
# Add release notes
```

**2. Build:**
```bash
# iOS
./scripts/build_ios_ipa.sh

# Android
./scripts/build_android_aab.sh
```

**3. Test:**
- Internal testing first
- External testing if major changes
- Verify all fixes/features

**4. Submit:**
- Upload to stores
- Add release notes
- Submit for review

**5. Monitor:**
- Watch crash reports
- Monitor reviews
- Track adoption rate

---

## Troubleshooting

### Common iOS Issues

**Build Failed:**
```bash
# Clean and rebuild
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter build ios --release
```

**Signing Issues:**
```bash
# Verify certificates
open ~/Library/MobileDevice/Provisioning\ Profiles/

# Re-download profiles
xcodebuild -downloadAllPlatforms
```

**Upload Failed:**
```bash
# Verify app-specific password
# Generate at appleid.apple.com

# Try Transporter app instead
open -a Transporter
```

### Common Android Issues

**Build Failed:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build appbundle --release
```

**Signing Issues:**
```bash
# Verify keystore
keytool -list -v -keystore /path/to/keystore.jks

# Check key.properties
cat android/key.properties
```

**Upload Failed:**
```bash
# Verify AAB signature
jarsigner -verify build/app/outputs/bundle/release/app-release.aab

# Check version code is incremented
grep versionCode android/app/build.gradle
```

---

## Quick Reference

### Essential Commands

```bash
# Version bump
./scripts/bump_version.sh [major|minor|patch]

# Build iOS
./scripts/build_ios_ipa.sh

# Build Android
./scripts/build_android_aab.sh

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Important URLs

- App Store Connect: https://appstoreconnect.apple.com/
- Play Console: https://play.google.com/console/
- Apple Developer: https://developer.apple.com/account/
- Privacy Policy: https://expensetra7629.builtwithrocket.new/privacy_policy.html
- Terms of Service: https://expensetra7629.builtwithrocket.new/terms_of_service.html

### Support Contacts

- Technical Support: support@expensetracker.app
- Legal: legal@expensetracker.app
- Privacy: privacy@expensetracker.app

---

## Documentation Index

Refer to these guides for detailed information:

1. **ANDROID_RELEASE_SIGNING_GUIDE.md** - Android keystore and signing
2. **IOS_BUNDLE_ID_SETUP_GUIDE.md** - iOS Bundle ID and provisioning
3. **APP_STORE_CONNECT_GUIDE.md** - App Store submission
4. **PLAY_CONSOLE_SETUP_GUIDE.md** - Play Store submission
5. **BETA_TESTING_GUIDE.md** - TestFlight and internal testing
6. **RELEASE_NOTES_TEMPLATES.md** - Release notes examples
7. **SUBMISSION_READINESS_CHECKLIST.md** - Final submission checklist
8. **scripts/README.md** - Build automation documentation

---

**Last Updated:** February 21, 2026  
**Version:** 1.0.0