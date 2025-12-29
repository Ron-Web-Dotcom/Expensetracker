import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MonthlyComparisonWidget extends StatelessWidget {
  final String period;

  const MonthlyComparisonWidget({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> comparisonData = [
      {
        "title": "This Month",
        "amount": "\$1,990",
        "change": "+12.5%",
        "isPositive": false,
        "subtitle": "vs last month",
      },
      {
        "title": "Average Daily",
        "amount": "\$66.33",
        "change": "-5.2%",
        "isPositive": true,
        "subtitle": "vs last month",
      },
      {
        "title": "Highest Day",
        "amount": "\$220",
        "change": "+18.9%",
        "isPositive": false,
        "subtitle": "Saturday spending",
      },
      {
        "title": "Budget Status",
        "amount": "82%",
        "change": "Used",
        "isPositive": true,
        "subtitle": "\$360 remaining",
      },
    ];

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
            itemCount: comparisonData.length,
            itemBuilder: (context, index) {
              final item = comparisonData[index];
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
                            CustomIconWidget(
                              iconName: item["isPositive"]
                                  ? 'trending_down'
                                  : 'trending_up',
                              color: item["isPositive"]
                                  ? AppTheme.successLight
                                  : AppTheme.errorLight,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              item["change"],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: item["isPositive"]
                                    ? AppTheme.successLight
                                    : AppTheme.errorLight,
                                fontWeight: FontWeight.w600,
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
