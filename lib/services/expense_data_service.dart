import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './expense_notifier.dart';

class ExpenseDataService {
  static const String _expensesKey = 'expenses_data';
  final ExpenseNotifier _notifier = ExpenseNotifier();

  /// Save a new expense
  Future<void> saveExpense({
    required double amount,
    required String category,
    required DateTime date,
    required String paymentMethod,
    String? description,
    List<String>? receiptPhotos,
    bool? hasLocation,
    String transactionType = 'expense',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);

    List<Map<String, dynamic>> expenses = [];
    if (expensesJson != null) {
      expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesJson));
    }

    final expense = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': transactionType == 'income' ? amount : -amount,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'description': description ?? '',
      'receiptPhotos': receiptPhotos ?? [],
      'hasLocation': hasLocation ?? false,
      'createdAt': DateTime.now().toIso8601String(),
      'transactionType': transactionType,
    };

    expenses.add(expense);
    await prefs.setString(_expensesKey, jsonEncode(expenses));

    // Notify all listeners that expense data has changed
    _notifier.notifyExpenseChanged();
  }

  /// Get all expenses
  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);

    if (expensesJson == null) return [];

    return List<Map<String, dynamic>>.from(jsonDecode(expensesJson));
  }

  /// Get expenses filtered by date range
  Future<List<Map<String, dynamic>>> getExpensesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allExpenses = await getAllExpenses();

    return allExpenses.where((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      return expenseDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expenseDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get total spending for a period
  Future<double> getTotalSpending({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await getExpensesByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    return expenses.fold<double>(0, (sum, expense) {
      final amount = ((expense['amount'] as num?) ?? 0).toDouble();
      // Only count negative amounts (expenses)
      return amount < 0 ? sum + amount.abs() : sum;
    });
  }

  /// Get spending by category for a period
  Future<Map<String, double>> getSpendingByCategory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await getExpensesByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      final category = expense['category'] as String;
      final amount = (expense['amount'] as num).toDouble();
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }

  /// Get daily spending for a period
  Future<Map<String, double>> getDailySpending({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await getExpensesByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final Map<String, double> dailyTotals = {};

    for (var expense in expenses) {
      final date = DateTime.parse(expense['date']);
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final amount = (expense['amount'] as num).toDouble();
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
    }

    return dailyTotals;
  }

  /// Clear all expenses (for testing or reset)
  Future<void> clearAllExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
    _notifier.notifyExpenseChanged();
  }

  /// Delete a specific expense by ID
  Future<void> deleteExpense(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey) ?? '[]';
    final List<dynamic> expenses = json.decode(expensesJson);

    expenses.removeWhere((expense) => expense['id'] == id);

    await prefs.setString(_expensesKey, json.encode(expenses));
    _notifier.notifyExpenseChanged();
  }

  Future<void> updateExpense({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String description,
    required List<String> receiptPhotos,
    required bool hasLocation,
    String transactionType = 'expense',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey) ?? '[]';
    final List<dynamic> expenses = json.decode(expensesJson);

    final index = expenses.indexWhere((expense) => expense['id'] == id);
    if (index != -1) {
      expenses[index] = {
        'id': id,
        'amount': transactionType == 'income' ? amount : -amount,
        'category': category,
        'date': date.toIso8601String(),
        'paymentMethod': paymentMethod,
        'description': description,
        'receiptPhotos': receiptPhotos,
        'hasLocation': hasLocation,
        'timestamp': DateTime.now().toIso8601String(),
        'transactionType': transactionType,
      };

      await prefs.setString(_expensesKey, json.encode(expenses));
      _notifier.notifyExpenseChanged();
    }
  }
}
