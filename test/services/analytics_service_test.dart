import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/services/analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsService Tests', () {
    late AnalyticsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = AnalyticsService();
    });

    test('trackScreenView should log screen view event', () async {
      await service.trackScreenView('home_screen');

      final events = await service.getEvents();
      expect(events.isNotEmpty, true);
      expect(events.last['event_name'], 'screen_view');
      expect(events.last['screen_name'], 'home_screen');
    });

    test('trackEvent should log custom event', () async {
      await service.trackEvent(
        'button_clicked',
        parameters: {'button_name': 'add_expense', 'screen': 'dashboard'},
      );

      final events = await service.getEvents();
      expect(events.isNotEmpty, true);
      expect(events.last['event_name'], 'button_clicked');
      expect(events.last['button_name'], 'add_expense');
    });

    test('trackExpenseAdded should log expense event', () async {
      await service.trackExpenseAdded(
        amount: 100.0,
        category: 'Food',
        paymentMethod: 'Cash',
      );

      final events = await service.getEvents();
      expect(events.isNotEmpty, true);
      expect(events.last['event_name'], 'expense_added');
      expect(events.last['amount'], 100.0);
      expect(events.last['category'], 'Food');
    });

    test('trackBudgetAction should log budget event', () async {
      await service.trackBudgetAction(
        'created',
        category: 'Food',
        amount: 500.0,
      );

      final events = await service.getEvents();
      expect(events.isNotEmpty, true);
      expect(events.last['event_name'], 'budget_created');
      expect(events.last['category'], 'Food');
    });

    test('trackFeatureUsage should increment feature counter', () async {
      await service.trackFeatureUsage('receipt_scanner');
      await service.trackFeatureUsage('receipt_scanner');
      await service.trackFeatureUsage('receipt_scanner');

      final metrics = await service.getUserMetrics();
      expect(metrics['feature_receipt_scanner_count'], 3);
    });

    test('trackSessionStart should create session', () async {
      await service.trackSessionStart();

      final metrics = await service.getUserMetrics();
      expect(metrics['total_sessions'], greaterThanOrEqualTo(1));
    });

    test('trackSessionEnd should calculate duration', () async {
      await service.trackSessionStart();
      await Future.delayed(const Duration(seconds: 2));
      await service.trackSessionEnd();

      final events = await service.getEvents();
      final sessionEndEvent = events.lastWhere(
        (e) => e['event_name'] == 'session_end',
      );

      expect(sessionEndEvent['duration_seconds'], greaterThanOrEqualTo(2));
    });

    test('getEvents should return all logged events', () async {
      await service.trackScreenView('screen1');
      await service.trackScreenView('screen2');
      await service.trackEvent('test_event');

      final events = await service.getEvents();
      expect(events.length, greaterThanOrEqualTo(3));
    });

    test('clearEvents should remove all events', () async {
      await service.trackScreenView('test');
      await service.clearEvents();

      final events = await service.getEvents();
      expect(events, isEmpty);
    });

    test('getUserMetrics should return accumulated metrics', () async {
      await service.trackExpenseAdded(
        amount: 100.0,
        category: 'Food',
        paymentMethod: 'Cash',
      );

      final metrics = await service.getUserMetrics();
      expect(metrics['total_expenses_added'], greaterThanOrEqualTo(1));
    });
  });
}
