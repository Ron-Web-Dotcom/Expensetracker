import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conditional imports for platform-specific implementations
import 'crashlytics_service_io.dart'
    if (dart.library.html) 'crashlytics_service_web.dart';

/// Platform-aware Crashlytics service
/// Uses real Firebase Crashlytics on mobile, console logging on web
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  late final CrashlyticsServicePlatform _platform;

  /// Initialize crashlytics service
  Future<void> initialize() async {
    _platform = getCrashlyticsServicePlatform();
    await _platform.initialize();
  }

  /// Record Flutter error
  void recordFlutterError(FlutterErrorDetails details) {
    _platform.recordFlutterError(details);
  }

  /// Record general error
  void recordError(dynamic error, StackTrace? stack, {bool fatal = false}) {
    _platform.recordError(error, stack, fatal: fatal);
  }

  /// Log message
  void log(String message) {
    _platform.log(message);
  }

  /// Set user identifier
  void setUserIdentifier(String identifier) {
    _platform.setUserIdentifier(identifier);
  }

  /// Set custom key
  void setCustomKey(String key, dynamic value) {
    _platform.setCustomKey(key, value);
  }
}

/// Abstract platform interface
abstract class CrashlyticsServicePlatform {
  Future<void> initialize();
  void recordFlutterError(FlutterErrorDetails details);
  void recordError(dynamic error, StackTrace? stack, {bool fatal = false});
  void log(String message);
  void setUserIdentifier(String identifier);
  void setCustomKey(String key, dynamic value);
}
