import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/analytics_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FeatureAdoptionTimelineWidget extends StatefulWidget {
  const FeatureAdoptionTimelineWidget({super.key});

  @override
  State<FeatureAdoptionTimelineWidget> createState() =>
      _FeatureAdoptionTimelineWidgetState();
}

class _FeatureAdoptionTimelineWidgetState
    extends State<FeatureAdoptionTimelineWidget> {
  final AnalyticsService _analytics = AnalyticsService();
  List<Map<String, dynamic>> _adoptionData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdoptionData();
  }

  Future<void> _loadAdoptionData() async {
    setState(() => _isLoading = true);

    final List<Map<String, dynamic>> data = [
      {
        'feature': 'Expense Tracking',
        'adoptionDate': 'Day 1',
        'successRate': '95%',
        'status': 'adopted',
      },
      {
        'feature': 'Budget Management',
        'adoptionDate': 'Day 3',
        'successRate': '80%',
        'status': 'adopted',
      },
      {
        'feature': 'Analytics Dashboard',
        'adoptionDate': 'Day 7',
        'successRate': '65%',
        'status': 'exploring',
      },
      {
        'feature': 'Receipt Scanner',
        'adoptionDate': 'Not yet',
        'successRate': '0%',
        'status': 'not_adopted',
      },
    ];

    setState(() {
      _adoptionData = data;
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
                  iconName: 'timeline',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Feature Adoption Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ..._adoptionData.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(feature['status'], theme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['feature'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Text(
                                'Adopted: ${feature['adoptionDate']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Success: ${feature['successRate']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(
                                    feature['status'],
                                    theme,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(feature['status'], theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'adopted':
        return AppTheme.successLight;
      case 'exploring':
        return AppTheme.warningLight;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    String label;
    Color color;

    switch (status) {
      case 'adopted':
        label = 'Adopted';
        color = AppTheme.successLight;
        break;
      case 'exploring':
        label = 'Exploring';
        color = AppTheme.warningLight;
        break;
      default:
        label = 'Not Yet';
        color = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
