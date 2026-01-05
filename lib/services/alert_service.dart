import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './notification_service.dart';
import './budget_data_service.dart';
import './expense_data_service.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final NotificationService _notificationService = NotificationService();
  final BudgetDataService _budgetDataService = BudgetDataService();
  final ExpenseDataService _expenseDataService = ExpenseDataService();

  // SharedPreferences keys
  static const String _alertSettingsKey = 'alert_settings';
  static const String _alertHistoryKey = 'alert_history';
  static const String _lastUnusualSpendingCheckKey =
      'last_unusual_spending_check';

  // Default alert settings
  Map<String, dynamic> _defaultSettings = {
    // Budget Limits
    'budgetLimit50Enabled': true,
    'budgetLimit75Enabled': true,
    'budgetLimit90Enabled': true,

    // Unusual Spending
    'unusualSpendingEnabled': true,
    'largeTransactionEnabled': true,
    'largeTransactionThreshold': 500.0,
    'frequencySpikeEnabled': true,

    // Milestone Alerts
    'monthlyGoalEnabled': true,
    'savingsTargetEnabled': true,
    'spendingStreakEnabled': true,

    // Overspending Warnings
    'budgetExceededEnabled': true,
    'categoryLimitBreachedEnabled': true,

    // Smart Scheduling
    'quietHoursEnabled': false,
    'quietHoursStart': '22:00',
    'quietHoursEnd': '07:00',
    'weekendPreference': false,

    // Delivery Methods
    'pushNotificationsEnabled': true,
    'emailNotificationsEnabled': false,
    'inAppNotificationsEnabled': true,

    // Alert Frequency
    'maxAlertsPerDay': 10,
    'alertCooldownMinutes': 60,
  };

  /// Get alert settings
  Future<Map<String, dynamic>> getAlertSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_alertSettingsKey);

    if (settingsJson == null) {
      await saveAlertSettings(_defaultSettings);
      return _defaultSettings;
    }

    return Map<String, dynamic>.from(jsonDecode(settingsJson));
  }

  /// Save alert settings
  Future<void> saveAlertSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alertSettingsKey, jsonEncode(settings));
  }

  /// Update specific alert setting
  Future<void> updateAlertSetting(String key, dynamic value) async {
    final settings = await getAlertSettings();
    settings[key] = value;
    await saveAlertSettings(settings);
  }

  /// Check if alerts should be sent (quiet hours, frequency limits)
  Future<bool> canSendAlert(String alertType) async {
    final settings = await getAlertSettings();

    // Check quiet hours
    if (settings['quietHoursEnabled'] == true) {
      final now = DateTime.now();
      final startParts = (settings['quietHoursStart'] as String).split(':');
      final endParts = (settings['quietHoursEnd'] as String).split(':');

      final startHour = int.parse(startParts[0]);
      final endHour = int.parse(endParts[0]);

      if (now.hour >= startHour || now.hour < endHour) {
        return false;
      }
    }

    // Check daily alert limit
    final history = await getAlertHistory();
    final today = DateTime.now();
    final todayAlerts = history.where((alert) {
      final alertDate = DateTime.parse(alert['timestamp']);
      return alertDate.year == today.year &&
          alertDate.month == today.month &&
          alertDate.day == today.day;
    }).length;

    final maxAlerts = settings['maxAlertsPerDay'] as int;
    if (todayAlerts >= maxAlerts) {
      return false;
    }

    return true;
  }

  /// Monitor budget limits and send alerts
  Future<void> checkBudgetLimits() async {
    final settings = await getAlertSettings();
    final budgets = await _budgetDataService.getAllCategoryBudgets();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    for (var budget in budgets) {
      final categoryName = budget['categoryName'] as String;
      final budgetLimit = budget['budgetLimit'] as double;

      final spent = await _budgetDataService.getCategorySpentAmount(
        categoryName: categoryName,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final percentage = (spent / budgetLimit * 100).round();

      // Check 50% threshold
      if (percentage >= 50 &&
          percentage < 75 &&
          settings['budgetLimit50Enabled'] == true) {
        if (await canSendAlert('budget_50')) {
          await _sendBudgetAlert(50, categoryName, spent, budgetLimit);
        }
      }

      // Check 75% threshold
      if (percentage >= 75 &&
          percentage < 90 &&
          settings['budgetLimit75Enabled'] == true) {
        if (await canSendAlert('budget_75')) {
          await _sendBudgetAlert(75, categoryName, spent, budgetLimit);
        }
      }

      // Check 90% threshold
      if (percentage >= 90 &&
          percentage < 100 &&
          settings['budgetLimit90Enabled'] == true) {
        if (await canSendAlert('budget_90')) {
          await _sendBudgetAlert(90, categoryName, spent, budgetLimit);
        }
      }

      // Check budget exceeded
      if (percentage >= 100 && settings['budgetExceededEnabled'] == true) {
        if (await canSendAlert('budget_exceeded')) {
          await _sendBudgetExceededAlert(categoryName, spent, budgetLimit);
        }
      }
    }
  }

  /// Check for unusual spending patterns
  Future<void> checkUnusualSpending() async {
    final settings = await getAlertSettings();
    if (settings['unusualSpendingEnabled'] != true) return;

    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString(_lastUnusualSpendingCheckKey);

    // Only check once per day
    if (lastCheck != null) {
      final lastCheckDate = DateTime.parse(lastCheck);
      if (DateTime.now().difference(lastCheckDate).inHours < 24) {
        return;
      }
    }

    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    // Get spending data
    final recentSpending = await _expenseDataService.getTotalSpending(
      startDate: last7Days,
      endDate: now,
    );

    final historicalSpending = await _expenseDataService.getTotalSpending(
      startDate: last30Days,
      endDate: last7Days,
    );

    // Calculate average daily spending
    final recentAverage = recentSpending / 7;
    final historicalAverage = historicalSpending / 23;

    // Alert if recent spending is 50% higher than historical
    if (recentAverage > historicalAverage * 1.5) {
      if (await canSendAlert('unusual_spending')) {
        await _sendUnusualSpendingAlert(recentAverage, historicalAverage);
      }
    }

    await prefs.setString(_lastUnusualSpendingCheckKey, now.toIso8601String());
  }

  /// Check for large transactions
  Future<void> checkLargeTransaction(double amount) async {
    final settings = await getAlertSettings();
    if (settings['largeTransactionEnabled'] != true) return;

    final threshold = settings['largeTransactionThreshold'] as double;
    if (amount >= threshold) {
      if (await canSendAlert('large_transaction')) {
        await _sendLargeTransactionAlert(amount);
      }
    }
  }

  /// Send budget alert notification
  Future<void> _sendBudgetAlert(
    int percentage,
    String categoryName,
    double spent,
    double budget,
  ) async {
    await _notificationService.showNotification(
      id: 100 + percentage,
      title: '💰 Budget Alert: $percentage%',
      body:
          'You\'ve spent \$${spent.toStringAsFixed(2)} of \$${budget.toStringAsFixed(2)} in $categoryName',
    );

    await _addToHistory(
      type: 'budget_limit',
      title: 'Budget Alert: $percentage%',
      message:
          '$categoryName - \$${spent.toStringAsFixed(2)}/\$${budget.toStringAsFixed(2)}',
      severity: percentage >= 90 ? 'high' : 'medium',
    );
  }

  /// Send budget exceeded alert
  Future<void> _sendBudgetExceededAlert(
    String categoryName,
    double spent,
    double budget,
  ) async {
    await _notificationService.showNotification(
      id: 200,
      title: '🚨 Budget Exceeded!',
      body:
          '$categoryName budget exceeded! Spent \$${spent.toStringAsFixed(2)} of \$${budget.toStringAsFixed(2)}',
    );

    await _addToHistory(
      type: 'overspending',
      title: 'Budget Exceeded',
      message:
          '$categoryName - \$${spent.toStringAsFixed(2)}/\$${budget.toStringAsFixed(2)}',
      severity: 'critical',
    );
  }

  /// Send unusual spending alert
  Future<void> _sendUnusualSpendingAlert(
    double recentAverage,
    double historicalAverage,
  ) async {
    final increase =
        ((recentAverage - historicalAverage) / historicalAverage * 100).round();

    await _notificationService.showNotification(
      id: 300,
      title: '📊 Unusual Spending Detected',
      body: 'Your spending is $increase% higher than usual this week',
    );

    await _addToHistory(
      type: 'unusual_spending',
      title: 'Unusual Spending Pattern',
      message: 'Spending increased by $increase% compared to average',
      severity: 'medium',
    );
  }

  /// Send large transaction alert
  Future<void> _sendLargeTransactionAlert(double amount) async {
    await _notificationService.showNotification(
      id: 400,
      title: '💳 Large Transaction Alert',
      body:
          'A large transaction of \$${amount.toStringAsFixed(2)} was recorded',
    );

    await _addToHistory(
      type: 'large_transaction',
      title: 'Large Transaction',
      message: '\$${amount.toStringAsFixed(2)}',
      severity: 'medium',
    );
  }

  /// Add alert to history
  Future<void> _addToHistory({
    required String type,
    required String title,
    required String message,
    required String severity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_alertHistoryKey);

    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }

    history.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });

    // Keep only last 100 alerts
    if (history.length > 100) {
      history = history.sublist(0, 100);
    }

    await prefs.setString(_alertHistoryKey, jsonEncode(history));
  }

  /// Get alert history
  Future<List<Map<String, dynamic>>> getAlertHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_alertHistoryKey);

    if (historyJson == null) return [];

    return List<Map<String, dynamic>>.from(jsonDecode(historyJson));
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    final history = await getAlertHistory();
    final index = history.indexWhere((alert) => alert['id'] == alertId);

    if (index != -1) {
      history[index]['read'] = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_alertHistoryKey, jsonEncode(history));
    }
  }

  /// Clear alert history
  Future<void> clearAlertHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_alertHistoryKey);
  }

  /// Get active alerts count
  Future<int> getActiveAlertsCount() async {
    final history = await getAlertHistory();
    return history.where((alert) => alert['read'] == false).length;
  }

  /// Get alert statistics
  Future<Map<String, dynamic>> getAlertStatistics() async {
    final history = await getAlertHistory();
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));

    final recentAlerts = history.where((alert) {
      final alertDate = DateTime.parse(alert['timestamp']);
      return alertDate.isAfter(last30Days);
    }).toList();

    final byType = <String, int>{};
    final bySeverity = <String, int>{};

    for (var alert in recentAlerts) {
      final type = alert['type'] as String;
      final severity = alert['severity'] as String;

      byType[type] = (byType[type] ?? 0) + 1;
      bySeverity[severity] = (bySeverity[severity] ?? 0) + 1;
    }

    return {
      'totalAlerts': recentAlerts.length,
      'unreadAlerts': recentAlerts.where((a) => a['read'] == false).length,
      'byType': byType,
      'bySeverity': bySeverity,
      'lastAlertTime': history.isNotEmpty ? history.first['timestamp'] : null,
    };
  }
}
