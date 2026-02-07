import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;

import './core/app_export.dart';
import './routes/app_routes.dart';
import './services/certificate_pinning_service.dart';
import './services/crashlytics_service.dart';
import './services/notification_service.dart';
import './services/secure_storage_service.dart';
import './theme/app_theme.dart';
import './widgets/custom_error_widget.dart';

// Global ValueNotifier for theme changes
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

// Global ValueNotifier for locale changes
final ValueNotifier<Locale> localeNotifier = ValueNotifier(
  const Locale('en', 'US'),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Crashlytics
  final crashlytics = CrashlyticsService();
  await crashlytics.initialize();

  // Capture Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    crashlytics.recordFlutterError(details);
  };

  // Capture async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize secure storage FIRST (for encryption keys)
  final secureStorage = SecureStorageService();
  await secureStorage.initialize();

  // Initialize certificate pinning for future API calls
  final certificatePinning = CertificatePinningService();
  await certificatePinning.initialize();

  // Initialize timezone BEFORE notification service
  tz.initializeTimeZones();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Also log to crashlytics
    crashlytics.recordFlutterError(details);

    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadLocalePreference();
    // Listen to theme changes
    themeModeNotifier.addListener(_onThemeChanged);
    // Listen to locale changes
    localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChanged);
    localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {
      // Rebuild with new theme
    });
  }

  void _onLocaleChanged() {
    setState(() {
      // Rebuild with new locale
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themePref = prefs.getString('selected_theme') ?? 'System';

    final newThemeMode = switch (themePref) {
      'Light' => ThemeMode.light,
      'Dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    themeModeNotifier.value = newThemeMode;
  }

  Future<void> _loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('selected_language') ?? 'English (US)';
    localeNotifier.value = _getLocaleFromLanguage(language);
  }

  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'Spanish':
        return const Locale('es', 'ES');
      case 'French':
        return const Locale('fr', 'FR');
      case 'German':
        return const Locale('de', 'DE');
      case 'Chinese':
        return const Locale('zh', 'CN');
      case 'Japanese':
        return const Locale('ja', 'JP');
      default:
        return const Locale('en', 'US');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, child) {
            return ValueListenableBuilder<Locale>(
              valueListenable: localeNotifier,
              builder: (context, locale, child) {
                return MaterialApp(
                  title: 'expensetracker',
                  themeMode: themeMode,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  debugShowCheckedModeBanner: false,
                  initialRoute: AppRoutes.splash,
                  routes: AppRoutes.routes,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(1.0)),
                      child: child!,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}