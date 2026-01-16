import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReminderPreviewWidget extends StatelessWidget {
  final TimeOfDay reminderTime;
  final List<String> reminderTypes;

  const ReminderPreviewWidget({
    super.key,
    required this.reminderTime,
    required this.reminderTypes,
  });

  String _getNextReminderText(BuildContext context) {
    final now = DateTime.now();
    var nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (nextReminder.isBefore(now)) {
      nextReminder = nextReminder.add(const Duration(days: 1));
    }

    final difference = nextReminder.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'Next reminder in ${hours}h ${minutes}m';
    } else {
      return 'Next reminder in ${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: theme.colorScheme.primary, size: 4.w),
              SizedBox(width: 2.w),
              Text(
                _getNextReminderText(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Active types: ${reminderTypes.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}
