import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';

class CategoryBreakdownWidget extends StatefulWidget {
  final String period;

  const CategoryBreakdownWidget({super.key, required this.period});

  @override
  State<CategoryBreakdownWidget> createState() =>
      _CategoryBreakdownWidgetState();
}

class _CategoryBreakdownWidgetState extends State<CategoryBreakdownWidget> {
  int _touchedIndex = -1;

  final List<Map<String, dynamic>> _categoryData = [
    {"name": "Food & Dining", "value": 450.0, "color": Color(0xFF4CAF50)},
    {"name": "Transportation", "value": 280.0, "color": Color(0xFF2196F3)},
    {"name": "Shopping", "value": 320.0, "color": Color(0xFFFF9800)},
    {"name": "Bills & Utilities", "value": 380.0, "color": Color(0xFFF44336)},
    {"name": "Entertainment", "value": 180.0, "color": Color(0xFF9C27B0)},
    {"name": "Others", "value": 140.0, "color": Color(0xFF607D8B)},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          SizedBox(
            height: 20.h,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
