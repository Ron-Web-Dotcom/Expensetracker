# App Store Submission Checklist

## ✅ COMPLETED ITEMS

### Security & Privacy
- ✅ iOS Privacy Manifest (PrivacyInfo.xcprivacy) created
- ✅ Firebase Crashlytics integrated with web compatibility
- ✅ AES-256-GCM encryption for financial data
- ✅ Biometric authentication implemented
- ✅ Certificate pinning configured
- ✅ ProGuard rules for Android obfuscation
- ✅ iOS data protection (NSFileProtectionComplete)

### GDPR/CCPA Compliance
- ✅ Privacy Policy document created
- ✅ Terms of Service document created
- ✅ Data export feature (JSON format)
- ✅ Data deletion feature (right to be forgotten)
- ✅ Consent tracking system
- ✅ Legal Documents Viewer screen

### App Metadata
- ✅ App description updated in pubspec.yaml
- ✅ Version set to 1.0.0+1

### Technical Configuration
- ✅ Android package name: com.expensetracker.app
- ✅ Android minSdk: 23 (Android 6.0+)
- ✅ ProGuard enabled for release builds
- ✅ MultiDex enabled
- ✅ All permissions declared with descriptions

## ⚠️ REMAINING TASKS

### Android Release Signing (CRITICAL)
- ⚠️ Generate release keystore (see ANDROID_SIGNING_SETUP.md)
- ⚠️ Create android/key.properties file
- ⚠️ Test release build: `flutter build appbundle --release`

### iOS Configuration (CRITICAL)
- ⚠️ Set explicit Bundle ID in Xcode (currently uses variable)
- ⚠️ Set minimum deployment target: iOS 12.0 in Podfile
- ⚠️ Configure code signing certificates
- ⚠️ Create provisioning profiles
- ⚠️ Test archive build in Xcode

### App Store Assets
- ⚠️ Generate app icons (all required sizes)
  - iOS: 1024x1024, 180x180, 120x120, 87x87, 80x80, 60x60, 58x58, 40x40, 29x29
  - Android: Adaptive icons (192x192 foreground + background)
- ⚠️ Create screenshots (5-6 for iOS, 2-8 for Android)
- ⚠️ Create feature graphic for Play Store (1024x500)
- ⚠️ Prepare preview video (optional but recommended)

### Testing
- ⚠️ Write unit tests (target 60%+ coverage)
- ⚠️ Write widget tests for key screens
- ⚠️ Write integration tests for critical flows
- ⚠️ Setup TestFlight for iOS beta testing
- ⚠️ Setup Google Play internal testing
- ⚠️ Conduct accessibility audit
- ⚠️ Test on multiple devices (iOS and Android)

### Legal & Hosting
- ⚠️ Host Privacy Policy on web server (required by stores)
- ⚠️ Host Terms of Service on web server
- ⚠️ Add privacy policy URL to store listings
- ⚠️ Add support URL/email to store listings

### Store Accounts
- ⚠️ Apple Developer account ($99/year)
- ⚠️ Google Play Developer account ($25 one-time)

### Store Listings
- ⚠️ Complete App Store Connect metadata
- ⚠️ Complete Google Play Console metadata
- ⚠️ Select app category (Finance)
- ⚠️ Choose keywords for ASO
- ⚠️ Complete content rating questionnaire (IARC)
- ⚠️ Set pricing (Free recommended)
- ⚠️ Set availability (All countries recommended)

## 📋 NEXT STEPS

### Priority 1 (This Week)
1. Follow ANDROID_SIGNING_SETUP.md to configure release signing
2. Open ios/Runner.xcodeproj in Xcode and set Bundle ID
3. Set iOS deployment target to 12.0 in Podfile
4. Generate app icons using https://appicon.co/
5. Create 5-6 screenshots per platform

### Priority 2 (Next Week)
6. Write automated tests (unit, widget, integration)
7. Setup TestFlight and Play Store internal testing
8. Host legal documents on web server
9. Complete store metadata and listings
10. Submit for review

## 🚀 BUILD COMMANDS

### Android
```bash
# Release APK
flutter build apk --release

# Release AAB (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for device
flutter build ios --release

# Then archive in Xcode:
# Product → Archive → Upload to App Store Connect
```

## 📞 SUPPORT

For questions or issues:
- Review documentation in project root
- Check Flutter deployment guide: https://docs.flutter.dev/deployment
- Apple App Store guidelines: https://developer.apple.com/app-store/review/guidelines/
- Google Play policies: https://play.google.com/about/developer-content-policy/

## ⚠️ CRITICAL REMINDERS

1. **Keystore Security**: Backup your Android keystore in 3+ secure locations
2. **Privacy Manifest**: Required for iOS 17+ (already created)
3. **Crash Reporting**: Firebase Crashlytics integrated and ready
4. **Legal Compliance**: Privacy Policy and Terms must be hosted online
5. **Testing**: Beta test with real users before public launch

---

**Last Updated**: January 2026
**App Version**: 1.0.0+1
**Status**: Ready for final configuration and submission