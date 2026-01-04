import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/expense_data_service.dart';

class SmartInsightsWidget extends StatefulWidget {
  const SmartInsightsWidget({super.key});

  @override
  State<SmartInsightsWidget> createState() => _SmartInsightsWidgetState();
}

class _SmartInsightsWidgetState extends State<SmartInsightsWidget> {
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  List<Map<String, dynamic>> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
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
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final thisMonthTotal = await _expenseDataService.getTotalSpending(
        startDate: thisMonthStart,
        endDate: now,
      );

      final budget = 2000.0;
      final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
      final budgetRemaining = budget - thisMonthTotal;

      if (thisMonthTotal > 0) {
        if (budgetRemaining > 0 && daysLeft > 0) {
          insights.add({
            "icon": "trending_down",
            "title": "On Track!",
            "description":
                "You're doing great! You have \$${budgetRemaining.toStringAsFixed(0)} remaining with $daysLeft days left this month.",
            "color": AppTheme.successLight,
          });
        } else if (budgetRemaining < 0) {
          insights.add({
            "icon": "lightbulb",
            "title": "Budget Alert",
            "description":
                "You've exceeded your monthly budget by \$${(-budgetRemaining).toStringAsFixed(0)}. Consider reviewing your spending.",
            "color": AppTheme.warningLight,
          });
        }
      }

      final categorySpending = await _expenseDataService.getSpendingByCategory(
        startDate: thisMonthStart,
        endDate: now,
      );

      if (categorySpending.isNotEmpty) {
        final topCategory = categorySpending.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        final percentage = (topCategory.value / thisMonthTotal * 100)
            .toStringAsFixed(0);

        insights.add({
          "icon": "info",
          "title": "Top Spending Category",
          "description":
              "${topCategory.key} accounts for $percentage% of your spending this month (\$${topCategory.value.toStringAsFixed(0)}).",
          "color": Theme.of(context).colorScheme.primary,
        });
      }
    }

    setState(() {
      _insights = insights;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return SizedBox(
        height: 10.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'psychology',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Smart Insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: _insights.length,
          itemBuilder: (context, index) {
            final insight = _insights[index];
            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (insight["color"] as Color).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: (insight["color"] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: insight["icon"],
                      color: insight["color"] as Color,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight["title"],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          insight["description"],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
