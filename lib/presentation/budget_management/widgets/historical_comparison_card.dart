import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Historical comparison card showing previous period performance
class HistoricalComparisonCard extends StatelessWidget {
  final double previousPeriodSpent;
  final double currentPeriodSpent;
  final String periodLabel;

  const HistoricalComparisonCard({
    super.key,
    required this.previousPeriodSpent,
    required this.currentPeriodSpent,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difference = currentPeriodSpent - previousPeriodSpent;
    final percentageChange = previousPeriodSpent > 0
        ? (difference / previousPeriodSpent * 100)
        : 0.0;
    final isIncrease = difference > 0;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 14.h, maxHeight: 18.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Compared to $periodLabel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isIncrease
                      ? const Color(0xFFD32F2F).withValues(alpha: 0.1)
                      : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: isIncrease ? 'trending_up' : 'trending_down',
                      color: isIncrease
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF4CAF50),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${percentageChange.abs().toStringAsFixed(1)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isIncrease
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildComparisonDetail(
                  context,
                  'Previous',
                  '\$${previousPeriodSpent.toStringAsFixed(0)}',
                  theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildComparisonDetail(
                  context,
                  'Current',
                  '\$${currentPeriodSpent.toStringAsFixed(0)}',
                  theme.colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildComparisonDetail(
                  context,
                  'Difference',
                  '${isIncrease ? '+' : ''}\$${difference.abs().toStringAsFixed(0)}',
                  isIncrease
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonDetail(
    BuildContext context,
    String label,
    String amount,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
