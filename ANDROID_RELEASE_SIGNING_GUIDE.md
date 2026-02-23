# Android Release Signing Setup Guide

## Complete Guide to Signing Your Android App for Production Release

This guide provides step-by-step instructions for creating a keystore, signing your Android app, and preparing it for Google Play Store submission.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Automated Keystore Generation](#automated-keystore-generation)
3. [Manual Keystore Generation](#manual-keystore-generation)
4. [Configure Signing in Android Project](#configure-signing-in-android-project)
5. [Build Signed Release AAB](#build-signed-release-aab)
6. [Verify Your Build](#verify-your-build)
7. [Security Best Practices](#security-best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Java Development Kit (JDK) 11 or higher installed
- Flutter SDK installed and configured
- Android Studio or Android SDK command-line tools
- Terminal/Command Prompt access

**Verify JDK Installation:**
```bash
java -version
keytool -help
```

---

## Automated Keystore Generation

### Option 1: Use Our Automated Script (Recommended)

We provide an automated script that generates a keystore with secure defaults.

**For macOS/Linux:**

```bash
#!/bin/bash
# Save this as: generate_keystore.sh

echo "========================================"
echo "ExpenseTracker Android Keystore Generator"
echo "========================================"
echo ""

# Configuration
KEYSTORE_NAME="expensetracker-release-key.jks"
KEY_ALIAS="expensetracker-key-alias"
VALIDITY_DAYS=10000
KEY_SIZE=2048
KEYSTORE_DIR="$HOME/.android/keystores"

# Create keystore directory if it doesn't exist
mkdir -p "$KEYSTORE_DIR"

echo "This script will generate a release keystore for your Android app."
echo "Please provide the following information:"
echo ""

# Collect information
read -p "Your Name: " USER_NAME
read -p "Organization Unit (e.g., Development): " ORG_UNIT
read -p "Organization Name (e.g., ExpenseTracker): " ORG_NAME
read -p "City: " CITY
read -p "State/Province: " STATE
read -p "Country Code (e.g., US): " COUNTRY

echo ""
read -sp "Keystore Password (min 6 characters): " KEYSTORE_PASSWORD
echo ""
read -sp "Confirm Keystore Password: " KEYSTORE_PASSWORD_CONFIRM
echo ""

if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords do not match!"
    exit 1
fi

if [ ${#KEYSTORE_PASSWORD} -lt 6 ]; then
    echo "Error: Password must be at least 6 characters!"
    exit 1
fi

read -sp "Key Password (min 6 characters, press Enter to use same as keystore): " KEY_PASSWORD
echo ""

if [ -z "$KEY_PASSWORD" ]; then
    KEY_PASSWORD="$KEYSTORE_PASSWORD"
fi

# Generate keystore
echo ""
echo "Generating keystore..."
echo ""

KEYSTORE_PATH="$KEYSTORE_DIR/$KEYSTORE_NAME"

keytool -genkeypair \
    -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize $KEY_SIZE \
    -validity $VALIDITY_DAYS \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$USER_NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generated successfully!"
    echo ""
    echo "Keystore Location: $KEYSTORE_PATH"
    echo "Key Alias: $KEY_ALIAS"
    echo ""
    echo "========================================"
    echo "IMPORTANT: Save this information securely!"
    echo "========================================"
    echo ""
    echo "Create android/key.properties file with:"
    echo ""
    echo "storePassword=$KEYSTORE_PASSWORD"
    echo "keyPassword=$KEY_PASSWORD"
    echo "keyAlias=$KEY_ALIAS"
    echo "storeFile=$KEYSTORE_PATH"
    echo ""
    echo "⚠️  CRITICAL: Back up your keystore file!"
    echo "⚠️  Store passwords in a secure password manager!"
    echo "⚠️  Never commit key.properties to version control!"
    echo ""
    
    # Verify keystore
    echo "Verifying keystore..."
    keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" | head -20
    
else
    echo "❌ Error: Keystore generation failed!"
    exit 1
fi
```

**For Windows (PowerShell):**

```powershell
# Save this as: generate_keystore.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ExpenseTracker Android Keystore Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$KEYSTORE_NAME = "expensetracker-release-key.jks"
$KEY_ALIAS = "expensetracker-key-alias"
$VALIDITY_DAYS = 10000
$KEY_SIZE = 2048
$KEYSTORE_DIR = "$env:USERPROFILE\.android\keystores"

# Create keystore directory
if (-not (Test-Path $KEYSTORE_DIR)) {
    New-Item -ItemType Directory -Path $KEYSTORE_DIR | Out-Null
}

Write-Host "This script will generate a release keystore for your Android app."
Write-Host "Please provide the following information:"
Write-Host ""

# Collect information
$USER_NAME = Read-Host "Your Name"
$ORG_UNIT = Read-Host "Organization Unit (e.g., Development)"
$ORG_NAME = Read-Host "Organization Name (e.g., ExpenseTracker)"
$CITY = Read-Host "City"
$STATE = Read-Host "State/Province"
$COUNTRY = Read-Host "Country Code (e.g., US)"

Write-Host ""
$KEYSTORE_PASSWORD = Read-Host "Keystore Password (min 6 characters)" -AsSecureString
$KEYSTORE_PASSWORD_CONFIRM = Read-Host "Confirm Keystore Password" -AsSecureString

$pwd1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($KEYSTORE_PASSWORD))
$pwd2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($KEYSTORE_PASSWORD_CONFIRM))

if ($pwd1 -ne $pwd2) {
    Write-Host "Error: Passwords do not match!" -ForegroundColor Red
    exit 1
}

if ($pwd1.Length -lt 6) {
    Write-Host "Error: Password must be at least 6 characters!" -ForegroundColor Red
    exit 1
}

$KEY_PASSWORD_INPUT = Read-Host "Key Password (press Enter to use same as keystore)" -AsSecureString
$KEY_PASSWORD = if ($KEY_PASSWORD_INPUT.Length -eq 0) { $pwd1 } else { [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($KEY_PASSWORD_INPUT)) }

# Generate keystore
Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor Yellow
Write-Host ""

$KEYSTORE_PATH = "$KEYSTORE_DIR\$KEYSTORE_NAME"

$dname = "CN=$USER_NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"

keytool -genkeypair `
    -v `
    -keystore "$KEYSTORE_PATH" `
    -alias "$KEY_ALIAS" `
    -keyalg RSA `
    -keysize $KEY_SIZE `
    -validity $VALIDITY_DAYS `
    -storepass "$pwd1" `
    -keypass "$KEY_PASSWORD" `
    -dname "$dname"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Keystore generated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keystore Location: $KEYSTORE_PATH" -ForegroundColor Cyan
    Write-Host "Key Alias: $KEY_ALIAS" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "IMPORTANT: Save this information securely!" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Create android/key.properties file with:"
    Write-Host ""
    Write-Host "storePassword=$pwd1"
    Write-Host "keyPassword=$KEY_PASSWORD"
    Write-Host "keyAlias=$KEY_ALIAS"
    Write-Host "storeFile=$KEYSTORE_PATH"
    Write-Host ""
    Write-Host "⚠️  CRITICAL: Back up your keystore file!" -ForegroundColor Red
    Write-Host "⚠️  Store passwords in a secure password manager!" -ForegroundColor Red
    Write-Host "⚠️  Never commit key.properties to version control!" -ForegroundColor Red
    
} else {
    Write-Host "❌ Error: Keystore generation failed!" -ForegroundColor Red
    exit 1
}
```

**Run the script:**

```bash
# macOS/Linux
chmod +x generate_keystore.sh
./generate_keystore.sh

# Windows PowerShell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\generate_keystore.ps1
```

---

## Manual Keystore Generation

If you prefer to generate the keystore manually:

```bash
keytool -genkeypair \
    -v \
    -keystore ~/expensetracker-release-key.jks \
    -alias expensetracker-key-alias \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000
```

**You will be prompted for:**
- Keystore password (remember this!)
- Key password (can be same as keystore password)
- Your name
- Organization unit (e.g., "Development")
- Organization name (e.g., "ExpenseTracker")
- City
- State/Province
- Country code (e.g., "US")

---

## Configure Signing in Android Project

### Step 1: Create key.properties File

Create a file at `android/key.properties` with your keystore information:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=expensetracker-key-alias
storeFile=/Users/yourname/.android/keystores/expensetracker-release-key.jks
```

**Important:**
- Use absolute path for `storeFile`
- Never commit this file to version control
- Add `key.properties` to `.gitignore`

### Step 2: Verify .gitignore

Ensure `android/.gitignore` contains:

```
key.properties
*.jks
*.keystore
```

### Step 3: Update build.gradle

Your `android/app/build.gradle` should already be configured (verify these sections exist):

```gradle
// Load keystore properties
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## Build Signed Release AAB

### Step 1: Clean Previous Builds

```bash
flutter clean
flutter pub get
```

### Step 2: Build Release AAB

```bash
flutter build appbundle --release
```

**Expected output:**
```
✓ Built build/app/outputs/bundle/release/app-release.aab (XX.XMB)
```

### Step 3: Locate Your AAB

Your signed AAB will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Verify Your Build

### Verify AAB Signature

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

**Expected output:**
```
jar verified.
```

### Check AAB Contents

```bash
bundletool build-apks \
    --bundle=build/app/outputs/bundle/release/app-release.aab \
    --output=app.apks \
    --mode=universal
```

### Verify Keystore Information

```bash
keytool -list -v -keystore /path/to/your/keystore.jks
```

---

## Security Best Practices

### 🔒 Critical Security Rules

1. **Never Commit Keystore Files**
   - Add `*.jks`, `*.keystore`, `key.properties` to `.gitignore`
   - Never upload to public repositories

2. **Backup Your Keystore**
   - Store in multiple secure locations
   - Use encrypted cloud storage
   - Keep offline backup on external drive
   - **You cannot recover a lost keystore!**

3. **Secure Password Storage**
   - Use a password manager (1Password, LastPass, Bitwarden)
   - Never store passwords in plain text
   - Use strong, unique passwords (16+ characters)

4. **Access Control**
   - Limit who has access to keystore
   - Use separate keystores for different apps
   - Rotate keys if compromised

5. **CI/CD Security**
   - Store keystore as encrypted secret
   - Use environment variables for passwords
   - Enable audit logging

### Recommended Backup Strategy

```bash
# Create encrypted backup
tar -czf keystore-backup.tar.gz expensetracker-release-key.jks key.properties
openssl enc -aes-256-cbc -salt -in keystore-backup.tar.gz -out keystore-backup.tar.gz.enc

# Store encrypted backup in:
# 1. Secure cloud storage (Google Drive, Dropbox with encryption)
# 2. External hard drive (offline)
# 3. Company secure vault
```

---

## Troubleshooting

### Error: "key.properties file not found"

**Solution:**
- Ensure `android/key.properties` exists
- Check file path is correct
- Verify file permissions

### Error: "Keystore was tampered with, or password was incorrect"

**Solution:**
- Verify password in `key.properties`
- Check keystore file path
- Ensure keystore file is not corrupted

### Error: "Failed to read key from keystore"

**Solution:**
- Verify `keyAlias` matches the one used during generation
- Check `keyPassword` is correct
- Run `keytool -list -v -keystore your-keystore.jks` to verify

### Error: "Build failed with ProGuard errors"

**Solution:**
- Check `android/app/proguard-rules.pro` for missing rules
- Add keep rules for reflection-based code
- Test with `minifyEnabled false` first

### Error: "Execution failed for task ':app:signReleaseBundle'"

**Solution:**
- Clean build: `flutter clean`
- Delete `build` folder
- Verify signing configuration in `build.gradle`
- Check keystore file permissions

### Build Succeeds But AAB Not Signed

**Solution:**
- Verify `signingConfigs.release` is set in `buildTypes.release`
- Check `key.properties` is loaded correctly
- Run with `--verbose` flag to see detailed logs

---

## Quick Reference Commands

```bash
# Generate keystore
keytool -genkeypair -v -keystore ~/keystore.jks -alias mykey -keyalg RSA -keysize 2048 -validity 10000

# List keystore contents
keytool -list -v -keystore ~/keystore.jks

# Verify AAB signature
jarsigner -verify -verbose -certs app-release.aab

# Build release AAB
flutter build appbundle --release

# Build release APK (for testing)
flutter build apk --release

# Clean build
flutter clean && flutter pub get
```

---

## Next Steps

After successfully building your signed AAB:

1. ✅ Test the AAB on a physical device
2. ✅ Upload to Google Play Console (Internal Testing first)
3. ✅ Complete store listing metadata
4. ✅ Submit for review

Refer to:
- `PLAY_CONSOLE_SETUP_GUIDE.md` for store configuration
- `BETA_TESTING_GUIDE.md` for testing distribution
- `SUBMISSION_READINESS_CHECKLIST.md` for final checks

---

## Support

If you encounter issues:
- Check Flutter documentation: https://docs.flutter.dev/deployment/android
- Android signing docs: https://developer.android.com/studio/publish/app-signing
- Contact support: support@expensetracker.app

---

**Last Updated:** February 21, 2026  
**Version:** 1.0.0