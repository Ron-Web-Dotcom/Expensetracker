# Beta Testing Setup Guide

## Overview

This guide covers setting up beta testing for ExpenseTracker on both iOS (TestFlight) and Android (Google Play Internal Testing).

---

## iOS Beta Testing with TestFlight

### Prerequisites

- Apple Developer Account ($99/year)
- Xcode installed on macOS
- Valid provisioning profiles
- App Store Connect access

### Step 1: Configure App in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Set Bundle Identifier: `com.expensetracker.app`
4. Set Version: `1.0.0`
5. Set Build: `1`
6. Select Team in Signing & Capabilities

### Step 2: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Fill in details:
   - **Platform**: iOS
   - **Name**: ExpenseTracker
   - **Primary Language**: English
   - **Bundle ID**: com.expensetracker.app
   - **SKU**: expensetracker-ios
4. Click "Create"

### Step 3: Build and Archive

```bash
# Clean build
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device" as destination
2. Product → Archive
3. Wait for archive to complete
4. Click "Distribute App"
5. Select "App Store Connect"
6. Select "Upload"
7. Follow prompts to upload

### Step 4: Configure TestFlight

1. In App Store Connect, go to your app
2. Click "TestFlight" tab
3. Wait for build to process (10-30 minutes)
4. Once processed, click on build number
5. Fill in "What to Test" notes
6. Add Export Compliance: "No" (if no encryption)
7. Click "Submit for Review" (first build only)

### Step 5: Add Beta Testers

#### Internal Testing (Up to 100 testers)

1. Go to TestFlight → Internal Testing
2. Click "+" to add testers
3. Enter email addresses
4. Testers receive email invitation
5. They install TestFlight app and accept

#### External Testing (Up to 10,000 testers)

1. Go to TestFlight → External Testing
2. Create new group
3. Add testers via email or public link
4. Submit for Beta App Review (first time)
5. Approval takes 24-48 hours

### Step 6: Distribute Updates

```bash
# Increment build number in pubspec.yaml
version: 1.0.0+2

# Build and upload new version
flutter build ios --release
# Archive and upload in Xcode
```

Testers automatically get update notifications.

---

## Android Beta Testing with Google Play

### Prerequisites

- Google Play Developer Account ($25 one-time)
- Android signing keystore
- Google Play Console access

### Step 1: Generate Release Keystore

```bash
# Generate keystore
keytool -genkey -v -keystore ~/expensetracker-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias expensetracker

# Enter password and details when prompted
```

### Step 2: Configure Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=expensetracker
storeFile=../expensetracker-release.jks
```

**IMPORTANT**: Add to `.gitignore`:
```
android/key.properties
*.jks
```

### Step 3: Create App in Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in details:
   - **App name**: ExpenseTracker
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free
4. Accept declarations
5. Click "Create app"

### Step 4: Complete Store Listing

1. Go to "Store presence" → "Main store listing"
2. Fill in:
   - **Short description** (80 chars max)
   - **Full description** (4000 chars max)
   - **App icon** (512x512 PNG)
   - **Feature graphic** (1024x500 PNG)
   - **Screenshots** (2-8 images)
   - **App category**: Finance
3. Save

### Step 5: Set Up Internal Testing

1. Go to "Testing" → "Internal testing"
2. Click "Create new release"
3. Upload AAB:

```bash
# Build release AAB
flutter build appbundle --release

# File location:
# build/app/outputs/bundle/release/app-release.aab
```

4. Upload `app-release.aab`
5. Add release notes
6. Click "Save" then "Review release"
7. Click "Start rollout to Internal testing"

### Step 6: Add Testers

#### Internal Testing (Up to 100 testers)

1. Go to "Testing" → "Internal testing"
2. Click "Testers" tab
3. Create email list:
   - Click "Create email list"
   - Add tester emails
   - Save
4. Copy testing link
5. Share link with testers

#### Closed Testing (Unlimited testers)

