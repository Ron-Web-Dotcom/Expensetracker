import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:expensetracker/presentation/analytics_dashboard/analytics_dashboard.dart';
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

  group('AnalyticsDashboard Widget Tests', () {
    testWidgets('should display analytics title', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.text('Analytics'), findsWidgets);
    });

    testWidgets('should display period selector', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.text('Week'), findsWidgets);
      expect(find.text('Month'), findsWidgets);
      expect(find.text('Year'), findsWidgets);
    });

    testWidgets('should display spending trend chart', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Spending Trend'), findsWidgets);
    });

    testWidgets('should display category breakdown', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Category'), findsWidgets);
    });

    testWidgets('should display smart insights', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Insights'), findsWidgets);
    });

    testWidgets('should display monthly comparison', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('vs'), findsWidgets);
    });

    testWidgets('should allow period switching', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      final monthButton = find.text('Month');
      if (monthButton.evaluate().isNotEmpty) {
        await tester.tap(monthButton);
        await tester.pumpAndSettle();

        expect(find.text('Month'), findsOneWidget);
      }
    });

    testWidgets('should display spending patterns', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Pattern'), findsWidgets);
    });

    testWidgets('should show empty state when no data', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('No data'), findsWidgets);
    });

    testWidgets('should have scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget(const AnalyticsDashboard()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
