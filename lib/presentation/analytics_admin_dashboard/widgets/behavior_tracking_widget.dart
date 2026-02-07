import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/analytics_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class BehaviorTrackingWidget extends StatefulWidget {
  const BehaviorTrackingWidget({super.key});

  @override
  State<BehaviorTrackingWidget> createState() => _BehaviorTrackingWidgetState();
}

class _BehaviorTrackingWidgetState extends State<BehaviorTrackingWidget> {
  final AnalyticsService _analytics = AnalyticsService();
  List<Map<String, dynamic>> _mostUsedFeatures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBehaviorData();
  }

  Future<void> _loadBehaviorData() async {
    setState(() => _isLoading = true);

    final summary = await _analytics.getAnalyticsSummary();
    final features = summary['most_used_features'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> featureList = [];
    for (var feature in features.take(5)) {
      featureList.add({
        'name': feature['feature'],
        'count': feature['count'],
        'icon': _getFeatureIcon(feature['feature']),
      });
    }

    if (featureList.isEmpty) {
      featureList.addAll([
        {'name': 'Add Expense', 'count': 0, 'icon': 'add_circle'},
        {'name': 'View Analytics', 'count': 0, 'icon': 'analytics'},
        {
          'name': 'Budget Management',
          'count': 0,
          'icon': 'account_balance_wallet',
        },
      ]);
    }

    setState(() {
      _mostUsedFeatures = featureList;
      _isLoading = false;
    });
  }

  String _getFeatureIcon(String featureName) {
    final iconMap = {
      'add_expense': 'add_circle',
      'view_analytics': 'analytics',
      'budget_management': 'account_balance_wallet',
      'transaction_history': 'receipt_long',
      'receipt_camera': 'camera_alt',
    };
    return iconMap[featureName] ?? 'star';
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
                  iconName: 'insights',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Most Used Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ..._mostUsedFeatures.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: Row(
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
                        iconName: feature['icon'],
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        feature['name'],
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${feature['count']} uses',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
