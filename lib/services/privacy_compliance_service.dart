import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/expense_data_service.dart';
import '../services/budget_data_service.dart';
import '../services/secure_storage_service.dart';

/// GDPR/CCPA compliance service for data privacy management
class PrivacyComplianceService {
  static final PrivacyComplianceService _instance =
      PrivacyComplianceService._internal();
  factory PrivacyComplianceService() => _instance;
  PrivacyComplianceService._internal();

  final _expenseService = ExpenseDataService();
  final _budgetService = BudgetDataService();
  final _secureStorage = SecureStorageService();

  /// Export all user data as JSON (GDPR Article 15 - Right to Access)
  Future<String> exportAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Collect all data
      final expenses = await _expenseService.getAllExpenses();
      final budgets = await _budgetService.getAllCategoryBudgets();

      // Get settings data
      final settings = {
        'theme_mode': prefs.getString('theme_mode'),
        'language': prefs.getString('language'),
        'currency': prefs.getString('currency'),
        'biometric_enabled': prefs.getBool('biometric_enabled'),
        'notifications_enabled': prefs.getBool('notifications_enabled'),
      };

      // Get analytics preferences
      final analyticsConsent = prefs.getBool('analytics_consent') ?? false;
      final crashReportingConsent =
          prefs.getBool('crash_reporting_consent') ?? true;

      // Compile complete data export
      final exportData = {
        'export_metadata': {
          'exported_at': DateTime.now().toIso8601String(),
          'app_version': '1.0.0',
          'data_format': 'JSON',
        },
        'personal_data': {
          'expenses': expenses,
          'budgets': budgets,
          'settings': settings,
        },
        'privacy_preferences': {
          'analytics_consent': analyticsConsent,
          'crash_reporting_consent': crashReportingConsent,
          'data_collection_consent_date': prefs.getString('consent_date'),
        },
        'data_retention': {
          'total_expenses': expenses.length,
          'total_budgets': budgets.length,
          'account_created': prefs.getString('account_created_date'),
        },
      };

      return const JsonEncoder.withIndent('  ').convert(exportData);
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }

  /// Delete all user data (GDPR Article 17 - Right to Erasure)
  Future<void> deleteAllUserData() async {
    try {
      // Delete expenses
      final expenses = await _expenseService.getAllExpenses();
      for (var expense in expenses) {
        await _expenseService.deleteExpense(expense['id']);
      }

      // Delete budgets
      final budgets = await _budgetService.getAllCategoryBudgets();
      for (var budget in budgets) {
        await _budgetService.deleteCategoryBudget(budget['categoryName']);
      }

      // Clear secure storage
      await _secureStorage.clearAllKeys();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Log deletion for audit trail
      await _logDataDeletion();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Request data deletion with confirmation
  Future<bool> requestDataDeletion(String confirmationText) async {
    if (confirmationText.toLowerCase() != 'delete my data') {
      return false;
    }

    await deleteAllUserData();
    return true;
  }

  /// Get user consent status
  Future<Map<String, bool>> getConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'analytics_consent': prefs.getBool('analytics_consent') ?? false,
      'crash_reporting_consent':
          prefs.getBool('crash_reporting_consent') ?? true,
      'data_collection_consent':
          prefs.getBool('data_collection_consent') ?? true,
    };
  }

  /// Update consent preferences (GDPR Article 7 - Consent)
  Future<void> updateConsent({
    bool? analyticsConsent,
    bool? crashReportingConsent,
    bool? dataCollectionConsent,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (analyticsConsent != null) {
      await prefs.setBool('analytics_consent', analyticsConsent);
    }

    if (crashReportingConsent != null) {
      await prefs.setBool('crash_reporting_consent', crashReportingConsent);
    }

    if (dataCollectionConsent != null) {
      await prefs.setBool('data_collection_consent', dataCollectionConsent);
    }

    // Record consent update timestamp
    await prefs.setString(
      'consent_updated_at',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get consent history
  Future<List<Map<String, dynamic>>> getConsentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('consent_history') ?? '[]';
    final history = jsonDecode(historyJson) as List;
    return history.cast<Map<String, dynamic>>();
  }

  /// Record consent change in history
  Future<void> recordConsentChange(String consentType, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getConsentHistory();

    history.add({
      'type': consentType,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString('consent_history', jsonEncode(history));
  }

  /// Check if user has given initial consent
  Future<bool> hasGivenInitialConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('initial_consent_given') ?? false;
  }

  /// Record initial consent
  Future<void> recordInitialConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('initial_consent_given', true);
    await prefs.setString('consent_date', DateTime.now().toIso8601String());
  }

  /// Get data retention period
  Future<String> getDataRetentionInfo() async {
    return 'Your data is stored locally on your device and is retained until you delete the app or request data deletion. '
        'We do not transmit your financial data to external servers. '
        'Receipt images and expense records are encrypted using AES-256-GCM encryption.';
  }

  /// Log data deletion for audit purposes
  Future<void> _logDataDeletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_data_deletion',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get privacy manifest data
  Future<Map<String, dynamic>> getPrivacyManifest() async {
    return {
      'data_collection': {
        'financial_info': {
          'collected': true,
          'purpose': 'App functionality - expense tracking',
          'linked_to_user': false,
          'used_for_tracking': false,
        },
        'photos': {
          'collected': true,
          'purpose': 'App functionality - receipt scanning',
          'linked_to_user': false,
          'used_for_tracking': false,
        },
        'usage_data': {
          'collected': true,
          'purpose': 'Analytics and app functionality',
          'linked_to_user': false,
          'used_for_tracking': false,
        },
      },
      'data_storage': {
        'location': 'Local device only',
        'encryption': 'AES-256-GCM',
        'backup': 'iOS secure backup with NSFileProtectionComplete',
      },
      'third_party_sharing': {
        'shared': false,
        'details': 'No data is shared with third parties',
      },
    };
  }
}