1. Go to "Testing" → "Closed testing"
2. Create new track
3. Upload AAB
4. Add testers via email lists or Google Groups
5. Testers opt-in via Play Store link

#### Open Testing (Public beta)

1. Go to "Testing" → "Open testing"
2. Upload AAB
3. Anyone can join via Play Store
4. Set country availability

### Step 7: Distribute Updates

```bash
# Increment version in pubspec.yaml
version: 1.0.1+2

# Build new AAB
flutter build appbundle --release

# Upload to Play Console
# Go to Internal testing → Create new release
```

---

## Beta Testing Best Practices

### 1. Test Group Composition

- **Internal**: Development team (5-10 people)
- **Closed**: Trusted users (50-100 people)
- **Open**: Public volunteers (500+ people)

### 2. Testing Phases

**Phase 1: Internal (1 week)**
- Core functionality
- Critical bugs
- Performance issues

**Phase 2: Closed (2 weeks)**
- User experience
- Edge cases
- Device compatibility

**Phase 3: Open (2-4 weeks)**
- Scale testing
- Final polish
- Store readiness

### 3. Feedback Collection

#### In-App Feedback

```dart
// Add feedback button in settings
ElevatedButton(
  onPressed: () {
    // Open email or feedback form
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'feedback@expensetracker.com',
      query: 'subject=Beta Feedback&body=Version: 1.0.0+1',
    );
    launchUrl(emailUri);
  },
  child: Text('Send Feedback'),
)
```

#### External Tools

- **TestFlight**: Built-in feedback
- **Google Forms**: Custom surveys
- **Firebase Crashlytics**: Crash reports
- **Slack/Discord**: Community channels

### 4. Release Notes Template

```markdown
## Version 1.0.0 (Build 1) - Beta

### What's New
- Initial beta release
- Expense tracking
- Budget management
- Analytics dashboard

### Known Issues
- Receipt scanning may be slow on older devices
- Dark mode colors being refined

### What to Test
- Add expenses and verify they appear correctly
- Set budgets and check alert notifications
- Test biometric authentication
- Try exporting data

### How to Report Issues
- Use TestFlight feedback (iOS)
- Email: beta@expensetracker.com
- Include: Device model, OS version, steps to reproduce
```

### 5. Monitoring Beta Performance

#### Key Metrics

- **Crash-free rate**: Target 99%+
- **Session duration**: Track engagement
- **Feature adoption**: Which features are used
- **Feedback volume**: Issues reported

#### Tools

- Firebase Crashlytics
- Google Analytics
- App Store Connect Analytics
- Play Console Statistics

---

## Troubleshooting

### iOS Issues

**Issue**: Archive fails with signing error
**Solution**: Check provisioning profiles in Xcode

**Issue**: Build stuck in "Processing"
**Solution**: Wait 24 hours, contact Apple Support if persists

**Issue**: TestFlight invite not received
**Solution**: Check spam folder, resend invitation

### Android Issues

**Issue**: Upload rejected due to signing
**Solution**: Verify key.properties configuration

**Issue**: "App not available in your country"
**Solution**: Check country availability in Play Console

**Issue**: Testers can't find app
**Solution**: Ensure they're using the testing link, not searching Play Store

---

## Graduation to Production

### Criteria for Production Release

- [ ] 99%+ crash-free rate
- [ ] All critical bugs fixed
- [ ] Positive feedback from 80%+ testers
- [ ] Performance metrics meet targets
- [ ] All store requirements met
- [ ] Legal documents finalized
- [ ] Marketing materials ready

### Production Release Process

#### iOS

1. In App Store Connect, go to "App Store" tab
2. Click "+" to create new version
3. Fill in metadata and screenshots
4. Select build from TestFlight
5. Submit for review
6. Wait 24-48 hours for approval

#### Android

1. In Play Console, go to "Production"
2. Create new release
3. Upload same AAB from testing
4. Add release notes
5. Review and rollout
6. Gradual rollout: 10% → 50% → 100%

---

## Resources

- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Google Play Testing Guide](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
