import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int budgetAlert75Id = 1;
  static const int budgetAlert90Id = 2;
  static const int weeklySummaryId = 3;
  static const int achievementId = 4;

  // SharedPreferences keys
  static const String _lastBudgetAlertKey = 'last_budget_alert_percentage';
  static const String _lastWeeklySummaryKey = 'last_weekly_summary_date';
  static const String _achievementCountKey = 'achievement_count';

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can be extended to navigate to specific screens
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // Budget Alert Notifications (75% and 90%)
  Future<void> checkAndSendBudgetAlert({
    required double spent,
    required double budget,
    required String categoryName,
  }) async {
    if (!_isInitialized) await initialize();

    final percentage = (spent / budget * 100).round();
    final prefs = await SharedPreferences.getInstance();
    final lastAlertPercentage =
        prefs.getInt('$_lastBudgetAlertKey-$categoryName') ?? 0;

    // Send 75% alert
    if (percentage >= 75 && lastAlertPercentage < 75) {
      await _sendBudgetAlert(
        percentage: 75,
        categoryName: categoryName,
        spent: spent,
        budget: budget,
      );
      await prefs.setInt('$_lastBudgetAlertKey-$categoryName', 75);
    }

    // Send 90% alert
    if (percentage >= 90 && lastAlertPercentage < 90) {
      await _sendBudgetAlert(
        percentage: 90,
        categoryName: categoryName,
        spent: spent,
        budget: budget,
      );
      await prefs.setInt('$_lastBudgetAlertKey-$categoryName', 90);
    }

    // Reset alert tracking if spending drops below 75%
    if (percentage < 75 && lastAlertPercentage >= 75) {
      await prefs.remove('$_lastBudgetAlertKey-$categoryName');
    }
  }

  Future<void> _sendBudgetAlert({
    required int percentage,
    required String categoryName,
    required double spent,
    required double budget,
  }) async {
    final remaining = budget - spent;
    final notificationId = percentage == 75 ? budgetAlert75Id : budgetAlert90Id;

    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget spending alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notificationId + categoryName.hashCode,
      '⚠️ Budget Alert: $categoryName',
      'You\'ve spent $percentage% (\$${spent.toStringAsFixed(2)}) of your \$${budget.toStringAsFixed(2)} budget. \$${remaining.toStringAsFixed(2)} remaining.',
      details,
    );
  }

  // Weekly Summary Notification
  Future<void> scheduleWeeklySummary({
    required double totalSpent,
    required int transactionCount,
    required String topCategory,
  }) async {
    if (!_isInitialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final lastSummaryDate = prefs.getString(_lastWeeklySummaryKey);
    final now = DateTime.now();

    // Check if we already sent a summary this week
    if (lastSummaryDate != null) {
      final lastDate = DateTime.parse(lastSummaryDate);
      final daysSince = now.difference(lastDate).inDays;
      if (daysSince < 7) return; // Don't send if less than 7 days
    }

    await _sendWeeklySummary(
      totalSpent: totalSpent,
      transactionCount: transactionCount,
      topCategory: topCategory,
    );

    await prefs.setString(_lastWeeklySummaryKey, now.toIso8601String());
  }

  Future<void> _sendWeeklySummary({
    required double totalSpent,
    required int transactionCount,
    required String topCategory,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'weekly_summary',
      'Weekly Summary',
      channelDescription: 'Weekly spending summary notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      weeklySummaryId,
      '📊 Your Weekly Spending Summary',
      'This week: \$${totalSpent.toStringAsFixed(2)} across $transactionCount transactions. Top category: $topCategory',
      details,
    );
  }

  // Schedule weekly summary for every Monday at 9 AM
  Future<void> scheduleWeeklySummaryRecurring() async {
    if (!_isInitialized) await initialize();

    await _notifications.cancelAll();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

    // Find next Monday
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If the scheduled time is in the past, move to next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      'weekly_summary',
      'Weekly Summary',
      channelDescription: 'Weekly spending summary notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      weeklySummaryId,
      '📊 Your Weekly Spending Summary',
      'Tap to view your spending breakdown for the past week',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Achievement Milestone Notifications
  Future<void> sendAchievementNotification({
    required String title,
    required String message,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Achievement milestone notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final prefs = await SharedPreferences.getInstance();
    final achievementCount = prefs.getInt(_achievementCountKey) ?? 0;

    await _notifications.show(
      achievementId + achievementCount,
      '🎉 $title',
      message,
      details,
    );

    await prefs.setInt(_achievementCountKey, achievementCount + 1);
  }

  // Check for achievements based on spending patterns
  Future<void> checkAchievements({
    required double totalSpent,
    required double budget,
    required int daysInMonth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = DateTime.now().month;
    final lastAchievementMonth = prefs.getInt('last_achievement_month') ?? 0;

    // Only check once per month
    if (currentMonth == lastAchievementMonth) return;

    final percentageUsed = (totalSpent / budget * 100);

    // Achievement: Stayed under budget
    if (daysInMonth >= 28 && percentageUsed < 100) {
      await sendAchievementNotification(
        title: 'Budget Champion!',
        message:
            'Congratulations! You stayed under budget this month. You spent \$${totalSpent.toStringAsFixed(2)} of your \$${budget.toStringAsFixed(2)} budget.',
      );
      await prefs.setInt('last_achievement_month', currentMonth);
    }

    // Achievement: Saved 20% or more
    if (daysInMonth >= 28 && percentageUsed <= 80) {
      await sendAchievementNotification(
        title: 'Super Saver!',
        message:
            'Amazing! You saved ${(100 - percentageUsed).toStringAsFixed(0)}% of your budget this month. Keep up the great work!',
      );
      await prefs.setInt('last_achievement_month', currentMonth);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Send generic notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'spending_alerts',
      'Spending Alerts',
      channelDescription: 'Notifications for spending alerts and warnings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
  }
}
