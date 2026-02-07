# Android Release Signing Configuration Guide

## CRITICAL: This file must be created before building release APK/AAB

## Step 1: Generate Release Keystore

Run this command in your terminal (replace values with your information):

```bash
keytool -genkey -v -keystore ~/expensetracker-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias expensetracker
```

You will be prompted for:
- Keystore password (SAVE THIS SECURELY)
- Key password (SAVE THIS SECURELY)
- Your name, organization, city, state, country

## Step 2: Create key.properties File

Create a file at `android/key.properties` with this content:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=expensetracker
storeFile=/absolute/path/to/expensetracker-release.jks
```

**IMPORTANT:**
- Replace YOUR_KEYSTORE_PASSWORD with the password you set in Step 1
- Replace YOUR_KEY_PASSWORD with the key password from Step 1
- Replace /absolute/path/to/ with the full path to your keystore file
- Example storeFile: /Users/yourname/expensetracker-release.jks (Mac/Linux)
- Example storeFile: C:\\Users\\yourname\\expensetracker-release.jks (Windows)

## Step 3: Secure Your Keystore

1. **Backup the keystore file** to a secure location (USB drive, password manager)
2. **Add key.properties to .gitignore** (already configured)
3. **NEVER commit** key.properties or the .jks file to version control
4. **Store passwords** in a password manager

## Step 4: Build Release APK/AAB

Once key.properties is configured:

```bash
# Build release APK
flutter build apk --release

# Build release AAB (recommended for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Verification

To verify your signing configuration:

```bash
# Check keystore details
keytool -list -v -keystore ~/expensetracker-release.jks -alias expensetracker

# Verify APK signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

**Error: "key.properties not found"**
- Ensure key.properties exists at `android/key.properties`
- Check file path is correct

**Error: "Keystore file not found"**
- Verify storeFile path in key.properties is absolute path
- Check file exists at specified location

**Error: "Invalid keystore format"**
- Regenerate keystore using command in Step 1
- Ensure using JDK keytool (not Android SDK keytool)

## Security Reminders

⚠️ **CRITICAL**: If you lose your keystore or passwords:
- You CANNOT update your app on Google Play Store
- You will need to publish as a new app with new package name
- All existing users will need to uninstall and reinstall

✅ **Best Practices**:
- Store keystore in 3+ secure locations
- Use strong, unique passwords
- Document passwords in password manager
- Never share keystore or passwords
- Keep backups encrypted