import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Budget Alert Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Create budget and trigger alert', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Budget Management
      final budgetTab = find.text('Budget');
      if (budgetTab.evaluate().isNotEmpty) {
        await tester.tap(budgetTab);
        await tester.pumpAndSettle();
      }

      // Create new budget
      final addBudgetButton = find.byIcon(Icons.add);
      if (addBudgetButton.evaluate().isNotEmpty) {
        await tester.tap(addBudgetButton.first);
        await tester.pumpAndSettle();

        // Select category
        final foodCategory = find.text('Food');
        if (foodCategory.evaluate().isNotEmpty) {
          await tester.tap(foodCategory);
          await tester.pumpAndSettle();
        }

        // Enter budget amount
        final amountField = find.byType(TextField).first;
        await tester.enterText(amountField, '200');
        await tester.pumpAndSettle();

        // Save budget
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }

      // Add expenses to exceed budget
      for (int i = 0; i < 3; i++) {
        final addExpenseButton = find.text('Add Expense');
        if (addExpenseButton.evaluate().isNotEmpty) {
          await tester.tap(addExpenseButton);
          await tester.pumpAndSettle();

          // Enter amount
          final amountField = find.byType(TextField).first;
          await tester.enterText(amountField, '80');
          await tester.pumpAndSettle();

          // Select Food category
          final foodCategory = find.text('Food');
          if (foodCategory.evaluate().isNotEmpty) {
            await tester.tap(foodCategory);
            await tester.pumpAndSettle();
          }

          // Save
          final saveButton = find.widgetWithText(
            ElevatedButton,
            'Save Expense',
          );
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }
      }

      // Navigate back to Budget Management
      final budgetTab2 = find.text('Budget');
      if (budgetTab2.evaluate().isNotEmpty) {
        await tester.tap(budgetTab2);
        await tester.pumpAndSettle();
      }

      // Verify budget alert appears
      expect(find.byIcon(Icons.warning), findsWidgets);
      expect(find.textContaining('exceeded'), findsWidgets);
    });

    testWidgets('Budget warning at 80% threshold', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Create budget of 100
      final budgetTab = find.text('Budget');
      if (budgetTab.evaluate().isNotEmpty) {
        await tester.tap(budgetTab);
        await tester.pumpAndSettle();
      }

      final addBudgetButton = find.byIcon(Icons.add);
      if (addBudgetButton.evaluate().isNotEmpty) {
        await tester.tap(addBudgetButton.first);
        await tester.pumpAndSettle();

        final amountField = find.byType(TextField).first;
        await tester.enterText(amountField, '100');
        await tester.pumpAndSettle();

        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }

      // Add expense of 85 (85% of budget)
      final addExpenseButton = find.text('Add Expense');
      if (addExpenseButton.evaluate().isNotEmpty) {
        await tester.tap(addExpenseButton);
        await tester.pumpAndSettle();

        final amountField = find.byType(TextField).first;
        await tester.enterText(amountField, '85');
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }

      // Check for warning indicator
      expect(find.byIcon(Icons.warning_amber), findsWidgets);
    });
  });
}
