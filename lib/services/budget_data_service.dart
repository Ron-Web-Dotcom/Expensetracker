import 'dart:convert';
import './expense_notifier.dart';
import './secure_storage_service.dart';

class BudgetDataService {
  static const String _budgetsKey = 'budgets_data';
  static const String _totalBudgetKey = 'total_budget';
  final ExpenseNotifier _notifier = ExpenseNotifier();
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Save or update total budget
  Future<void> saveTotalBudget(double amount) async {
    try {
      // Save encrypted budget amount
      await _secureStorage.saveEncrypted(_totalBudgetKey, amount.toString());

      // Notify all listeners that budget data has changed
      _notifier.notifyBudgetChanged();
    } catch (e) {
      // Silent fail - storage quota exceeded or permissions denied
      rethrow;
    }
  }

  /// Get total budget
  Future<double> getTotalBudget() async {
    try {
      final encryptedAmount = await _secureStorage.readEncrypted(
        _totalBudgetKey,
      );
      if (encryptedAmount == null) return 0.0;
      return double.tryParse(encryptedAmount) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Save or update a category budget
  Future<void> saveCategoryBudget({
    required String categoryName,
    required String iconName,
    required String colorHex,
    required double budgetLimit,
  }) async {
    // Read encrypted budgets
    final encryptedJson = await _secureStorage.readEncrypted(_budgetsKey);

    List<Map<String, dynamic>> budgets = [];
    if (encryptedJson != null) {
      budgets = List<Map<String, dynamic>>.from(jsonDecode(encryptedJson));
    }

    // Check if category already exists
    final existingIndex = budgets.indexWhere(
      (b) => b['categoryName'] == categoryName,
    );

    final budget = {
      'categoryName': categoryName,
      'iconName': iconName,
      'colorHex': colorHex,
      'budgetLimit': budgetLimit,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (existingIndex >= 0) {
      budgets[existingIndex] = budget;
    } else {
      budgets.add(budget);
    }

    // Save encrypted budgets
    await _secureStorage.saveEncrypted(_budgetsKey, jsonEncode(budgets));

    // Notify all listeners that budget data has changed
    _notifier.notifyBudgetChanged();
  }

  /// Get all category budgets
  Future<List<Map<String, dynamic>>> getAllCategoryBudgets() async {
    try {
      // Read encrypted budgets
      final encryptedJson = await _secureStorage.readEncrypted(_budgetsKey);

      if (encryptedJson == null) return [];

      return List<Map<String, dynamic>>.from(jsonDecode(encryptedJson));
    } catch (e) {
      // Return empty list if JSON decode fails or storage error
      return [];
    }
  }

  /// Delete a category budget
  Future<void> deleteCategoryBudget(String categoryName) async {
    // Read encrypted budgets
    final encryptedJson = await _secureStorage.readEncrypted(_budgetsKey);

    if (encryptedJson == null) return;

    List<Map<String, dynamic>> budgets = List<Map<String, dynamic>>.from(
      jsonDecode(encryptedJson),
    );

    budgets.removeWhere((b) => b['categoryName'] == categoryName);

    // Save encrypted budgets
    await _secureStorage.saveEncrypted(_budgetsKey, jsonEncode(budgets));

    // Notify all listeners that budget data has changed
    _notifier.notifyBudgetChanged();
  }

  /// Get spent amount for a category in a date range
  Future<double> getCategorySpentAmount({
    required String categoryName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Read encrypted expenses
    final encryptedJson = await _secureStorage.readEncrypted('expenses_data');

    if (encryptedJson == null) return 0.0;

    final expenses = List<Map<String, dynamic>>.from(jsonDecode(encryptedJson));

    double total = 0.0;
    for (var expense in expenses) {
      final expenseDate = DateTime.parse(expense['date']);
      final expenseCategory = expense['category'] as String;

      if (expenseCategory == categoryName &&
          expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expenseDate.isBefore(endDate.add(const Duration(days: 1)))) {
        total += (expense['amount'] as num).toDouble();
      }
    }

    return total;
  }

  /// Get total spent amount in a date range
  Future<double> getTotalSpentAmount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Read encrypted expenses
    final encryptedJson = await _secureStorage.readEncrypted('expenses_data');

    if (encryptedJson == null) return 0.0;

    final expenses = List<Map<String, dynamic>>.from(jsonDecode(encryptedJson));

    double total = 0.0;
    for (var expense in expenses) {
      final expenseDate = DateTime.parse(expense['date']);

      if (expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expenseDate.isBefore(endDate.add(const Duration(days: 1)))) {
        total += (expense['amount'] as num).toDouble();
      }
    }

    return total;
  }

  /// Clear all budgets (for testing or reset)
  Future<void> clearAllBudgets() async {
    await _secureStorage.removeEncrypted(_budgetsKey);
    await _secureStorage.removeEncrypted(_totalBudgetKey);
  }
}
