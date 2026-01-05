import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SmartSchedulingWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(String key, dynamic value) onUpdate;

  const SmartSchedulingWidget({
    super.key,
    required this.settings,
    required this.onUpdate,
  });

  @override
  State<SmartSchedulingWidget> createState() => _SmartSchedulingWidgetState();
}

class _SmartSchedulingWidgetState extends State<SmartSchedulingWidget> {
  bool _isExpanded = false;

  Future<void> _selectTime(BuildContext context, String key, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      widget.onUpdate(key, formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withAlpha(26),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: const Color(0xFF9C27B0),
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Scheduling',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF212121),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Quiet hours & delivery preferences',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? const Color(0xFFB0B0B0)
                                : const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : const Color(0xFF757575),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF3D3D3D)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildToggleItem(
                    context,
                    'Quiet Hours',
                    'Pause alerts during specified hours',
                    'quietHoursEnabled',
                    widget.settings['quietHoursEnabled'] ?? false,
                  ),
                  if (widget.settings['quietHoursEnabled'] == true) ...[
                    _buildTimeItem(
                      context,
                      'Start Time',
                      widget.settings['quietHoursStart'] ?? '22:00',
                      'quietHoursStart',
                    ),
                    _buildTimeItem(
                      context,
                      'End Time',
                      widget.settings['quietHoursEnd'] ?? '07:00',
                      'quietHoursEnd',
                    ),
                  ],
                  _buildToggleItem(
                    context,
                    'Weekend Preference',
                    'Reduce alerts on weekends',
                    'weekendPreference',
                    widget.settings['weekendPreference'] ?? false,
                  ),
                  _buildToggleItem(
                    context,
                    'Push Notifications',
                    'Receive push notifications',
                    'pushNotificationsEnabled',
                    widget.settings['pushNotificationsEnabled'] ?? true,
                  ),
                  _buildToggleItem(
                    context,
                    'In-App Notifications',
                    'Show notifications within the app',
                    'inAppNotificationsEnabled',
                    widget.settings['inAppNotificationsEnabled'] ?? true,
                  ),
                  _buildSliderItem(
                    context,
                    'Max Alerts Per Day',
                    widget.settings['maxAlertsPerDay']?.toDouble() ?? 10.0,
                    'maxAlertsPerDay',
                    1.0,
                    20.0,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    String title,
    String subtitle,
    String key,
    bool value,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF3D3D3D)
                : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
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
            value: value,
            onChanged: (newValue) {
              widget.onUpdate(key, newValue);
            },
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(
    BuildContext context,
    String title,
    String time,
    String key,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _selectTime(context, key, time),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? const Color(0xFF3D3D3D)
                  : const Color(0xFFE0E0E0),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF212121),
              ),
            ),
            Row(
              children: [
                Text(
                  time,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderItem(
    BuildContext context,
    String title,
    double value,
    String key,
    double min,
    double max,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF3D3D3D)
                : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF212121),
                ),
              ),
              Text(
                value.toInt().toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: (newValue) {
              widget.onUpdate(key, newValue.toInt());
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}