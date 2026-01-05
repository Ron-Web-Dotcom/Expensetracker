import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './expense_data_service.dart';

/// Service for exporting and managing app data
class DataExportService {
  final ExpenseDataService _expenseDataService = ExpenseDataService();

  /// Export transactions to CSV format
  Future<String> exportAsCSV({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    // Get real expense data
    List<Map<String, dynamic>> expenses;

    if (startDate != null && endDate != null) {
      expenses = await _expenseDataService.getExpensesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      expenses = await _expenseDataService.getAllExpenses();
    }

    // Filter by category if specified
    if (category != null && category != 'All Categories') {
      expenses = expenses.where((e) => e['category'] == category).toList();
    }

    // Build CSV content
    final buffer = StringBuffer();
    buffer.writeln('Date,Category,Amount,Description,Payment Method');

    for (var expense in expenses) {
      final date = DateFormat(
        'MM/dd/yyyy',
      ).format(DateTime.parse(expense['date']));
      final category = expense['category'];
      final amount = (expense['amount'] as num)
          .toDouble()
          .abs()
          .toStringAsFixed(2);
      final description = expense['description'] ?? '';
      final paymentMethod = expense['paymentMethod'];

      buffer.writeln(
        '"$date","$category","$amount","$description","$paymentMethod"',
      );
    }

    return buffer.toString();
  }

  /// Export transactions to PDF format
  Future<String> exportAsPDF({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    // Get real expense data
    List<Map<String, dynamic>> expenses;

    if (startDate != null && endDate != null) {
      expenses = await _expenseDataService.getExpensesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      expenses = await _expenseDataService.getAllExpenses();
    }

    // Filter by category if specified
    if (category != null && category != 'All Categories') {
      expenses = expenses.where((e) => e['category'] == category).toList();
    }

    // For now, return a placeholder path
    // In a real implementation, this would generate a PDF file
    return 'expense_report.pdf';
  }

  /// Backup all app data
  Future<String> backupData() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final backupData = <String, dynamic>{};
    for (var key in allKeys) {
      final value = prefs.get(key);
      backupData[key] = value;
    }

    backupData['transactions'] = _getSampleTransactions();
    backupData['backup_date'] = DateTime.now().toIso8601String();

    final jsonString = jsonEncode(backupData);

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Clear all app data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    final userName = prefs.getString('user_name') ?? '';
    final userEmail = prefs.getString('user_email') ?? '';

    await prefs.clear();

    await prefs.setBool('is_authenticated', isAuthenticated);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_email', userEmail);
  }

  /// Get sample transaction data
  List<Map<String, dynamic>> _getSampleTransactions() {
    return [
      {
        'date': DateFormat(
          'MM/dd/yyyy',
        ).format(DateTime.now().subtract(const Duration(days: 1))),
        'category': 'Food & Dining',
        'amount': '45.50',
        'description': 'Lunch at restaurant',
        'paymentMethod': 'Credit Card',
      },
      {
        'date': DateFormat(
          'MM/dd/yyyy',
        ).format(DateTime.now().subtract(const Duration(days: 2))),
        'category': 'Transportation',
        'amount': '25.00',
        'description': 'Uber ride',
        'paymentMethod': 'Debit Card',
      },
      {
        'date': DateFormat(
          'MM/dd/yyyy',
        ).format(DateTime.now().subtract(const Duration(days: 3))),
        'category': 'Shopping',
        'amount': '120.00',
        'description': 'Clothing purchase',
        'paymentMethod': 'Credit Card',
      },
      {
        'date': DateFormat(
          'MM/dd/yyyy',
        ).format(DateTime.now().subtract(const Duration(days: 5))),
        'category': 'Bills & Utilities',
        'amount': '85.00',
        'description': 'Internet bill',
        'paymentMethod': 'Bank Transfer',
      },
      {
        'date': DateFormat(
          'MM/dd/yyyy',
        ).format(DateTime.now().subtract(const Duration(days: 7))),
        'category': 'Entertainment',
        'amount': '35.00',
        'description': 'Movie tickets',
        'paymentMethod': 'Cash',
      },
    ];
  }

  /// Get user email for export
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? 'user@example.com';
  }

  /// Save user email
  Future<void> saveUserEmail(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', userEmail);
  }
}
