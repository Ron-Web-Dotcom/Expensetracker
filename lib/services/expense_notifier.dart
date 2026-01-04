import 'package:flutter/foundation.dart';

/// Global notifier for expense and budget data changes
/// Broadcasts updates to all listening screens for real-time synchronization
class ExpenseNotifier extends ChangeNotifier {
  static final ExpenseNotifier _instance = ExpenseNotifier._internal();
  factory ExpenseNotifier() => _instance;
  ExpenseNotifier._internal();

  /// Notify all listeners that expense data has changed
  void notifyExpenseChanged() {
    notifyListeners();
  }

  /// Notify all listeners that budget data has changed
  void notifyBudgetChanged() {
    notifyListeners();
  }

  /// Notify all listeners that any financial data has changed
  void notifyDataChanged() {
    notifyListeners();
  }
}
