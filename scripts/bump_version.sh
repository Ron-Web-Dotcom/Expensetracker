#!/bin/bash

################################################################################
# ExpenseTracker - Automated Version Bumping Script
# 
# This script automates the process of incrementing version numbers across
# all necessary files for both iOS and Android platforms.
#
# Usage:
#   chmod +x bump_version.sh
#   ./bump_version.sh [major|minor|patch]
#
# Examples:
#   ./bump_version.sh patch   # 1.0.0 -> 1.0.1
#   ./bump_version.sh minor   # 1.0.0 -> 1.1.0
#   ./bump_version.sh major   # 1.0.0 -> 2.0.0
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ExpenseTracker Version Bumper${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print messages
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

# Check if bump type is provided
if [ -z "$1" ]; then
    print_error "Bump type not specified"
    echo "Usage: $0 [major|minor|patch]"
    echo ""
    echo "Examples:"
    echo "  $0 patch   # 1.0.0 -> 1.0.1"
    echo "  $0 minor   # 1.0.0 -> 1.1.0"
    echo "  $0 major   # 1.0.0 -> 2.0.0"
    exit 1
fi

BUMP_TYPE=$1

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    print_error "Invalid bump type: $BUMP_TYPE"
    echo "Must be one of: major, minor, patch"
    exit 1
fi

# Files to update
PUBSPEC_FILE="pubspec.yaml"
CHANGELOG_FILE="CHANGELOG.md"

# Check if files exist
if [ ! -f "$PUBSPEC_FILE" ]; then
    print_error "pubspec.yaml not found"
    exit 1
fi

# Extract current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/.*+//')

if [ -z "$CURRENT_VERSION" ]; then
    print_error "Could not extract current version from pubspec.yaml"
    exit 1
fi

print_status "Current version: $CURRENT_VERSION+$CURRENT_BUILD"

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Bump version based on type
case $BUMP_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
NEW_BUILD=$((CURRENT_BUILD + 1))

print_status "New version: $NEW_VERSION+$NEW_BUILD"
echo ""

# Confirm with user
read -p "Proceed with version bump? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Version bump cancelled"
    exit 0
fi

echo ""
print_status "Updating version numbers..."
echo ""

# Backup files
print_status "Creating backups..."
cp "$PUBSPEC_FILE" "${PUBSPEC_FILE}.backup"
if [ -f "$CHANGELOG_FILE" ]; then
    cp "$CHANGELOG_FILE" "${CHANGELOG_FILE}.backup"
fi
print_success "Backups created"

# Update pubspec.yaml
print_status "Updating pubspec.yaml..."
sed -i.tmp "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" "$PUBSPEC_FILE"
rm "${PUBSPEC_FILE}.tmp"
print_success "pubspec.yaml updated"

# Update CHANGELOG.md
if [ -f "$CHANGELOG_FILE" ]; then
    print_status "Updating CHANGELOG.md..."
    
    # Get current date
    CURRENT_DATE=$(date +"%Y-%m-%d")
    
    # Create new changelog entry
    NEW_ENTRY="## [$NEW_VERSION] - $CURRENT_DATE\n\n### Added\n- \n\n### Changed\n- \n\n### Fixed\n- \n\n"
    
    # Insert new entry at the top (after title)
    sed -i.tmp "3i\\\n$NEW_ENTRY" "$CHANGELOG_FILE"
    rm "${CHANGELOG_FILE}.tmp"
    
    print_success "CHANGELOG.md updated"
else
    print_warning "CHANGELOG.md not found, skipping"
fi

# Update iOS Info.plist
IOS_INFO_PLIST="ios/Runner/Info.plist"
if [ -f "$IOS_INFO_PLIST" ]; then
    print_status "Updating iOS Info.plist..."
    
    # Update CFBundleShortVersionString
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" "$IOS_INFO_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $NEW_VERSION" "$IOS_INFO_PLIST"
    
    # Update CFBundleVersion
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$IOS_INFO_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $NEW_BUILD" "$IOS_INFO_PLIST"
    
    print_success "iOS Info.plist updated"
else
    print_warning "iOS Info.plist not found, skipping"
fi

# Update Android build.gradle
ANDROID_BUILD_GRADLE="android/app/build.gradle"
if [ -f "$ANDROID_BUILD_GRADLE" ]; then
    print_status "Updating Android build.gradle..."
    
    # Update versionCode
    sed -i.tmp "s/versionCode .*/versionCode $NEW_BUILD/" "$ANDROID_BUILD_GRADLE"
    
    # Update versionName
    sed -i.tmp "s/versionName .*/versionName \"$NEW_VERSION\"/" "$ANDROID_BUILD_GRADLE"
    
    rm "${ANDROID_BUILD_GRADLE}.tmp"
    
    print_success "Android build.gradle updated"
else
    print_warning "Android build.gradle not found, skipping"
fi

echo ""
print_success "Version bump complete!"
echo ""

# Display summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Version Bump Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Old version: $CURRENT_VERSION+$CURRENT_BUILD"
echo "New version: $NEW_VERSION+$NEW_BUILD"
echo ""
echo "Files updated:"
echo "  ✓ pubspec.yaml"
[ -f "$CHANGELOG_FILE" ] && echo "  ✓ CHANGELOG.md"
[ -f "$IOS_INFO_PLIST" ] && echo "  ✓ ios/Runner/Info.plist"
[ -f "$ANDROID_BUILD_GRADLE" ] && echo "  ✓ android/app/build.gradle"
echo ""

# Git operations
if command -v git &> /dev/null && [ -d ".git" ]; then
    echo -e "${BLUE}Git Operations:${NC}"
    echo ""
    
    read -p "Create git commit? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add "$PUBSPEC_FILE"
        [ -f "$CHANGELOG_FILE" ] && git add "$CHANGELOG_FILE"
        [ -f "$IOS_INFO_PLIST" ] && git add "$IOS_INFO_PLIST"
        [ -f "$ANDROID_BUILD_GRADLE" ] && git add "$ANDROID_BUILD_GRADLE"
        
        git commit -m "chore: bump version to $NEW_VERSION+$NEW_BUILD"
        print_success "Git commit created"
        
        read -p "Create git tag? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -a "v$NEW_VERSION" -m "Version $NEW_VERSION"
            print_success "Git tag created: v$NEW_VERSION"
            echo ""
            print_status "To push changes and tag:"
            echo "  git push origin main"
            echo "  git push origin v$NEW_VERSION"
        fi
    fi
fi

echo ""
print_status "Next steps:"
echo "1. Update CHANGELOG.md with actual changes"
echo "2. Test the app thoroughly"
echo "3. Build release versions:"
echo "   - iOS: ./scripts/build_ios_ipa.sh"
echo "   - Android: ./scripts/build_android_aab.sh"
echo "4. Submit to app stores"
echo ""

print_success "Version bump completed successfully!"
