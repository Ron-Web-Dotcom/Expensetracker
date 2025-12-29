import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for exporting and managing app data
class DataExportService {
  /// Export data as CSV format
  Future<String> exportAsCSV() async {
    final transactions = _getSampleTransactions();

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Date,Category,Amount,Description,Payment Method');

    for (var transaction in transactions) {
      csvBuffer.writeln(
        '${transaction['date']},${transaction['category']},${transaction['amount']},${transaction['description']},${transaction['paymentMethod']}',
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/expense_data_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csvBuffer.toString());

    return file.path;
  }

  /// Export data as PDF format
  Future<String> exportAsPDF() async {
    final pdf = pw.Document();
    final transactions = _getSampleTransactions();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'ExpenseTracker Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Date', 'Category', 'Amount', 'Description'],
              data: transactions
                  .map(
                    (t) => [
                      t['date'],
                      t['category'],
                      '\$${t['amount']}',
                      t['description'],
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Transactions: ${transactions.length}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file.path;
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
}
