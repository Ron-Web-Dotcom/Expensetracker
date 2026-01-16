import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/completion_calendar_widget.dart';
import './widgets/habit_streak_widget.dart';
import './widgets/quick_log_action_widget.dart';
import './widgets/reminder_history_item_widget.dart';

class ReminderNotificationCenter extends StatefulWidget {
  const ReminderNotificationCenter({super.key});

  @override
  State<ReminderNotificationCenter> createState() =>
      _ReminderNotificationCenterState();
}

class _ReminderNotificationCenterState
    extends State<ReminderNotificationCenter> {
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notificationService = NotificationService();

  int _reminderStreak = 0;
  List<Map<String, dynamic>> _reminderHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('reminder_notification_center');
    _loadReminderData();
  }

  Future<void> _loadReminderData() async {
    setState(() => _isLoading = true);

    final streak = await _notificationService.getReminderStreak();
    final history = await _notificationService.getReminderHistory();

    setState(() {
      _reminderStreak = streak;
      _reminderHistory = history;
      _isLoading = false;
    });
  }

  double _calculateWeeklyCompletionRate() {
    if (_reminderHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyReminders = _reminderHistory.where((reminder) {
      final timestampStr = reminder['timestamp'];
      if (timestampStr == null) return false;

      try {
        final timestamp = DateTime.parse(timestampStr);
        return timestamp.isAfter(weekAgo);
      } catch (e) {
        return false;
      }
    }).toList();

    if (weeklyReminders.isEmpty) return 0.0;

    final completed = weeklyReminders
        .where((r) => r['responseType'] == 'logged')
        .length;

    return (completed / weeklyReminders.length * 100);
  }

  Future<void> _handleQuickLog() async {
    await _notificationService.logReminderResponse(true);
    _showSnackBar('Expense logged successfully!');
    Navigator.pushNamed(context, AppRoutes.addExpense);
    _analytics.trackEvent('quick_log_from_reminder');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: 'Reminder Center',
        variant: CustomAppBarVariant.withBack,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReminderData,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habit Streak Section
                    HabitStreakWidget(
                      streak: _reminderStreak,
                      weeklyCompletionRate: _calculateWeeklyCompletionRate(),
                    ),
                    SizedBox(height: 2.h),

                    // Quick Action Panel
                    QuickLogActionWidget(onQuickLog: _handleQuickLog),
                    SizedBox(height: 2.h),

                    // Completion Calendar
                    CompletionCalendarWidget(reminderHistory: _reminderHistory),
                    SizedBox(height: 2.h),

                    // Reminder History
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: Text(
                        'REMINDER HISTORY',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_reminderHistory.isEmpty)
                      Container(
                        margin: EdgeInsets.all(4.w),
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.history,
                                size: 12.w,
                                color: isDark
                                    ? const Color(0xFF3D3D3D)
                                    : const Color(0xFFE0E0E0),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No reminder history yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : const Color(0xFF757575),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Your reminder responses will appear here',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? const Color(0xFF757575)
                                      : const Color(0xFF9E9E9E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._reminderHistory.take(20).map((reminder) {
                        return ReminderHistoryItemWidget(
                          timestamp: DateTime.parse(reminder['timestamp']),
                          responseType: reminder['responseType'],
                        );
                      }),
                    SizedBox(height: 2.h),

                    // Smart Insights
                    Container(
                      margin: EdgeInsets.all(4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: theme.colorScheme.primary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Smart Insight',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _getSmartInsight(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? const Color(0xFFB0B0B0)
                                  : const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
    );
  }

  String _getSmartInsight() {
    final completionRate = _calculateWeeklyCompletionRate();

    if (completionRate >= 80) {
      return 'Excellent! You\'re maintaining a strong expense tracking habit. Keep up the great work!';
    } else if (completionRate >= 50) {
      return 'Good progress! Try responding to more reminders to build a stronger tracking habit.';
    } else if (_reminderHistory.isEmpty) {
      return 'Enable daily reminders in settings to start building your expense tracking habit.';
    } else {
      return 'Consistency is key! Try setting your reminder time to match your daily routine.';
    }
  }
}
