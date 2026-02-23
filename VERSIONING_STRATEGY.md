# Versioning Strategy

## Semantic Versioning

ExpenseTracker follows [Semantic Versioning 2.0.0](https://semver.org/)

### Version Format: MAJOR.MINOR.PATCH+BUILD

- **MAJOR**: Incompatible API changes or major feature overhauls
- **MINOR**: New features, backward-compatible
- **PATCH**: Bug fixes, backward-compatible
- **BUILD**: Build number (auto-incremented)

### Current Version: 1.0.0+1

## Version Update Guidelines

### MAJOR Version (X.0.0)

Increment when:
- Breaking changes to data models
- Complete UI/UX redesign
- Major architecture changes
- Removal of deprecated features
- Migration to new platform versions

**Example**: 1.0.0 → 2.0.0

### MINOR Version (0.X.0)

Increment when:
- New features added
- New screens/modules
- Enhanced existing features
- New integrations
- Performance improvements

**Example**: 1.0.0 → 1.1.0

### PATCH Version (0.0.X)

Increment when:
- Bug fixes
- Security patches
- UI tweaks
- Performance optimizations
- Documentation updates

**Example**: 1.0.0 → 1.0.1

### BUILD Number (+X)

Auto-increment for:
- Every build submitted to stores
- Internal testing builds
- Beta releases

**Example**: 1.0.0+1 → 1.0.0+2

## Version Update Process

### 1. Update pubspec.yaml

```yaml
version: 1.1.0+5  # version+build_number
```

### 2. Update CHANGELOG.md

```markdown
## [1.1.0] - 2026-02-15

### Added
- New analytics dashboard with insights
- Receipt scanning with OCR
- Budget alerts and notifications

### Changed
- Improved expense entry flow
- Enhanced dark mode colors

### Fixed
- Fixed crash on budget deletion
- Resolved memory leak in dashboard
```

### 3. Update App Store Metadata

- Update "What's New" section
- Update screenshots if UI changed
- Update app description if needed

### 4. Tag Release in Git

```bash
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0
```

## Release Channels

### Production (Stable)
- **Version**: 1.x.x
- **Audience**: All users
- **Testing**: Full QA + Beta testing
- **Frequency**: Monthly or as needed

### Beta (Testing)
- **Version**: 1.x.x-beta.x
- **Audience**: Beta testers
- **Testing**: Internal QA
- **Frequency**: Weekly

### Alpha (Development)
- **Version**: 1.x.x-alpha.x
- **Audience**: Internal team
- **Testing**: Basic smoke tests
- **Frequency**: Daily/as needed

## Version Naming Examples

```
1.0.0+1     - Initial release
1.0.1+2     - Bug fix release
1.1.0+3     - Feature release
1.1.1+4     - Patch release
2.0.0+5     - Major release
1.2.0-beta.1+6   - Beta release
1.2.0-alpha.1+7  - Alpha release
```

## Changelog Template

```markdown
# Changelog

All notable changes to ExpenseTracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Feature in development

### Changed
- Improvements in progress

### Fixed
- Bugs being addressed

## [1.0.0] - 2026-02-15

### Added
- Initial release
- Expense tracking
- Budget management
- Analytics dashboard
- Receipt scanning
- Biometric authentication
- Dark mode support
- GDPR compliance

### Security
- AES-256-GCM encryption
- Secure local storage
- Certificate pinning
```

## Build Number Management

### iOS (Info.plist)
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Android (build.gradle)
```gradle
defaultConfig {
    versionCode 1
    versionName "1.0.0"
}
```

### Flutter (pubspec.yaml)
```yaml
version: 1.0.0+1
```

## Pre-Release Checklist

- [ ] Update version in pubspec.yaml
- [ ] Update CHANGELOG.md
- [ ] Update README.md if needed
- [ ] Run all tests
- [ ] Test on physical devices
- [ ] Update App Store screenshots
- [ ] Update "What's New" text
- [ ] Create git tag
- [ ] Build release APK/AAB
- [ ] Build iOS archive
- [ ] Submit to TestFlight (iOS)
- [ ] Submit to Internal Testing (Android)
- [ ] Collect beta feedback
- [ ] Submit to production

## Version History

| Version | Release Date | Highlights |
|---------|-------------|------------|
| 1.0.0+1 | 2026-02-15 | Initial release with core features |

## Deprecation Policy

- Features marked as deprecated in version X.Y.0
- Will be removed in version (X+1).0.0
- Minimum 3 months notice before removal
- Migration guide provided in documentation

## Support Policy

- **Current Version**: Full support
- **Previous MINOR**: Security updates only
- **Older Versions**: No support

## Automated Versioning

### Using fastlane (iOS)
```ruby
increment_version_number(version_number: "1.1.0")
increment_build_number
```

### Using Gradle (Android)
```gradle
task incrementVersion {
    // Auto-increment logic
}
```

## Resources

- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Flutter Versioning](https://docs.flutter.dev/deployment/flavors)
