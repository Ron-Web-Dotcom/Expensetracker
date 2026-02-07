import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/analytics_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class UserJourneyWidget extends StatefulWidget {
  const UserJourneyWidget({super.key});

  @override
  State<UserJourneyWidget> createState() => _UserJourneyWidgetState();
}

class _UserJourneyWidgetState extends State<UserJourneyWidget> {
  final AnalyticsService _analytics = AnalyticsService();
  List<Map<String, dynamic>> _journeySteps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJourneyData();
  }

  Future<void> _loadJourneyData() async {
    setState(() => _isLoading = true);

    final summary = await _analytics.getAnalyticsSummary();
    final features = summary['most_used_features'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> steps = [
      {
        'screen': 'Dashboard',
        'timeSpent': '2m 30s',
        'conversionRate': '95%',
        'icon': 'dashboard',
      },
      {
        'screen': 'Add Expense',
        'timeSpent': '1m 15s',
        'conversionRate': '85%',
        'icon': 'add_circle',
      },
      {
        'screen': 'Analytics',
        'timeSpent': '3m 45s',
        'conversionRate': '70%',
        'icon': 'analytics',
      },
    ];

    setState(() {
      _journeySteps = steps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return SizedBox(
        height: 20.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
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
              children: [
                CustomIconWidget(
                  iconName: 'route',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'User Journey Flow',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ..._journeySteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == _journeySteps.length - 1;

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: step['icon'],
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['screen'],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Text(
                                  'Time: ${step['timeSpent']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Conversion: ${step['conversionRate']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.successLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 5.w,
                        top: 1.h,
                        bottom: 1.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 2,
                            height: 3.h,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
