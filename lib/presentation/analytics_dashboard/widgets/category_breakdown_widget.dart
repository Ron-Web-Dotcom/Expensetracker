import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';
import '../../../services/expense_data_service.dart';

class CategoryBreakdownWidget extends StatefulWidget {
  final String period;

  const CategoryBreakdownWidget({super.key, required this.period});

  @override
  State<CategoryBreakdownWidget> createState() =>
      _CategoryBreakdownWidgetState();
}

class _CategoryBreakdownWidgetState extends State<CategoryBreakdownWidget> {
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  int _touchedIndex = -1;
  List<Map<String, dynamic>> _categoryData = [];
  bool _isLoading = true;

  final Map<String, Color> _categoryColors = {
    "Food & Dining": Color(0xFF4CAF50),
    "Transportation": Color(0xFF2196F3),
    "Shopping": Color(0xFFFF9800),
    "Bills & Utilities": Color(0xFFF44336),
    "Entertainment": Color(0xFF9C27B0),
    "Healthcare": Color(0xFF00BCD4),
    "Education": Color(0xFF3F51B5),
    "Personal Care": Color(0xFFE91E63),
    "Travel": Color(0xFF009688),
    "Others": Color(0xFF607D8B),
  };

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  @override
  void didUpdateWidget(CategoryBreakdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loadCategoryData();
    }
  }

  Future<void> _loadCategoryData() async {
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

    final categorySpending = await _expenseDataService.getSpendingByCategory(
      startDate: startDate,
      endDate: endDate,
    );

    final List<Map<String, dynamic>> data = [];
    categorySpending.forEach((category, amount) {
      data.add({
        "name": category,
        "value": amount,
        "color": _categoryColors[category] ?? Color(0xFF607D8B),
      });
    });

    data.sort((a, b) => (b["value"] as double).compareTo(a["value"] as double));

    setState(() {
      _categoryData = data;
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

    final total = _categoryData.fold<double>(
      0,
      (sum, item) => sum + (item["value"] as double),
    );

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
                'Category Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_categoryData.isEmpty)
            SizedBox(
              height: 20.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No category data yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Add expenses to see breakdown',
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
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: List.generate(_categoryData.length, (index) {
                          final isTouched = index == _touchedIndex;
                          final radius = isTouched ? 55.0 : 50.0;
                          final category = _categoryData[index];
                          final percentage =
                              ((category["value"] as double) / total * 100);

                          return PieChartSectionData(
                            color: category["color"] as Color,
                            value: category["value"] as double,
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: radius,
                            titleStyle: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _categoryData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final percentage =
                              ((category["value"] as double) / total * 100);

                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 3.w,
                                  height: 3.w,
                                  decoration: BoxDecoration(
                                    color: category["color"] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category["name"],
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '\$${(category["value"] as double).toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
