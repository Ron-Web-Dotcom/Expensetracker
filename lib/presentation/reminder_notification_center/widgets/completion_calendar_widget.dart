import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class CompletionCalendarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reminderHistory;

  const CompletionCalendarWidget({super.key, required this.reminderHistory});

  Map<String, int> _getCompletionData() {
    final Map<String, int> completionMap = {};

    for (var reminder in reminderHistory) {
      final timestamp = DateTime.parse(reminder['timestamp']);
      final dateKey = DateFormat('yyyy-MM-dd').format(timestamp);

      if (reminder['responseType'] == 'logged') {
        completionMap[dateKey] = (completionMap[dateKey] ?? 0) + 1;
      }
    }

    return completionMap;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completionData = _getCompletionData();

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Completion Calendar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF212121),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildCalendarGrid(context, completionData),
          SizedBox(height: 2.h),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    Map<String, int> completionData,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 27));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 1.w,
        mainAxisSpacing: 1.w,
      ),
      itemCount: 28,
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final completionCount = completionData[dateKey] ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: _getCompletionColor(context, completionCount),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: Text(
              '${date.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: completionCount > 0
                    ? Colors.white
                    : (theme.brightness == Brightness.dark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575)),
                fontSize: 10.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCompletionColor(BuildContext context, int count) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (count == 0) {
      return isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5);
    } else if (count == 1) {
      return theme.colorScheme.primary.withAlpha(77);
    } else if (count == 2) {
      return theme.colorScheme.primary.withAlpha(153);
    } else {
      return theme.colorScheme.primary;
    }
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
          ),
        ),
        SizedBox(width: 2.w),
        ...List.generate(4, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 0.5.w),
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: _getCompletionColor(context, index),
              borderRadius: BorderRadius.circular(2.0),
            ),
          );
        }),
        SizedBox(width: 2.w),
        Text(
          'More',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
          ),
        ),
      ],
    );
  }
}
