import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/reminder_schedule_overview_widget.dart';
import './widgets/reminder_streak_widget.dart';
import './widgets/reminder_time_selector_widget.dart';
import './widgets/reminder_type_selector_widget.dart';

class EnhancedSettings extends StatefulWidget {
  const EnhancedSettings({super.key});

  @override
  State<EnhancedSettings> createState() => _EnhancedSettingsState();
}

class _EnhancedSettingsState extends State<EnhancedSettings> {
  final _settingsService = SettingsService();
  final _notificationService = NotificationService();

  bool _dailyReminderEnabled = false;
  String _reminderTime = '19:00';
  List<String> _reminderTypes = ['expense_logging'];
  int _reminderStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _settingsService.isDailyReminderEnabled();
    final time = await _settingsService.getDailyReminderTime();
    final types = await _settingsService.getReminderTypes();
    final streak = await _notificationService.getReminderStreak();

    setState(() {
      _dailyReminderEnabled = enabled;
      _reminderTime = time;
      _reminderTypes = types;
      _reminderStreak = streak;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    await _settingsService.setDailyReminderEnabled(value);

    if (value) {
      await _notificationService.scheduleDailyReminder(
        time: _reminderTime,
        reminderTypes: _reminderTypes,
      );
    } else {
      await _notificationService.cancelDailyReminder();
    }

    setState(() => _dailyReminderEnabled = value);
  }

  Future<void> _updateReminderTime(String time) async {
    await _settingsService.setDailyReminderTime(time);
    setState(() => _reminderTime = time);

    if (_dailyReminderEnabled) {
      await _notificationService.scheduleDailyReminder(
        time: time,
        reminderTypes: _reminderTypes,
      );
    }
  }

  Future<void> _updateReminderTypes(List<String> types) async {
    await _settingsService.setReminderTypes(types);
    setState(() => _reminderTypes = types);

    if (_dailyReminderEnabled) {
      await _notificationService.scheduleDailyReminder(
        time: _reminderTime,
        reminderTypes: types,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      appBar: CustomAppBarFactory.withBack(
        title: 'Daily Reminders',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Master Toggle Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dailyReminderEnabled
                            ? theme.colorScheme.primary.withAlpha(77)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: theme.colorScheme.primary,
                            size: 6.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Reminders',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF212121),
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                _dailyReminderEnabled
                                    ? 'Active • $_reminderTime'
                                    : 'Tap to enable daily reminders',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _dailyReminderEnabled
                                      ? theme.colorScheme.primary
                                      : (isDark
                                            ? const Color(0xFFB0B0B0)
                                            : const Color(0xFF757575)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _dailyReminderEnabled,
                          onChanged: _toggleReminder,
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  if (_dailyReminderEnabled) ...[
                    SizedBox(height: 2.h),

                    // Reminder Streak
                    ReminderStreakWidget(streak: _reminderStreak),

                    SizedBox(height: 2.h),

                    // Time Selector
                    ReminderTimeSelectorWidget(
                      selectedTime: _reminderTime,
                      onTimeChanged: _updateReminderTime,
                    ),

                    SizedBox(height: 2.h),

                    // Reminder Type Selector
                    ReminderTypeSelectorWidget(
                      selectedTypes: _reminderTypes,
                      onTypesChanged: _updateReminderTypes,
                    ),

                    SizedBox(height: 2.h),

                    // Schedule Overview
                    ReminderScheduleOverviewWidget(
                      reminderTime: _reminderTime,
                      reminderTypes: _reminderTypes,
                    ),

                    SizedBox(height: 2.h),

                    // Tips Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(13),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                            size: 5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pro Tip',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Set reminders for evening hours (7-8 PM) when you\'re most likely to reflect on daily spending.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? const Color(0xFFB0B0B0)
                                        : const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }
}
