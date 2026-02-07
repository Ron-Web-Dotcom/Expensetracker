import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import './crashlytics_service.dart';

/// Mobile implementation using Firebase Crashlytics
class CrashlyticsServiceIO implements CrashlyticsServicePlatform {
  @override
  Future<void> initialize() async {
    // Enable Crashlytics collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  @override
  void recordFlutterError(FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  @override
  void recordError(dynamic error, StackTrace? stack, {bool fatal = false}) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }

  @override
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  @override
  void setUserIdentifier(String identifier) {
    FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }

  @override
  void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }
}

CrashlyticsServicePlatform getCrashlyticsServicePlatform() {
  return CrashlyticsServiceIO();
}
