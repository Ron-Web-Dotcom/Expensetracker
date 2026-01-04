import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final double avgLoadTime;
  final double apiResponseRate;
  final double errorFrequency;

  const PerformanceMetricsWidget({
    super.key,
    required this.avgLoadTime,
    required this.apiResponseRate,
    required this.errorFrequency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'speed',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Performance Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildMetricRow(
              context,
              'App Load Time',
              '${avgLoadTime.toStringAsFixed(1)}s',
              avgLoadTime < 2.0,
            ),
            SizedBox(height: 1.5.h),
            _buildMetricRow(
              context,
              'API Response Rate',
              '${apiResponseRate.toStringAsFixed(1)}%',
              apiResponseRate > 95.0,
            ),
            SizedBox(height: 1.5.h),
            _buildMetricRow(
              context,
              'Error Frequency',
              '${errorFrequency.toStringAsFixed(1)}%',
              errorFrequency < 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    bool isGood,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isGood ? AppTheme.successLight : AppTheme.warningLight,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              isGood ? Icons.check_circle : Icons.warning,
              color: isGood ? AppTheme.successLight : AppTheme.warningLight,
              size: 16,
            ),
          ],
        ),
      ],
    );
  }
}
