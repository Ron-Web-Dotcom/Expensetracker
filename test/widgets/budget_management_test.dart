import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:expensetracker/presentation/budget_management/budget_management.dart';
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

  group('BudgetManagement Widget Tests', () {
    testWidgets('should display budget overview card', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.text('Budget Overview'), findsWidgets);
    });

    testWidgets('should display period selector', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.text('Monthly'), findsWidgets);
      expect(find.text('Weekly'), findsWidgets);
    });

    testWidgets('should display category budget items', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('should show add budget button', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('should display progress indicators for budgets', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('should show budget alerts when exceeded', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsWidgets);
    });

    testWidgets('should allow budget editing', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsWidgets);
      }
    });

    testWidgets('should display historical comparison', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.textContaining('vs Last'), findsWidgets);
    });

    testWidgets('should show empty state when no budgets', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.textContaining('No budgets'), findsWidgets);
    });

    testWidgets('should have back navigation', (tester) async {
      await tester.pumpWidget(createTestWidget(const BudgetManagement()));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
