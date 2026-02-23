import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/expense_data_service.dart';
import '../services/budget_data_service.dart';
import '../services/secure_storage_service.dart';
import '../services/settings_service.dart';

class PrivacyService {
  static final PrivacyService _instance = PrivacyService._internal();
  factory PrivacyService() => _instance;
  PrivacyService._internal();

  final _expenseService = ExpenseDataService();
  final _budgetService = BudgetDataService();
  final _secureStorage = SecureStorageService();
  final _settingsService = SettingsService();

  /// Export all user data as JSON (GDPR Article 20 - Right to Data Portability)
  Future<String> exportUserData() async {
    try {
      final expenses = await _expenseService.getAllExpenses();
      final budgets = await _budgetService.getAllCategoryBudgets();
      final prefs = await SharedPreferences.getInstance();

      // Collect all settings
      final settings = {
        'theme_mode': prefs.getString('theme_mode'),
        'language': prefs.getString('language'),
        'currency': prefs.getString('currency'),
        'biometric_enabled': prefs.getBool('biometric_enabled'),
        'notifications_enabled': prefs.getBool('notifications_enabled'),
      };

      final exportData = {
        'export_info': {
          'exported_at': DateTime.now().toIso8601String(),
          'app_version': '1.0.0',
          'data_format': 'JSON',
        },
        'expenses': expenses,
        'budgets': budgets,
        'settings': settings,
        'data_summary': {
          'total_expenses': expenses.length,
          'total_budgets': budgets.length,
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

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset to default settings
      await _settingsService.resetToDefaults();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Request data collection consent (GDPR Article 7)
  Future<bool> requestDataCollectionConsent(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsented = prefs.getBool('data_collection_consent') ?? false;

    if (hasConsented) {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Data Collection Consent'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We collect and process the following data to provide you with expense tracking services:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Financial transaction data (expenses, budgets)',
                  ),
                  const Text('• Receipt images (stored locally)'),
                  const Text('• App preferences and settings'),
                  const Text('• Usage analytics (crashes, performance)'),
                  const SizedBox(height: 16),
                  const Text(
                    'All data is stored locally on your device with AES-256 encryption. We do not share your data with third parties.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You have the right to:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('• Access your data (export)'),
                  const Text('• Delete your data (right to be forgotten)'),
                  const Text('• Withdraw consent at any time'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Decline'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await prefs.setBool('data_collection_consent', true);
                  await prefs.setString(
                    'consent_timestamp',
                    DateTime.now().toIso8601String(),
                  );
                  Navigator.of(context).pop(true);
                },
                child: const Text('Accept'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Withdraw consent
  Future<void> withdrawConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('data_collection_consent', false);
    await prefs.setString(
      'consent_withdrawn_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  /// Check if user has consented
  Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('data_collection_consent') ?? false;
  }

  /// Get consent timestamp
  Future<String?> getConsentTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('consent_timestamp');
  }
}
