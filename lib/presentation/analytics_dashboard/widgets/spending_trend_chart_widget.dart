import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';
import '../../../services/expense_data_service.dart';

class SpendingTrendChartWidget extends StatefulWidget {
  final String period;

  const SpendingTrendChartWidget({super.key, required this.period});

  @override
  State<SpendingTrendChartWidget> createState() =>
      _SpendingTrendChartWidgetState();
}

class _SpendingTrendChartWidgetState extends State<SpendingTrendChartWidget> {
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  int? _touchedIndex;
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  @override
  void didUpdateWidget(SpendingTrendChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loadChartData();
    }
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;
    List<Map<String, dynamic>> data = [];

    if (widget.period == 'Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      final dailySpending = await _expenseDataService.getDailySpending(
        startDate: startDate,
        endDate: endDate,
      );

      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        data.add({
          "label": weekdays[i],
          "value": dailySpending[dateKey] ?? 0.0,
        });
      }
    } else if (widget.period == 'Month') {
      startDate = DateTime(now.year, now.month, 1);
      final dailySpending = await _expenseDataService.getDailySpending(
        startDate: startDate,
        endDate: endDate,
      );

      for (int week = 0; week < 4; week++) {
        final weekStart = startDate.add(Duration(days: week * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        double weekTotal = 0.0;

        for (int day = 0; day < 7; day++) {
          final date = weekStart.add(Duration(days: day));
          if (date.isAfter(endDate)) break;
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          weekTotal += dailySpending[dateKey] ?? 0.0;
        }

        data.add({"label": "Week ${week + 1}", "value": weekTotal});
      }
    } else {
      startDate = DateTime(now.year, 1, 1);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      for (int month = 1; month <= 12; month++) {
        final monthStart = DateTime(now.year, month, 1);
        final monthEnd = DateTime(now.year, month + 1, 0);
        final monthTotal = await _expenseDataService.getTotalSpending(
          startDate: monthStart,
          endDate: monthEnd,
        );

        data.add({"label": months[month - 1], "value": monthTotal});
      }
    }

    setState(() {
      _chartData = data;
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

    final maxValue = _chartData.isEmpty
        ? 100.0
        : (_chartData
                  .map((e) => e["value"] as double)
                  .reduce((a, b) => a > b ? a : b) *
              1.2);
    final hasData = _chartData.any((e) => (e["value"] as double) > 0);

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
                'Spending Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.period,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (!hasData)
            SizedBox(
              height: 25.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No spending data yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Add expenses to see trends',
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
              height: 25.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
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
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _chartData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _chartData[value.toInt()]["label"],
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
                        interval: maxValue / 5,
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
                  minX: 0,
                  maxX: (_chartData.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxValue,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                          if (touchResponse != null &&
                              touchResponse.lineBarSpots != null) {
                            setState(() {
                              _touchedIndex =
                                  touchResponse.lineBarSpots!.first.spotIndex;
                            });
                          } else {
                            setState(() {
                              _touchedIndex = null;
                            });
                          }
                        },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.primary,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '\${barSpot.y.toStringAsFixed(0)}',
                            theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _chartData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _chartData[index]["value"] as double,
                        ),
                      ),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: _touchedIndex == index ? 6 : 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
