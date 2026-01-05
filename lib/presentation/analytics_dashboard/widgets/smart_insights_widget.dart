import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/budget_data_service.dart';
import '../../../services/expense_data_service.dart';

class SmartInsightsWidget extends StatefulWidget {
  final String period;

  const SmartInsightsWidget({super.key, required this.period});

  @override
  State<SmartInsightsWidget> createState() => _SmartInsightsWidgetState();
}

class _SmartInsightsWidgetState extends State<SmartInsightsWidget> {
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final BudgetDataService _budgetDataService = BudgetDataService();
  List<Map<String, dynamic>> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  @override
  void didUpdateWidget(SmartInsightsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loadInsights();
    }
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final expenses = await _expenseDataService.getAllExpenses();

    final List<Map<String, dynamic>> insights = [];

    if (expenses.isEmpty) {
      insights.add({
        "icon": "info",
        "title": "Get Started",
        "description":
            "Start tracking your expenses to receive personalized insights and spending recommendations.",
        "color": Theme.of(context).colorScheme.primary,
      });
    } else {
      DateTime currentStart, currentEnd, previousStart, previousEnd;
      String periodLabel, previousLabel;
      int daysInPeriod, daysElapsed;

      if (widget.period == 'Week') {
        currentStart = now.subtract(Duration(days: now.weekday - 1));
        currentEnd = now;
        previousStart = currentStart.subtract(const Duration(days: 7));
        previousEnd = currentStart.subtract(const Duration(days: 1));
        periodLabel = 'week';
        previousLabel = 'last week';
        daysInPeriod = 7;
        daysElapsed = now.weekday;
      } else if (widget.period == 'Month') {
        currentStart = DateTime(now.year, now.month, 1);
        currentEnd = now;
        previousStart = DateTime(now.year, now.month - 1, 1);
        previousEnd = DateTime(now.year, now.month, 0);
        periodLabel = 'month';
        previousLabel = 'last month';
        daysInPeriod = DateTime(now.year, now.month + 1, 0).day;
        daysElapsed = now.day;
      } else {
        currentStart = DateTime(now.year, 1, 1);
        currentEnd = now;
        previousStart = DateTime(now.year - 1, 1, 1);
        previousEnd = DateTime(now.year - 1, 12, 31);
        periodLabel = 'year';
        previousLabel = 'last year';
        daysInPeriod = 365;
        daysElapsed = now.difference(currentStart).inDays + 1;
      }

      final currentTotal = await _expenseDataService.getTotalSpending(
        startDate: currentStart,
        endDate: currentEnd,
      );

      final previousTotal = await _expenseDataService.getTotalSpending(
        startDate: previousStart,
        endDate: previousEnd,
      );

      // Get actual budget from BudgetDataService
      double totalBudget = await _budgetDataService.getTotalBudget();

      // If no total budget, sum category budgets
      if (totalBudget == 0) {
        final categoryBudgets = await _budgetDataService
            .getAllCategoryBudgets();
        for (var budget in categoryBudgets) {
          totalBudget += (budget['amount'] as num).toDouble();
        }
      }

      // Use default if no budgets set
      if (totalBudget == 0) {
        totalBudget = 2000.0;
      }

      final daysLeft = daysInPeriod - daysElapsed;
      final budgetRemaining = totalBudget - currentTotal;
      final dailyBudgetRemaining = daysLeft > 0
          ? budgetRemaining / daysLeft
          : 0;

      // Insight 1: Budget Status
      if (currentTotal > 0) {
        if (budgetRemaining > 0 && daysLeft > 0) {
          final percentUsed = (currentTotal / totalBudget * 100)
              .toStringAsFixed(0);
          insights.add({
            "icon": "trending_down",
            "title": "Budget Status: On Track",
            "description":
                "You've used $percentUsed% of your budget. \$${budgetRemaining.toStringAsFixed(0)} remaining for $daysLeft days. Daily budget: \$${dailyBudgetRemaining.toStringAsFixed(0)}.",
            "color": AppTheme.successLight,
          });
        } else if (budgetRemaining < 0) {
          insights.add({
            "icon": "warning",
            "title": "Budget Exceeded",
            "description":
                "You've exceeded your $periodLabel budget by \$${(-budgetRemaining).toStringAsFixed(0)}. Consider reducing discretionary spending.",
            "color": AppTheme.errorLight,
          });
        } else if (daysLeft > 0 && budgetRemaining > 0) {
          insights.add({
            "icon": "check_circle",
            "title": "Great Progress!",
            "description":
                "You have \$${budgetRemaining.toStringAsFixed(0)} left for $daysLeft days. Stay on track!",
            "color": AppTheme.successLight,
          });
        }
      }

      // Insight 2: Period-over-Period Comparison
      if (previousTotal > 0 && currentTotal > 0) {
        final difference = currentTotal - previousTotal;
        final percentChange = (difference / previousTotal * 100)
            .abs()
            .toStringAsFixed(0);

        if (difference > 0) {
          insights.add({
            "icon": "trending_up",
            "title": "Spending Increased",
            "description":
                "Your spending is up $percentChange% compared to $previousLabel (\$${difference.toStringAsFixed(0)} more). Review your expenses to identify areas to cut back.",
            "color": AppTheme.warningLight,
          });
        } else if (difference < 0) {
          insights.add({
            "icon": "trending_down",
            "title": "Spending Decreased",
            "description":
                "Great job! You've reduced spending by $percentChange% compared to $previousLabel (\$${(-difference).toStringAsFixed(0)} saved).",
            "color": AppTheme.successLight,
          });
        }
      }

      // Insight 3: Top Spending Category Analysis
      final categorySpending = await _expenseDataService.getSpendingByCategory(
        startDate: currentStart,
        endDate: currentEnd,
      );

      if (categorySpending.isNotEmpty) {
        final topCategory = categorySpending.entries.reduce(
          (a, b) => a.value.abs() > b.value.abs() ? a : b,
        );
        final topAmount = topCategory.value.abs();
        final percentage = (topAmount / currentTotal * 100).toStringAsFixed(0);

        // Get previous period's spending for this category
        final previousCategorySpending = await _expenseDataService
            .getSpendingByCategory(
              startDate: previousStart,
              endDate: previousEnd,
            );
        final previousCategoryAmount =
            previousCategorySpending[topCategory.key]?.abs() ?? 0;

        String recommendation = "";
        if (previousCategoryAmount > 0) {
          final categoryChange = topAmount - previousCategoryAmount;
          if (categoryChange > 0) {
            recommendation =
                " This is \$${categoryChange.toStringAsFixed(0)} more than $previousLabel.";
          }
        }

        insights.add({
          "icon": "pie_chart",
          "title": "Top Category: ${topCategory.key}",
          "description":
              "${topCategory.key} accounts for $percentage% of your spending (\$${topAmount.toStringAsFixed(0)}).$recommendation",
          "color": Theme.of(context).colorScheme.primary,
        });
      }

      // Insight 4: Spending Velocity Analysis
      if (daysElapsed > 0 && currentTotal > 0) {
        final dailyAverage = currentTotal / daysElapsed;
        final projectedPeriodTotal = dailyAverage * daysInPeriod;

        if (projectedPeriodTotal > totalBudget * 1.1) {
          final projectedOverage = projectedPeriodTotal - totalBudget;
          insights.add({
            "icon": "speed",
            "title": "Spending Too Fast",
            "description":
                "At your current pace (\$${dailyAverage.toStringAsFixed(0)}/day), you'll exceed budget by \$${projectedOverage.toStringAsFixed(0)}. Reduce daily spending to \$${dailyBudgetRemaining.toStringAsFixed(0)}.",
            "color": AppTheme.warningLight,
          });
        } else if (projectedPeriodTotal < totalBudget * 0.8) {
          insights.add({
            "icon": "savings",
            "title": "Excellent Savings Pace",
            "description":
                "You're on track to save \$${(totalBudget - projectedPeriodTotal).toStringAsFixed(0)} this $periodLabel! Keep up the great work.",
            "color": AppTheme.successLight,
          });
        }
      }

      // Insight 5: Unusual Spending Detection
      final recentExpenses = expenses.where((e) {
        final expenseDate = DateTime.parse(e['date']);
        return expenseDate.isAfter(now.subtract(const Duration(days: 7)));
      }).toList();

      if (recentExpenses.isNotEmpty) {
        final recentTotal = recentExpenses.fold<double>(0, (sum, e) {
          final amount = (e['amount'] as num).toDouble();
          return sum + amount.abs();
        });
        final weeklyAverage = currentTotal / (daysElapsed / 7);

        if (recentTotal > weeklyAverage * 1.5) {
          insights.add({
            "icon": "notification_important",
            "title": "Unusual Spending Detected",
            "description":
                "You've spent \$${recentTotal.toStringAsFixed(0)} in the last 7 days, which is higher than your weekly average. Review recent transactions.",
            "color": AppTheme.warningLight,
          });
        }
      }

      // Insight 6: Category Budget Recommendations
      if (categorySpending.length > 1) {
        final sortedCategories = categorySpending.entries.toList()
          ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

        if (sortedCategories.length >= 2) {
          final top1 = sortedCategories[0];
          final top2 = sortedCategories[1];
          final top1Amount = top1.value.abs();
          final top2Amount = top2.value.abs();

          if (top1Amount > top2Amount * 2) {
            insights.add({
              "icon": "lightbulb",
              "title": "Rebalance Spending",
              "description":
                  "${top1.key} spending (\$${top1Amount.toStringAsFixed(0)}) is significantly higher than other categories. Consider setting a category budget limit.",
              "color": Theme.of(context).colorScheme.secondary,
            });
          }
        }
      }
    }

    setState(() {
      _insights = insights.take(6).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
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
        height: 30.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Smart Insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'auto_awesome',
                      color: theme.colorScheme.secondary,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'AI Powered',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_insights.isEmpty)
            SizedBox(
              height: 15.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No insights yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Add expenses to get insights',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._insights.map((insight) {
              return Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: (insight["color"] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (insight["color"] as Color).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: insight["color"] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: insight["icon"],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight["title"],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            insight["description"],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
