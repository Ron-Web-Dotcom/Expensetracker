import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Budget overview card showing total budget, spent, and remaining amounts
class BudgetOverviewCard extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;
  final double remainingAmount;
  final double spendingPercentage;

  const BudgetOverviewCard({
    super.key,
    required this.totalBudget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.spendingPercentage,
  });

  Color _getProgressColor(double percentage) {
    if (percentage < 50) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage < 75) {
      return const Color(0xFFFF9800); // Orange
    } else if (percentage < 90) {
      return const Color(0xFFFF5722); // Deep Orange
    } else {
      return const Color(0xFFD32F2F); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 28.h, maxHeight: 35.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Monthly Budget',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getProgressColor(
                    spendingPercentage,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${spendingPercentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _getProgressColor(spendingPercentage),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Circular Progress Indicator
          SizedBox(
            width: 30.w,
            height: 30.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: CircularProgressIndicator(
                    value: spendingPercentage / 100,
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.surface.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(spendingPercentage),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${spentAmount.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Spent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Budget Details
          Row(
            children: [
              Expanded(
                child: _buildBudgetDetail(
                  context,
                  'Total Budget',
                  '\$${totalBudget.toStringAsFixed(0)}',
                  theme.colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildBudgetDetail(
                  context,
                  'Remaining',
                  '\$${remainingAmount.toStringAsFixed(0)}',
                  remainingAmount > 0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDetail(
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
          style: theme.textTheme.titleLarge?.copyWith(
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
