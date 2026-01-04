import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/expense_data_service.dart';

class MonthlyComparisonWidget extends StatefulWidget {
  final String period;

  const MonthlyComparisonWidget({super.key, required this.period});

  @override
  State<MonthlyComparisonWidget> createState() =>
      _MonthlyComparisonWidgetState();
}

class _MonthlyComparisonWidgetState extends State<MonthlyComparisonWidget> {
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  List<Map<String, dynamic>> _comparisonData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparisonData();
  }

  @override
  void didUpdateWidget(MonthlyComparisonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loadComparisonData();
    }
  }

  Future<void> _loadComparisonData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = now;
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    final thisMonthTotal = await _expenseDataService.getTotalSpending(
      startDate: thisMonthStart,
      endDate: thisMonthEnd,
    );

    final lastMonthTotal = await _expenseDataService.getTotalSpending(
      startDate: lastMonthStart,
      endDate: lastMonthEnd,
    );

    final dailySpending = await _expenseDataService.getDailySpending(
      startDate: thisMonthStart,
      endDate: thisMonthEnd,
    );

    final daysWithData = dailySpending.values.where((v) => v > 0).length;
    final averageDaily = daysWithData > 0 ? thisMonthTotal / daysWithData : 0.0;

    final highestDay = dailySpending.values.isEmpty
        ? 0.0
        : dailySpending.values.reduce((a, b) => a > b ? a : b);

    final lastMonthAverage = lastMonthTotal / lastMonthEnd.day;
    final monthChange = lastMonthTotal > 0
        ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
        : 0.0;

    final dailyChange = lastMonthAverage > 0
        ? ((averageDaily - lastMonthAverage) / lastMonthAverage * 100)
        : 0.0;

    final budget = 2000.0;
    final budgetUsed = budget > 0 ? (thisMonthTotal / budget * 100) : 0.0;
    final budgetRemaining = budget - thisMonthTotal;

    final List<Map<String, dynamic>> data = [
      {
        "title": "This Month",
        "amount": "\$${thisMonthTotal.toStringAsFixed(0)}",
        "change":
            "${monthChange >= 0 ? '+' : ''}${monthChange.toStringAsFixed(1)}%",
        "isPositive": monthChange <= 0,
        "subtitle": "vs last month",
      },
      {
        "title": "Average Daily",
        "amount": "\$${averageDaily.toStringAsFixed(2)}",
        "change":
            "${dailyChange >= 0 ? '+' : ''}${dailyChange.toStringAsFixed(1)}%",
        "isPositive": dailyChange <= 0,
        "subtitle": "vs last month",
      },
      {
        "title": "Highest Day",
        "amount": "\$${highestDay.toStringAsFixed(0)}",
        "change": daysWithData > 0 ? "${now.day} days tracked" : "No data",
        "isPositive": true,
        "subtitle": daysWithData > 0 ? "This month" : "Add expenses",
      },
      {
        "title": "Budget Status",
        "amount": "${budgetUsed.toStringAsFixed(0)}%",
        "change": budgetUsed < 100 ? "On track" : "Over budget",
        "isPositive": budgetUsed < 80,
        "subtitle": budgetRemaining > 0
            ? "\$${budgetRemaining.toStringAsFixed(0)} remaining"
            : "Budget exceeded",
      },
    ];

    setState(() {
      _comparisonData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return SizedBox(
        height: 18.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Monthly Comparison',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 18.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _comparisonData.length,
            itemBuilder: (context, index) {
              final item = _comparisonData[index];
              return Container(
                width: 40.w,
                margin: EdgeInsets.only(right: 3.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["title"],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["amount"],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            if (item["change"].toString().contains('%'))
                              CustomIconWidget(
                                iconName: item["isPositive"]
                                    ? 'trending_down'
                                    : 'trending_up',
                                color: item["isPositive"]
                                    ? AppTheme.successLight
                                    : AppTheme.errorLight,
                                size: 16,
                              ),
                            if (item["change"].toString().contains('%'))
                              SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                item["change"],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: item["change"].toString().contains('%')
                                      ? (item["isPositive"]
                                            ? AppTheme.successLight
                                            : AppTheme.errorLight)
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      item["subtitle"],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
