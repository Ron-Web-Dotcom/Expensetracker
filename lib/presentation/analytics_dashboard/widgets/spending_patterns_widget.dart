import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';
import '../../../services/expense_data_service.dart';

class SpendingPatternsWidget extends StatefulWidget {
  final String period;

  const SpendingPatternsWidget({super.key, required this.period});

  @override
  State<SpendingPatternsWidget> createState() => _SpendingPatternsWidgetState();
}

class _SpendingPatternsWidgetState extends State<SpendingPatternsWidget> {
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  bool _showWeekdays = true;
  List<Map<String, dynamic>> _weekdayData = [];
  List<Map<String, dynamic>> _weekendData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatternData();
  }

  @override
  void didUpdateWidget(SpendingPatternsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loadPatternData();
    }
  }

  Future<void> _loadPatternData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (widget.period == 'Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (widget.period == 'Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, 1, 1);
    }

    final dailySpending = await _expenseDataService.getDailySpending(
      startDate: startDate,
      endDate: endDate,
    );

    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final weekendLabels = ['Sat', 'Sun'];

    final Map<int, double> weekdayTotals = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final Map<int, double> weekendTotals = {6: 0, 7: 0};
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final Map<int, int> weekendCounts = {6: 0, 7: 0};

    dailySpending.forEach((dateKey, amount) {
      final date = DateTime.parse(dateKey);
      final weekday = date.weekday;

      if (weekday <= 5) {
        weekdayTotals[weekday] = (weekdayTotals[weekday] ?? 0) + amount;
        weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
      } else {
        weekendTotals[weekday] = (weekendTotals[weekday] ?? 0) + amount;
        weekendCounts[weekday] = (weekendCounts[weekday] ?? 0) + 1;
      }
    });

    final List<Map<String, dynamic>> weekdayData = [];
    for (int i = 1; i <= 5; i++) {
      final count = weekdayCounts[i] ?? 1;
      weekdayData.add({
        "label": weekdayLabels[i - 1],
        "value": (weekdayTotals[i] ?? 0) / count,
      });
    }

    final List<Map<String, dynamic>> weekendData = [];
    for (int i = 6; i <= 7; i++) {
      final count = weekendCounts[i] ?? 1;
      weekendData.add({
        "label": weekendLabels[i - 6],
        "value": (weekendTotals[i] ?? 0) / count,
      });
    }

    setState(() {
      _weekdayData = weekdayData;
      _weekendData = weekendData;
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

    final displayData = _showWeekdays ? _weekdayData : _weekendData;
    final maxValue = displayData.isEmpty
        ? 100.0
        : (displayData
                  .map((e) => e["value"] as double)
                  .reduce((a, b) => a > b ? a : b) *
              1.2);
    final hasData = displayData.any((e) => (e["value"] as double) > 0);

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
                'Spending Patterns',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showWeekdays = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: _showWeekdays
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Weekdays',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _showWeekdays
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showWeekdays = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: !_showWeekdays
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Weekend',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: !_showWeekdays
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (!hasData)
            SizedBox(
              height: 20.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No pattern data yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Add expenses to see patterns',
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
            SizedBox(
              height: 20.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.primary,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '\${rod.toY.toStringAsFixed(0)}',
                          theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < displayData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                displayData[value.toInt()]["label"],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxValue / 4,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: List.generate(
                    displayData.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: displayData[index]["value"] as double,
                          color: theme.colorScheme.primary,
                          width: 8.w,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
