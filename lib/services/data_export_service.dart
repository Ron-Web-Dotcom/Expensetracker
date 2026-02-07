import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import './expense_data_service.dart';

/// Service for exporting and managing app data
class DataExportService {
  final ExpenseDataService _expenseDataService = ExpenseDataService();

  /// Export transactions to CSV format
  Future<String> exportAsCSV({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? paymentMethod,
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

    // Filter by payment method if specified
    if (paymentMethod != null && paymentMethod != 'All') {
      expenses = expenses
          .where((e) => e['paymentMethod'] == paymentMethod)
          .toList();
    }

    // Build CSV content
    final buffer = StringBuffer();
    buffer.writeln('Date,Category,Amount,Description,Payment Method');

    for (var expense in expenses) {
      final date = DateFormat(
        'MM/dd/yyyy',
      ).format(DateTime.parse(expense['date']));
      final categoryVal = expense['category'];
      final amount = (expense['amount'] as num)
          .toDouble()
          .abs()
          .toStringAsFixed(2);
      final description = (expense['description'] ?? '').replaceAll('"', '""');
      final paymentMethodVal = expense['paymentMethod'];

      buffer.writeln(
        '"$date","$categoryVal","$amount","$description","$paymentMethodVal"',
      );
    }

    final csvContent = buffer.toString();
    final fileName =
        'expense_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';

    // Platform-specific file saving
    if (kIsWeb) {
      // Web: Trigger browser download
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return fileName;
    } else {
      // Mobile: Save to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);
      return file.path;
    }
  }

  /// Export transactions to PDF format
  Future<String> exportAsPDF({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? paymentMethod,
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

    // Filter by payment method if specified
    if (paymentMethod != null && paymentMethod != 'All') {
      expenses = expenses
          .where((e) => e['paymentMethod'] == paymentMethod)
          .toList();
    }

    // Calculate summary statistics
    final totalExpenses = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense['amount'] as num).toDouble().abs(),
    );

    final categoryBreakdown = <String, double>{};
    for (var expense in expenses) {
      final cat = expense['category'] as String;
      final amount = (expense['amount'] as num).toDouble().abs();
      categoryBreakdown[cat] = (categoryBreakdown[cat] ?? 0.0) + amount;
    }

    // Build PDF-like text content (simplified format)
    final buffer = StringBuffer();
    buffer.writeln('EXPENSE REPORT');
    buffer.writeln('=' * 50);
    buffer.writeln(
      'Generated: ${DateFormat('MM/dd/yyyy HH:mm').format(DateTime.now())}',
    );
    if (startDate != null && endDate != null) {
      buffer.writeln(
        'Period: ${DateFormat('MM/dd/yyyy').format(startDate)} - ${DateFormat('MM/dd/yyyy').format(endDate)}',
      );
    }
    if (category != null) {
      buffer.writeln('Category Filter: $category');
    }
    if (paymentMethod != null) {
      buffer.writeln('Payment Method Filter: $paymentMethod');
    }
    buffer.writeln('\nSUMMARY');
    buffer.writeln('-' * 50);
    buffer.writeln('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}');
    buffer.writeln('Number of Transactions: ${expenses.length}');
    buffer.writeln('\nCATEGORY BREAKDOWN');
    buffer.writeln('-' * 50);
    categoryBreakdown.forEach((cat, amount) {
      final percentage = totalExpenses > 0
          ? ((amount / totalExpenses) * 100).toStringAsFixed(1)
          : '0.0';
      buffer.writeln('$cat: \$${amount.toStringAsFixed(2)} ($percentage%)');
    });
    buffer.writeln('\nTRANSACTIONS');
    buffer.writeln('-' * 50);
    buffer.writeln(
      'Date'.padRight(12) +
          'Category'.padRight(20) +
          'Amount'.padRight(12) +
          'Payment',
    );
    buffer.writeln('-' * 50);

    for (var expense in expenses) {
      final date = DateFormat(
        'MM/dd/yyyy',
      ).format(DateTime.parse(expense['date']));
      final cat = (expense['category'] as String).padRight(20);
      final amount =
          '\$${(expense['amount'] as num).toDouble().abs().toStringAsFixed(2)}'
              .padRight(12);
      final payment = expense['paymentMethod'] as String;

      buffer.writeln(
        date.padRight(12) +
            cat.substring(0, cat.length > 20 ? 20 : cat.length) +
            amount +
            payment,
      );
    }

    final pdfContent = buffer.toString();
    final fileName =
        'expense_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';

    // Platform-specific file saving
    if (kIsWeb) {
      // Web: Trigger browser download
      final bytes = utf8.encode(pdfContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return fileName;
    } else {
      // Mobile: Save to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(pdfContent);
      return file.path;
    }
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

    backupData['backup_date'] = DateTime.now().toIso8601String();

    final jsonString = jsonEncode(backupData);
    final fileName =
        'backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

    if (kIsWeb) {
      // Web: Trigger browser download
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return fileName;
    } else {
      // Mobile: Save to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      return file.path;
    }
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
