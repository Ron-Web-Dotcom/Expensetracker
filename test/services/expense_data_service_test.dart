import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/services/expense_data_service.dart';
import 'package:expensetracker/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExpenseDataService Tests', () {
    late ExpenseDataService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = ExpenseDataService();
    });

    test('saveExpense should save expense successfully', () async {
      await service.saveExpense(
        amount: 100.0,
        category: 'Food',
        date: DateTime.now(),
        paymentMethod: 'Cash',
        description: 'Test expense',
      );

      final expenses = await service.getAllExpenses();
      expect(expenses.length, 1);
      expect(expenses[0]['category'], 'Food');
      expect(expenses[0]['amount'], -100.0);
    });

    test('saveExpense should save income with positive amount', () async {
      await service.saveExpense(
        amount: 500.0,
        category: 'Salary',
        date: DateTime.now(),
        paymentMethod: 'Bank Transfer',
        transactionType: 'income',
      );

      final expenses = await service.getAllExpenses();
      expect(expenses.length, 1);
      expect(expenses[0]['amount'], 500.0);
      expect(expenses[0]['transactionType'], 'income');
    });

    test('getAllExpenses should return empty list when no expenses', () async {
      final expenses = await service.getAllExpenses();
      expect(expenses, isEmpty);
    });

    test('getExpensesByDateRange should filter expenses correctly', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      await service.saveExpense(
        amount: 100.0,
        category: 'Food',
        date: today,
        paymentMethod: 'Cash',
      );

      await service.saveExpense(
        amount: 200.0,
        category: 'Transport',
        date: yesterday,
        paymentMethod: 'Card',
      );

      await service.saveExpense(
        amount: 300.0,
        category: 'Shopping',
        date: twoDaysAgo,
        paymentMethod: 'Cash',
      );

      final filtered = await service.getExpensesByDateRange(
        startDate: yesterday,
        endDate: today,
      );

      expect(filtered.length, 2);
    });

    test('getTotalSpending should calculate correctly', () async {
      final today = DateTime.now();

      await service.saveExpense(
        amount: 100.0,
        category: 'Food',
        date: today,
        paymentMethod: 'Cash',
      );

      await service.saveExpense(
        amount: 200.0,
        category: 'Transport',
        date: today,
        paymentMethod: 'Card',
      );

      await service.saveExpense(
        amount: 500.0,
        category: 'Salary',
        date: today,
        paymentMethod: 'Bank',
        transactionType: 'income',
      );

      final total = await service.getTotalSpending(
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
      );

      expect(total, 300.0);
    });

    test('getSpendingByCategory should group expenses correctly', () async {
      final today = DateTime.now();

      await service.saveExpense(
        amount: 100.0,
        category: 'Food',
        date: today,
        paymentMethod: 'Cash',
      );

      await service.saveExpense(
        amount: 50.0,
        category: 'Food',
        date: today,
        paymentMethod: 'Card',
      );

      await service.saveExpense(
        amount: 200.0,
        category: 'Transport',
        date: today,
        paymentMethod: 'Cash',
      );

      final byCategory = await service.getSpendingByCategory(
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
      );

      expect(byCategory['Food'], 150.0);
      expect(byCategory['Transport'], 200.0);
    });

    test('deleteExpense should remove expense', () async {
      await service.saveExpense(
        amount: 100.0,
        category: 'Food',
        date: DateTime.now(),
        paymentMethod: 'Cash',
      );

      final expenses = await service.getAllExpenses();
      final expenseId = expenses[0]['id'];

      await service.deleteExpense(expenseId);

      final remainingExpenses = await service.getAllExpenses();
      expect(remainingExpenses, isEmpty);
    });

    test('should handle invalid amounts gracefully', () async {
      await service.saveExpense(
        amount: 0.0,
        category: 'Test',
        date: DateTime.now(),
        paymentMethod: 'Cash',
      );

      final expenses = await service.getAllExpenses();
      expect(expenses.length, 1);
      expect(expenses[0]['amount'], 0.0);
    });
  });
}
