import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './expense_notifier.dart';

class BudgetDataService {
  static const String _budgetsKey = 'budgets_data';
  static const String _totalBudgetKey = 'total_budget';
  final ExpenseNotifier _notifier = ExpenseNotifier();

  /// Save or update total budget
  Future<void> saveTotalBudget(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_totalBudgetKey, amount);

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
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_totalBudgetKey) ?? 0.0;
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
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString(_budgetsKey);

    List<Map<String, dynamic>> budgets = [];
    if (budgetsJson != null) {
      budgets = List<Map<String, dynamic>>.from(jsonDecode(budgetsJson));
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

    await prefs.setString(_budgetsKey, jsonEncode(budgets));

    // Notify all listeners that budget data has changed
    _notifier.notifyBudgetChanged();
  }

  /// Get all category budgets
  Future<List<Map<String, dynamic>>> getAllCategoryBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getString(_budgetsKey);

      if (budgetsJson == null) return [];

      return List<Map<String, dynamic>>.from(jsonDecode(budgetsJson));
    } catch (e) {
      // Return empty list if JSON decode fails or storage error
      return [];
    }
  }

  /// Delete a category budget
  Future<void> deleteCategoryBudget(String categoryName) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString(_budgetsKey);

    if (budgetsJson == null) return;

    List<Map<String, dynamic>> budgets = List<Map<String, dynamic>>.from(
      jsonDecode(budgetsJson),
    );

    budgets.removeWhere((b) => b['categoryName'] == categoryName);

    await prefs.setString(_budgetsKey, jsonEncode(budgets));

    // Notify all listeners that budget data has changed
    _notifier.notifyBudgetChanged();
  }

  /// Get spent amount for a category in a date range
  Future<double> getCategorySpentAmount({
    required String categoryName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('expenses_data');

    if (expensesJson == null) return 0.0;

    final expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesJson));

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
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('expenses_data');

    if (expensesJson == null) return 0.0;

    final expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesJson));

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_budgetsKey);
    await prefs.remove(_totalBudgetKey);
  }
}
