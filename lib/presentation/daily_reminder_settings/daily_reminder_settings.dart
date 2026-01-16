import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/reminder_type_card_widget.dart';
import './widgets/time_slot_picker_widget.dart';
import './widgets/reminder_preview_widget.dart';

class DailyReminderSettings extends StatefulWidget {
  const DailyReminderSettings({super.key});

  @override
  State<DailyReminderSettings> createState() => _DailyReminderSettingsState();
}

class _DailyReminderSettingsState extends State<DailyReminderSettings> {
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  Set<String> _selectedReminderTypes = {'expense_logging'};

  final Map<String, Map<String, String>> _reminderTypeData = {
    'expense_logging': {
      'title': 'Daily Check-ins',
      'description': 'Evening expense review prompts',
      'icon': 'receipt_long',
    },
    'receipt_capture': {
      'title': 'Receipt Reminders',
      'description': 'Photo capture nudges after spending',
      'icon': 'camera_alt',
    },
    'budget_review': {
      'title': 'Budget Awareness',
      'description': 'Weekly spending status updates',
      'icon': 'account_balance_wallet',
    },
    'goal_tracking': {
      'title': 'Goal Tracking',
      'description': 'Milestone progress notifications',
      'icon': 'emoji_events',
    },
  };

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('daily_reminder_settings');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('daily_reminder_enabled') ?? false;
    final timeString = await _notificationService.getDailyReminderTime();
    final types = await _notificationService.getDailyReminderTypes();

    setState(() {
      _reminderEnabled = enabled;
      if (timeString != null) {
        final timeParts = timeString.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
      _selectedReminderTypes = types.toSet();
    });
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _reminderEnabled = value);

    if (value) {
      await _notificationService.scheduleDailyReminder(
        time: '${_reminderTime.hour}:${_reminderTime.minute}',
        reminderTypes: _selectedReminderTypes.toList(),
      );
      _showSnackBar(
        'Daily reminder enabled for ${_reminderTime.format(context)}',
      );
    } else {
      await _notificationService.cancelDailyReminder();
      _showSnackBar('Daily reminder disabled');
    }

    _analytics.trackEvent(
      'daily_reminder_toggled',
      parameters: {'enabled': value},
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              hourMinuteTextColor: theme.colorScheme.primary,
              dialHandColor: theme.colorScheme.primary,
              dialBackgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFF5F5F5),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);

      if (_reminderEnabled) {
        await _notificationService.scheduleDailyReminder(
          time: '${_reminderTime.hour}:${_reminderTime.minute}',
          reminderTypes: _selectedReminderTypes.toList(),
        );
        _showSnackBar(
          'Reminder time updated to ${_reminderTime.format(context)}',
        );
      }

      _analytics.trackEvent(
        'reminder_time_changed',
        parameters: {'time': '${picked.hour}:${picked.minute}'},
      );
    }
  }

  void _toggleReminderType(String type) {
    setState(() {
      if (_selectedReminderTypes.contains(type)) {
        if (_selectedReminderTypes.length > 1) {
          _selectedReminderTypes.remove(type);
        } else {
          _showSnackBar('At least one reminder type must be selected');
          return;
        }
      } else {
        _selectedReminderTypes.add(type);
      }
    });

    if (_reminderEnabled) {
      _notificationService.scheduleDailyReminder(
        time: '${_reminderTime.hour}:${_reminderTime.minute}',
        reminderTypes: _selectedReminderTypes.toList(),
      );
    }
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
        title: 'Daily Reminders',
        variant: CustomAppBarVariant.withBack,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master Toggle Section
              Container(
                margin: EdgeInsets.all(4.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _reminderEnabled
                        ? theme.colorScheme.primary.withAlpha(77)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(8.0),
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
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF212121),
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                _reminderEnabled
                                    ? 'Active at ${_reminderTime.format(context)}'
                                    : 'Currently disabled',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _reminderEnabled,
                          onChanged: _toggleReminder,
                          activeColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    if (_reminderEnabled) ...[
                      SizedBox(height: 2.h),
                      ReminderPreviewWidget(
                        reminderTime: _reminderTime,
                        reminderTypes: _selectedReminderTypes.toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Time Selection
              if (_reminderEnabled) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Text(
                    'REMINDER TIME',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                TimeSlotPickerWidget(
                  selectedTime: _reminderTime,
                  onTimeSelected: _selectTime,
                ),
                SizedBox(height: 2.h),

                // Reminder Types
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Text(
                    'REMINDER TYPES',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ..._reminderTypeData.entries.map((entry) {
                  return ReminderTypeCardWidget(
                    title: entry.value['title']!,
                    description: entry.value['description']!,
                    icon: entry.value['icon']!,
                    isSelected: _selectedReminderTypes.contains(entry.key),
                    onToggle: () => _toggleReminderType(entry.key),
                  );
                }),
                SizedBox(height: 2.h),
              ],

              // Help Text
              Container(
                margin: EdgeInsets.all(4.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Daily reminders help build consistent expense tracking habits. Choose reminder types that match your routine.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFB0B0B0)
                              : const Color(0xFF757575),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}