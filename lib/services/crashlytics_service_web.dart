import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import './crashlytics_service.dart';

/// Web implementation using console logging
class CrashlyticsServiceWeb implements CrashlyticsServicePlatform {
  @override
  Future<void> initialize() async {
    developer.log('Crashlytics initialized (Web - Console Logging Mode)');
  }

  @override
  void recordFlutterError(FlutterErrorDetails details) {
    developer.log(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
      name: 'CrashlyticsWeb',
    );
  }

  @override
  void recordError(dynamic error, StackTrace? stack, {bool fatal = false}) {
    developer.log(
      'Error (${fatal ? "FATAL" : "NON-FATAL"}): $error',
      error: error,
      stackTrace: stack,
      name: 'CrashlyticsWeb',
    );
  }

  @override
  void log(String message) {
    developer.log(message, name: 'CrashlyticsWeb');
  }

  @override
  void setUserIdentifier(String identifier) {
    developer.log('User Identifier: $identifier', name: 'CrashlyticsWeb');
  }

  @override
  void setCustomKey(String key, dynamic value) {
    developer.log('Custom Key: $key = $value', name: 'CrashlyticsWeb');
  }
}

CrashlyticsServicePlatform getCrashlyticsServicePlatform() {
  return CrashlyticsServiceWeb();
}
