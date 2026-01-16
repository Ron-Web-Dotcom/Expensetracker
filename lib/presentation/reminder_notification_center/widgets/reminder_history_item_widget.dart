import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class ReminderHistoryItemWidget extends StatelessWidget {
  final DateTime timestamp;
  final String responseType;

  const ReminderHistoryItemWidget({
    super.key,
    required this.timestamp,
    required this.responseType,
  });

  IconData _getResponseIcon() {
    switch (responseType) {
      case 'logged':
        return Icons.check_circle;
      case 'dismissed':
        return Icons.cancel;
      case 'snoozed':
        return Icons.snooze;
      default:
        return Icons.notifications;
    }
  }

  Color _getResponseColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (responseType) {
      case 'logged':
        return Colors.green;
      case 'dismissed':
        return Colors.red;
      case 'snoozed':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getResponseText() {
    switch (responseType) {
      case 'logged':
        return 'Expense Logged';
      case 'dismissed':
        return 'Dismissed';
      case 'snoozed':
        return 'Snoozed';
      default:
        return 'Reminder Sent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getResponseColor(context).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getResponseIcon(),
              color: _getResponseColor(context),
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getResponseText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp),
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
    );
  }
}
