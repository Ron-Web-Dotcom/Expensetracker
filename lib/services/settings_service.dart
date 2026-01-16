import 'dart:convert';

import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/settings/settings.dart';

/// Service for managing app settings and preferences
class SettingsService {
  static const String _biometricKey = 'biometric_enabled';
  static const String _loginAlertsKey = 'login_alerts_enabled';
  static const String _themeKey = 'selected_theme';
  static const String _languageKey = 'selected_language';
  static const String _currencyKey = 'selected_currency';
  static const String _dateFormatKey = 'selected_date_format';
  static const String _numberFormatKey = 'selected_number_format';
  static const String _defaultCategoryKey = 'default_category';
  static const String _budgetAlertsKey = 'budget_alerts_enabled';
  static const String _weeklySummaryKey = 'weekly_summary_enabled';
  static const String _receiptRemindersKey = 'receipt_reminders_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  static const String _cloudBackupKey = 'cloud_backup_enabled';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _loginHistoryKey = 'login_history';
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const String _dailyReminderTimeKey = 'daily_reminder_time';

  final LocalAuthentication _localAuth = LocalAuthentication();

  // Security Settings
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricKey, enabled);
    } catch (e) {
      // Silent fail - storage quota exceeded or permissions denied
    }
  }

  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access ExpenseTracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoginAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginAlertsKey) ?? true;
  }

  Future<void> setLoginAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginAlertsKey, enabled);
  }

  Future<void> logLoginAttempt(bool success) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_loginHistoryKey);

    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }

    history.insert(0, {
      'timestamp': DateTime.now().toIso8601String(),
      'success': success,
      'device': 'Mobile',
    });

    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    await prefs.setString(_loginHistoryKey, jsonEncode(history));
  }

  Future<List<Map<String, dynamic>>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_loginHistoryKey);

    if (historyJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(historyJson));
  }

  // App Preferences
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'System';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English (US)';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'USD - United States Dollar';
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  Future<String> getDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dateFormatKey) ?? 'MM/DD/YYYY';
  }

  Future<void> setDateFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateFormatKey, format);
  }

  Future<String> getNumberFormat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_numberFormatKey) ?? '1,000.00';
  }

  Future<void> setNumberFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_numberFormatKey, format);
  }

  Future<String> getDefaultCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCategoryKey) ?? 'General';
  }

  Future<void> setDefaultCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCategoryKey, category);
  }

  // Notification Preferences
  Future<bool> isBudgetAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_budgetAlertsKey) ?? true;
  }

  Future<void> setBudgetAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertsKey, enabled);
  }

  Future<bool> isWeeklySummaryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weeklySummaryKey) ?? true;
  }

  Future<void> setWeeklySummaryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklySummaryKey, enabled);
  }

  Future<bool> isReceiptRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_receiptRemindersKey) ?? false;
  }

  Future<void> setReceiptRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_receiptRemindersKey, enabled);
  }

  Future<String> getQuietHoursStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_quietHoursStartKey) ?? '22:00';
  }

  Future<void> setQuietHoursStart(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quietHoursStartKey, time);
  }

  Future<String> getQuietHoursEnd() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_quietHoursEndKey) ?? '07:00';
  }

  Future<void> setQuietHoursEnd(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quietHoursEndKey, time);
  }

  // Daily Reminder Settings
  Future<bool> isDailyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dailyReminderEnabledKey) ?? false;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, enabled);
  }

  Future<String> getDailyReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyReminderTimeKey) ?? '19:00';
  }

  Future<void> setDailyReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyReminderTimeKey, time);
  }

  // Daily Reminder Types
  static const String _reminderTypesKey = 'reminder_types';

  Future<List<String>> getReminderTypes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_reminderTypesKey) ?? ['expense_logging'];
  }

  Future<void> setReminderTypes(List<String> types) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_reminderTypesKey, types);
  }

  // Data Management
  Future<bool> isCloudBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cloudBackupKey) ?? true;
  }

  Future<void> setCloudBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cloudBackupKey, enabled);
  }

  Future<String> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncTimeKey) ?? '2 hours ago';
  }

  Future<void> updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimeKey, 'Just now');
  }

  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Delete user account and all associated data
  Future<void> deleteUserAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('is_first_time', true);
    await prefs.setBool('has_seen_onboarding', false);
  }
}
