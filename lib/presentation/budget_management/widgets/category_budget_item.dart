import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual category budget item with progress bar and actions
class CategoryBudgetItem extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double budgetLimit;
  final double spentAmount;
  final VoidCallback onTap;
  final VoidCallback onAdjustLimit;
  final VoidCallback onViewTransactions;
  final VoidCallback onSetAlert;
  final VoidCallback onDelete;

  const CategoryBudgetItem({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.budgetLimit,
    required this.spentAmount,
    required this.onTap,
    required this.onAdjustLimit,
    required this.onViewTransactions,
    required this.onSetAlert,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = budgetLimit > 0
        ? (spentAmount / budgetLimit * 100).clamp(0, 100)
        : 0.0;
    final remainingAmount = budgetLimit - spentAmount;

    return Slidable(
      key: ValueKey(categoryName),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onAdjustLimit();
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Adjust',
          ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onViewTransactions();
            },
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            icon: Icons.receipt_long,
            label: 'View',
          ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.lightImpact();
              onSetAlert();
            },
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            icon: Icons.notifications,
            label: 'Alert',
          ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              onDelete();
            },
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 12.h, maxHeight: 15.h),
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(3.w),
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
              // Category Header
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _getIconName(categoryIcon),
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '\$${spentAmount.toStringAsFixed(0)} of \$${budgetLimit.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: percentage >= 90
                              ? const Color(0xFFD32F2F)
                              : theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        remainingAmount >= 0
                            ? '\$${remainingAmount.toStringAsFixed(0)} left'
                            : 'Over budget',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: remainingAmount >= 0
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surface.withValues(
                    alpha: 0.3,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage >= 90
                        ? const Color(0xFFD32F2F)
                        : percentage >= 75
                        ? const Color(0xFFFF9800)
                        : categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.movie) return 'movie';
    if (icon == Icons.medical_services) return 'medical_services';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.fitness_center) return 'fitness_center';
    return 'category';
  }
}
