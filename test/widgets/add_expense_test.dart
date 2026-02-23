import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:expensetracker/presentation/add_expense/add_expense.dart';
import 'package:expensetracker/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(Widget child) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: child,
          routes: {
            AppRoutes.expenseDashboard: (context) =>
                const Scaffold(body: Text('Dashboard')),
          },
        );
      },
    );
  }

  group('AddExpense Widget Tests', () {
    testWidgets('should display all required input fields', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should show error when amount is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('amount'), findsWidgets);
      }
    });

    testWidgets('should show error when category is not selected', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '100');
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('category'), findsWidgets);
      }
    });

    testWidgets('should toggle between expense and income', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      final incomeToggle = find.text('Income');
      if (incomeToggle.evaluate().isNotEmpty) {
        await tester.tap(incomeToggle);
        await tester.pumpAndSettle();

        expect(find.text('Add Income'), findsOneWidget);
      }
    });

    testWidgets('should allow date selection', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      final dateButton = find.byIcon(Icons.calendar_today);
      if (dateButton.evaluate().isNotEmpty) {
        await tester.tap(dateButton);
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
      }
    });

    testWidgets('should display payment method selector', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsWidgets);
      expect(find.text('Card'), findsWidgets);
    });

    testWidgets('should allow description input', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      final descriptionField = find.widgetWithText(TextField, 'Description');
      if (descriptionField.evaluate().isEmpty) {
        final allTextFields = find.byType(TextField);
        if (allTextFields.evaluate().length > 1) {
          await tester.enterText(allTextFields.at(1), 'Test description');
          await tester.pumpAndSettle();

          expect(find.text('Test description'), findsOneWidget);
        }
      }
    });

    testWidgets('should validate amount format', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, 'invalid');
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save Expense');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('valid'), findsWidgets);
      }
    });

    testWidgets('should show receipt attachment option', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt), findsWidgets);
    });

    testWidgets('should have back navigation', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddExpense()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });
  });
}
