import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Expense Creation Flow Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete expense creation flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through onboarding if present
      final getStartedButton = find.text('Get Started');
      if (getStartedButton.evaluate().isNotEmpty) {
        await tester.tap(getStartedButton);
        await tester.pumpAndSettle();
      }

      // Find and tap Add Expense button
      final addExpenseButton = find.text('Add Expense');
      expect(addExpenseButton, findsOneWidget);
      await tester.tap(addExpenseButton);
      await tester.pumpAndSettle();

      // Enter amount
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '150.50');
      await tester.pumpAndSettle();

      // Select category
      final foodCategory = find.text('Food');
      if (foodCategory.evaluate().isNotEmpty) {
        await tester.tap(foodCategory);
        await tester.pumpAndSettle();
      }

      // Enter description
      final descriptionField = find.widgetWithText(TextField, 'Description');
      if (descriptionField.evaluate().isNotEmpty) {
        await tester.enterText(descriptionField, 'Lunch at restaurant');
        await tester.pumpAndSettle();
      }

      // Select payment method
      final cardPayment = find.text('Card');
      if (cardPayment.evaluate().isNotEmpty) {
        await tester.tap(cardPayment);
        await tester.pumpAndSettle();
      }

      // Save expense
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify navigation back to dashboard
      expect(find.text('Dashboard'), findsWidgets);

      // Verify expense appears in recent transactions
      expect(find.textContaining('150'), findsWidgets);
    });

    testWidgets('Income creation flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Add Expense
      final addButton = find.byType(FloatingActionButton).first;
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Switch to Income
      final incomeToggle = find.text('Income');
      if (incomeToggle.evaluate().isNotEmpty) {
        await tester.tap(incomeToggle);
        await tester.pumpAndSettle();

        expect(find.text('Add Income'), findsOneWidget);
      }

      // Enter income amount
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '5000');
      await tester.pumpAndSettle();

      // Select category
      final salaryCategory = find.text('Salary');
      if (salaryCategory.evaluate().isNotEmpty) {
        await tester.tap(salaryCategory);
        await tester.pumpAndSettle();
      }

      // Save income
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Income');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      }

      // Verify success
      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('Expense with receipt attachment', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Add Expense
      final addButton = find.text('Add Expense');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Enter basic details
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '75.00');
      await tester.pumpAndSettle();

      // Tap camera icon for receipt
      final cameraIcon = find.byIcon(Icons.camera_alt);
      if (cameraIcon.evaluate().isNotEmpty) {
        await tester.tap(cameraIcon.first);
        await tester.pumpAndSettle();

        // Verify camera/gallery options appear
        expect(find.text('Camera'), findsWidgets);
        expect(find.text('Gallery'), findsWidgets);
      }
    });

    testWidgets('Form validation prevents invalid submission', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Add Expense
      final addButton = find.text('Add Expense');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Try to save without entering data
      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify error messages appear
      expect(find.textContaining('amount'), findsWidgets);
      expect(find.textContaining('category'), findsWidgets);

      // Verify we're still on the add expense screen
      expect(find.text('Add Expense'), findsOneWidget);
    });
  });
}
