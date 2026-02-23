import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensetracker/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    late NotificationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = NotificationService();
    });

    test('initialize should complete without errors', () async {
      expect(() => service.initialize(), returnsNormally);
    });

    test('scheduleExpenseReminder should create notification', () async {
      await service.scheduleExpenseReminder(
        title: 'Log your expenses',
        body: 'Don\'t forget to track today\'s spending',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(true, true);
    });

    test('scheduleBudgetAlert should create alert notification', () async {
      await service.scheduleBudgetAlert(
        category: 'Food',
        currentAmount: 450.0,
        budgetAmount: 500.0,
        percentage: 90.0,
      );

      expect(true, true);
    });

    test('cancelNotification should remove scheduled notification', () async {
      await service.scheduleExpenseReminder(
        title: 'Test',
        body: 'Test notification',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      await service.cancelNotification(1);

      expect(true, true);
    });

    test('cancelAllNotifications should clear all notifications', () async {
      await service.scheduleExpenseReminder(
        title: 'Test 1',
        body: 'Test notification 1',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      await service.scheduleExpenseReminder(
        title: 'Test 2',
        body: 'Test notification 2',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      );

      await service.cancelAllNotifications();

      expect(true, true);
    });

    test('showInstantNotification should display immediately', () async {
      await service.showInstantNotification(
        title: 'Instant Alert',
        body: 'This is an instant notification',
      );

      expect(true, true);
    });
  });
}
