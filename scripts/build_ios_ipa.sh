#!/bin/bash

################################################################################
# ExpenseTracker - Automated iOS IPA Build Script
# 
# This script automates the process of building a signed iOS IPA file
# ready for App Store submission or TestFlight distribution.
#
# Prerequisites:
# - macOS with Xcode installed
# - Flutter SDK installed
# - Valid Apple Developer account
# - Signing certificates and provisioning profiles configured
#
# Usage:
#   chmod +x build_ios_ipa.sh
#   ./build_ios_ipa.sh
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
BUNDLE_ID="com.expensetracker.app"
SCHEME="Runner"
WORKSPACE="ios/Runner.xcworkspace"
CONFIGURATION="Release"
ARCHIVE_PATH="build/ios/Runner.xcarchive"
EXPORT_PATH="build/ios/ipa"
EXPORT_OPTIONS_PLIST="ios/ExportOptions.plist"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ExpenseTracker iOS IPA Builder${NC}"
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

if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed or command line tools not configured"
    exit 1
fi

print_success "All prerequisites met"
echo ""

# Display Flutter and Xcode versions
print_status "Environment Information:"
echo "  Flutter: $(flutter --version | head -n 1)"
echo "  Xcode: $(xcodebuild -version | head -n 1)"
echo ""

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
rm -rf build/ios
print_success "Clean complete"
echo ""

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
print_success "Dependencies retrieved"
echo ""

# Install CocoaPods dependencies
print_status "Installing iOS dependencies (CocoaPods)..."
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
print_success "iOS dependencies installed"
echo ""

# Build Flutter iOS release
print_status "Building Flutter iOS release..."
flutter build ios --release --no-codesign
print_success "Flutter build complete"
echo ""

# Create ExportOptions.plist if it doesn't exist
if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
    print_status "Creating ExportOptions.plist..."
    cat > "$EXPORT_OPTIONS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
EOF
    print_warning "ExportOptions.plist created with default values"
    print_warning "Please update YOUR_TEAM_ID in $EXPORT_OPTIONS_PLIST"
fi

# Create archive
print_status "Creating Xcode archive..."
xcodebuild -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    clean archive

if [ $? -eq 0 ]; then
    print_success "Archive created successfully"
else
    print_error "Archive creation failed"
    exit 1
fi
echo ""

# Export IPA
print_status "Exporting IPA..."
mkdir -p "$EXPORT_PATH"

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    print_success "IPA exported successfully"
else
    print_error "IPA export failed"
    exit 1
fi
echo ""

# Find the IPA file
IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)

if [ -z "$IPA_FILE" ]; then
    print_error "IPA file not found in export directory"
    exit 1
fi

# Get IPA file size
IPA_SIZE=$(du -h "$IPA_FILE" | cut -f1)

# Display results
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "IPA Location: $IPA_FILE"
echo "IPA Size: $IPA_SIZE"
echo ""
echo "Archive Location: $ARCHIVE_PATH"
echo ""

# Verify IPA
print_status "Verifying IPA..."
unzip -l "$IPA_FILE" | grep -q "Payload"
if [ $? -eq 0 ]; then
    print_success "IPA structure verified"
else
    print_warning "IPA structure verification failed"
fi
echo ""

# Next steps
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Test the IPA on a physical device"
echo "2. Upload to App Store Connect:"
echo "   xcrun altool --upload-app --type ios --file \"$IPA_FILE\" --username YOUR_APPLE_ID --password YOUR_APP_SPECIFIC_PASSWORD"
echo "3. Or use Xcode Organizer to upload"
echo "4. Submit for TestFlight beta testing"
echo ""

print_success "iOS IPA build process completed successfully!"
