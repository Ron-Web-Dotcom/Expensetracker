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
    DateTime currentStart, currentEnd, previousStart, previousEnd;
    String periodLabel, previousLabel;
    int daysInPeriod;

    if (widget.period == 'Week') {
      // Current week (Monday to today)
      currentStart = now.subtract(Duration(days: now.weekday - 1));
      currentEnd = now;
      // Previous week
      previousStart = currentStart.subtract(const Duration(days: 7));
      previousEnd = currentStart.subtract(const Duration(days: 1));
      periodLabel = 'This Week';
      previousLabel = 'vs last week';
      daysInPeriod = 7;
    } else if (widget.period == 'Month') {
      // Current month
      currentStart = DateTime(now.year, now.month, 1);
      currentEnd = now;
      // Previous month
      previousStart = DateTime(now.year, now.month - 1, 1);
      previousEnd = DateTime(now.year, now.month, 0);
      periodLabel = 'This Month';
      previousLabel = 'vs last month';
      daysInPeriod = DateTime(now.year, now.month + 1, 0).day;
    } else {
      // Current year
      currentStart = DateTime(now.year, 1, 1);
      currentEnd = now;
      // Previous year
      previousStart = DateTime(now.year - 1, 1, 1);
      previousEnd = DateTime(now.year - 1, 12, 31);
      periodLabel = 'This Year';
      previousLabel = 'vs last year';
      daysInPeriod = 365;
    }

    final currentTotal = await _expenseDataService.getTotalSpending(
      startDate: currentStart,
      endDate: currentEnd,
    );

    final previousTotal = await _expenseDataService.getTotalSpending(
      startDate: previousStart,
      endDate: previousEnd,
    );

    final dailySpending = await _expenseDataService.getDailySpending(
      startDate: currentStart,
      endDate: currentEnd,
    );

    final daysWithData = dailySpending.values.where((v) => v > 0).length;
    final averageDaily = daysWithData > 0 ? currentTotal / daysWithData : 0.0;

    final highestDay = dailySpending.values.isEmpty
        ? 0.0
        : dailySpending.values.reduce((a, b) => a > b ? a : b);

    final previousDaysCount = previousEnd.difference(previousStart).inDays + 1;
    final previousAverage = previousDaysCount > 0
        ? previousTotal / previousDaysCount
        : 0.0;

    final periodChange = previousTotal > 0
        ? ((currentTotal - previousTotal) / previousTotal * 100)
        : 0.0;

    final dailyChange = previousAverage > 0
        ? ((averageDaily - previousAverage) / previousAverage * 100)
        : 0.0;

    // Only show data if there are actual expenses
    final List<Map<String, dynamic>> data = [];

    if (currentTotal > 0 || previousTotal > 0) {
      data.addAll([
        {
          "title": periodLabel,
          "amount": "\${currentTotal.toStringAsFixed(0)}",
          "change":
              "${periodChange >= 0 ? '+' : ''}${periodChange.toStringAsFixed(1)}%",
          "isPositive": periodChange <= 0,
          "subtitle": previousLabel,
        },
        {
          "title": "Average Daily",
          "amount": "\${averageDaily.toStringAsFixed(2)}",
          "change":
              "${dailyChange >= 0 ? '+' : ''}${dailyChange.toStringAsFixed(1)}%",
          "isPositive": dailyChange <= 0,
          "subtitle": previousLabel,
        },
        {
          "title": "Highest Day",
          "amount": "\${highestDay.toStringAsFixed(0)}",
          "change": daysWithData > 0
              ? "\$daysWithData days tracked"
              : "No data",
          "isPositive": true,
          "subtitle": daysWithData > 0 ? periodLabel : "Add expenses",
        },
      ]);
    }

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
            '${widget.period}ly Comparison',
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
