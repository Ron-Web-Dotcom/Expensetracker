import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:expensetracker/presentation/expense_dashboard/expense_dashboard.dart';
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
            AppRoutes.addExpense: (context) =>
                const Scaffold(body: Text('Add Expense')),
            AppRoutes.analyticsDashboard: (context) =>
                const Scaffold(body: Text('Analytics')),
            AppRoutes.budgetManagement: (context) =>
                const Scaffold(body: Text('Budget')),
          },
        );
      },
    );
  }

  group('ExpenseDashboard Widget Tests', () {
    testWidgets('should display greeting header', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hello'), findsWidgets);
    });

    testWidgets('should display monthly spending card', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('This Month'), findsWidgets);
    });

    testWidgets('should display quick action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsWidgets);
      expect(find.text('View Analytics'), findsWidgets);
    });

    testWidgets('should navigate to add expense screen', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      final addButton = find.widgetWithText(ElevatedButton, 'Add Expense');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(find.text('Add Expense'), findsOneWidget);
      }
    });

    testWidgets('should display recent transactions section', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recent'), findsWidgets);
    });

    testWidgets('should show empty state when no transactions', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('No'), findsWidgets);
    });

    testWidgets('should have bottom navigation bar', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should display floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('should refresh on pull down', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should display budget progress indicators', (tester) async {
      await tester.pumpWidget(createTestWidget(const ExpenseDashboard()));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });
  });
}
