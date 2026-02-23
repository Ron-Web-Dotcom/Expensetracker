import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/services/budget_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BudgetDataService Tests', () {
    late BudgetDataService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = BudgetDataService();
    });

    test('setBudget should create budget successfully', () async {
      await service.setBudget(
        category: 'Food',
        amount: 500.0,
        period: 'monthly',
      );

      final budgets = await service.getAllBudgets();
      expect(budgets.length, 1);
      expect(budgets[0]['category'], 'Food');
      expect(budgets[0]['amount'], 500.0);
      expect(budgets[0]['period'], 'monthly');
    });

    test('setBudget should update existing budget', () async {
      await service.setBudget(
        category: 'Food',
        amount: 500.0,
        period: 'monthly',
      );

      await service.setBudget(
        category: 'Food',
        amount: 600.0,
        period: 'monthly',
      );

      final budgets = await service.getAllBudgets();
      expect(budgets.length, 1);
      expect(budgets[0]['amount'], 600.0);
    });

    test('getAllBudgets should return empty list when no budgets', () async {
      final budgets = await service.getAllBudgets();
      expect(budgets, isEmpty);
    });

    test('getBudgetForCategory should return correct budget', () async {
      await service.setBudget(
        category: 'Food',
        amount: 500.0,
        period: 'monthly',
      );

      await service.setBudget(
        category: 'Transport',
        amount: 200.0,
        period: 'monthly',
      );

      final budget = await service.getBudgetForCategory('Food');
      expect(budget, isNotNull);
      expect(budget!['amount'], 500.0);
    });

    test('deleteBudget should remove budget', () async {
      await service.setBudget(
        category: 'Food',
        amount: 500.0,
        period: 'monthly',
      );

      await service.deleteBudget('Food');

      final budgets = await service.getAllBudgets();
      expect(budgets, isEmpty);
    });

    test('checkBudgetAlert should detect overspending', () async {
      await service.setBudget(
        category: 'Food',
        amount: 100.0,
        period: 'monthly',
      );

      final alert = await service.checkBudgetAlert(
        category: 'Food',
        currentSpending: 120.0,
      );

      expect(alert, isNotNull);
      expect(alert!['type'], 'exceeded');
      expect(alert['percentage'], greaterThan(100));
    });

    test('checkBudgetAlert should detect warning threshold', () async {
      await service.setBudget(
        category: 'Food',
        amount: 100.0,
        period: 'monthly',
      );

      final alert = await service.checkBudgetAlert(
        category: 'Food',
        currentSpending: 85.0,
      );

      expect(alert, isNotNull);
      expect(alert!['type'], 'warning');
      expect(alert['percentage'], greaterThanOrEqualTo(80));
    });

    test('checkBudgetAlert should return null when under threshold', () async {
      await service.setBudget(
        category: 'Food',
        amount: 100.0,
        period: 'monthly',
      );

      final alert = await service.checkBudgetAlert(
        category: 'Food',
        currentSpending: 50.0,
      );

      expect(alert, isNull);
    });

    test('should handle multiple budgets correctly', () async {
      await service.setBudget(
        category: 'Food',
        amount: 500.0,
        period: 'monthly',
      );

      await service.setBudget(
        category: 'Transport',
        amount: 200.0,
        period: 'weekly',
      );

      await service.setBudget(
        category: 'Entertainment',
        amount: 300.0,
        period: 'monthly',
      );

      final budgets = await service.getAllBudgets();
      expect(budgets.length, 3);
    });
  });
}
