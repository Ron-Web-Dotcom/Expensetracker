import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick action cards for frequent tasks
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onViewBudget;
  final VoidCallback onGenerateReport;

  const QuickActionsWidget({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onViewBudget,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            children: [
              _buildActionCard(
                context,
                icon: 'add_circle',
                label: 'Add Expense',
                color: theme.colorScheme.error,
                onTap: onAddExpense,
              ),
              SizedBox(width: 3.w),
              _buildActionCard(
                context,
                icon: 'trending_up',
                label: 'Add Income',
                color: theme.colorScheme.primary,
                onTap: onAddIncome,
              ),
              SizedBox(width: 3.w),
              _buildActionCard(
                context,
                icon: 'account_balance_wallet',
                label: 'View Budget',
                color: const Color(0xFF9C27B0),
                onTap: onViewBudget,
              ),
              SizedBox(width: 3.w),
              _buildActionCard(
                context,
                icon: 'assessment',
                label: 'Generate Report',
                color: const Color(0xFFFF9800),
                onTap: onGenerateReport,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(iconName: icon, color: color, size: 32),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
