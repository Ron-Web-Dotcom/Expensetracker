import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Monthly spending card with progress bar and budget comparison
class MonthlySpendingCardWidget extends StatelessWidget {
  final double monthlySpending;
  final double monthlyBudget;
  final double spendingPercentage;
  final bool isBalanceVisible;

  const MonthlySpendingCardWidget({
    super.key,
    required this.monthlySpending,
    required this.monthlyBudget,
    required this.spendingPercentage,
    required this.isBalanceVisible,
  });

  Color _getStatusColor(BuildContext context, double percentage) {
    final theme = Theme.of(context);
    if (percentage >= 90) {
      return theme.colorScheme.error;
    } else if (percentage >= 75) {
      return const Color(0xFFFF9800);
    } else {
      return theme.colorScheme.primary;
    }
  }

  String _getStatusText(double percentage) {
    if (percentage >= 90) {
      return 'Budget Alert';
    } else if (percentage >= 75) {
      return 'Approaching Limit';
    } else {
      return 'On Track';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context, spendingPercentage);
    final remaining = monthlyBudget - monthlySpending;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Spending',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(spendingPercentage),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            isBalanceVisible
                ? '\$${monthlySpending.toStringAsFixed(2)}'
                : '••••••',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 36.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'of \$${monthlyBudget.toStringAsFixed(2)} budget',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.7,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: spendingPercentage / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${spendingPercentage.toStringAsFixed(1)}% used',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              Text(
                '\$${remaining.toStringAsFixed(2)} remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
