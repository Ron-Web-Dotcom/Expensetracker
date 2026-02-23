#!/bin/bash

################################################################################
# ExpenseTracker - Automated Android AAB Build Script
# 
# This script automates the process of building a signed Android App Bundle (AAB)
# ready for Google Play Store submission.
#
# Prerequisites:
# - Flutter SDK installed
# - Android SDK installed
# - Java JDK 11+ installed
# - Keystore file configured (see ANDROID_RELEASE_SIGNING_GUIDE.md)
# - android/key.properties file configured
#
# Usage:
#   chmod +x build_android_aab.sh
#   ./build_android_aab.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ExpenseTracker"
PACKAGE_NAME="com.expensetracker.app"
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
KEY_PROPERTIES="android/key.properties"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ExpenseTracker Android AAB Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

if ! command -v java &> /dev/null; then
    print_error "Java is not installed or not in PATH"
    exit 1
fi

if ! command -v keytool &> /dev/null; then
    print_error "keytool is not available (part of Java JDK)"
    exit 1
fi

print_success "All prerequisites met"
echo ""

# Display environment information
print_status "Environment Information:"
echo "  Flutter: $(flutter --version | head -n 1)"
echo "  Java: $(java -version 2>&1 | head -n 1)"
echo ""

# Check for key.properties
if [ ! -f "$KEY_PROPERTIES" ]; then
    print_error "key.properties file not found at $KEY_PROPERTIES"
    print_error "Please create this file with your keystore configuration"
    print_error "See ANDROID_RELEASE_SIGNING_GUIDE.md for instructions"
    exit 1
fi

print_success "Keystore configuration found"
echo ""

# Verify keystore file exists
print_status "Verifying keystore file..."
KEYSTORE_PATH=$(grep "storeFile=" "$KEY_PROPERTIES" | cut -d'=' -f2)

if [ -z "$KEYSTORE_PATH" ]; then
    print_error "storeFile not found in key.properties"
    exit 1
fi

if [ ! -f "$KEYSTORE_PATH" ]; then
    print_error "Keystore file not found at: $KEYSTORE_PATH"
    print_error "Please check the storeFile path in key.properties"
    exit 1
fi

print_success "Keystore file verified: $KEYSTORE_PATH"
echo ""

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
rm -rf build/app/outputs
print_success "Clean complete"
echo ""

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
print_success "Dependencies retrieved"
echo ""

# Run code generation if needed
if grep -q "build_runner" pubspec.yaml; then
    print_status "Running code generation..."
    flutter pub run build_runner build --delete-conflicting-outputs
    print_success "Code generation complete"
    echo ""
fi

# Build Android App Bundle
print_status "Building Android App Bundle (AAB)..."
print_status "This may take several minutes..."
echo ""

flutter build appbundle --release

if [ $? -eq 0 ]; then
    print_success "AAB build complete"
else
    print_error "AAB build failed"
    exit 1
fi
echo ""

# Verify AAB file exists
if [ ! -f "$AAB_PATH" ]; then
    print_error "AAB file not found at expected location: $AAB_PATH"
    exit 1
fi

# Get AAB file size
AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)

# Verify AAB signature
print_status "Verifying AAB signature..."
jarsigner -verify -verbose -certs "$AAB_PATH" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "AAB signature verified"
else
    print_error "AAB signature verification failed"
    print_error "The AAB may not be properly signed"
    exit 1
fi
echo ""

# Extract signing information
print_status "Extracting signing information..."
KEY_ALIAS=$(grep "keyAlias=" "$KEY_PROPERTIES" | cut -d'=' -f2)
SIGNING_INFO=$(jarsigner -verify -verbose -certs "$AAB_PATH" 2>&1 | grep -A 5 "Signer #1")

echo "$SIGNING_INFO" | head -n 5
echo ""

# Display results
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "AAB Location: $AAB_PATH"
echo "AAB Size: $AAB_SIZE"
echo "Key Alias: $KEY_ALIAS"
echo ""

# Optional: Build universal APK for testing
read -p "Build universal APK for testing? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Building universal APK..."
    flutter build apk --release
    
    if [ $? -eq 0 ]; then
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        print_success "APK built successfully"
        echo "APK Location: $APK_PATH"
        echo "APK Size: $APK_SIZE"
    else
        print_warning "APK build failed"
    fi
    echo ""
fi

# Next steps
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Test the AAB:"
echo "   - Upload to Play Console Internal Testing track"
echo "   - Or use bundletool to generate APK for local testing"
echo ""
echo "2. Upload to Google Play Console:"
echo "   - Go to https://play.google.com/console/"
echo "   - Select your app"
echo "   - Production > Create new release"
echo "   - Upload: $AAB_PATH"
echo ""
echo "3. Complete release information:"
echo "   - Release notes"
echo "   - Review and rollout"
echo ""

# Optional: Generate bundletool commands
echo -e "${BLUE}Testing Commands:${NC}"
echo ""
echo "# Generate universal APK from AAB (for testing):"
echo "bundletool build-apks --bundle=$AAB_PATH --output=app.apks --mode=universal"
echo ""
echo "# Extract APK:"
echo "unzip -p app.apks universal.apk > app-universal.apk"
echo ""
echo "# Install on connected device:"
echo "adb install app-universal.apk"
echo ""

print_success "Android AAB build process completed successfully!"
