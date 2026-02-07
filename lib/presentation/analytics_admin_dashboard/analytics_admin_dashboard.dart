import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/data_export_service.dart';
import '../../services/expense_data_service.dart';
import '../../services/expense_notifier.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/behavior_tracking_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/kpi_card_widget.dart';
import './widgets/performance_metrics_widget.dart';

class AnalyticsAdminDashboard extends StatefulWidget {
  const AnalyticsAdminDashboard({super.key});

  @override
  State<AnalyticsAdminDashboard> createState() =>
      _AnalyticsAdminDashboardState();
}

class _AnalyticsAdminDashboardState extends State<AnalyticsAdminDashboard> {
  final AnalyticsService _analytics = AnalyticsService();
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();
  final DataExportService _exportService = DataExportService();

  String _selectedPeriod = 'This Month';
  Map<String, dynamic> _kpiData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('analytics_admin_dashboard');
    _loadKPIData();
    _expenseNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _expenseNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _loadKPIData();
  }

  Future<void> _loadKPIData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (_selectedPeriod == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedPeriod == 'This Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (_selectedPeriod == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, 1, 1);
    }

    final analyticsSummary = await _analytics.getAnalyticsSummary();
    final totalSpending = await _expenseDataService.getTotalSpending(
      startDate: startDate,
      endDate: endDate,
    );
    final expenses = await _expenseDataService.getExpensesByDateRange(
      startDate: startDate,
      endDate: endDate,
    );

    final dailyActiveUsers = expenses.isEmpty ? 0 : 1;
    final featureAdoption = analyticsSummary['most_used_features']?.length ?? 0;
    final crashReports = 0;
    final revenue = totalSpending;

    setState(() {
      _kpiData = {
        'dailyActiveUsers': dailyActiveUsers,
        'featureAdoption': featureAdoption,
        'crashReports': crashReports,
        'revenue': revenue,
        'userEngagement': analyticsSummary['total_sessions'] ?? 0,
        'avgSessionDuration': 0,
        'errorRate': 0.0,
      };
      _isLoading = false;
    });
  }

  void _showPeriodSelector() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text(
                    'Select Period',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ...[('Today'), ('This Week'), ('This Month'), ('This Year')]
                      .map(
                        (period) => ListTile(
                          title: Text(period),
                          trailing: _selectedPeriod == period
                              ? Icon(
                                  Icons.check,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedPeriod = period);
                            _loadKPIData();
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportOptionsWidget(
        onExport: (format, dateRange) async {
          await _analytics.trackEvent(
            'admin_export',
            parameters: {'format': format, 'date_range': dateRange},
          );
          Navigator.pop(context);

          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Generating $format report...'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );

            String filePath;
            if (format == 'PDF') {
              filePath = await _exportService.exportAsPDF();
            } else {
              filePath = await _exportService.exportAsCSV();
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$format exported successfully to: $filePath'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Export failed: $e'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5FBF2),
      appBar: CustomAppBarFactory.standard(
        title: 'Analytics Admin',
        centerTitle: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showExportOptions,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadKPIData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Real-Time Metrics',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            InkWell(
                              onTap: _showPeriodSelector,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedPeriod,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 2.h,
                          crossAxisSpacing: 3.w,
                          childAspectRatio: 1.4,
                          children: [
                            KPICardWidget(
                              title: 'Daily Active Users',
                              value: _kpiData['dailyActiveUsers'].toString(),
                              change: '+0%',
                              isPositive: true,
                              icon: 'people',
                            ),
                            KPICardWidget(
                              title: 'Feature Adoption',
                              value: '${_kpiData['featureAdoption']}',
                              change: '+0%',
                              isPositive: true,
                              icon: 'trending_up',
                            ),
                            KPICardWidget(
                              title: 'Crash Reports',
                              value: _kpiData['crashReports'].toString(),
                              change: '0%',
                              isPositive: true,
                              icon: 'bug_report',
                            ),
                            KPICardWidget(
                              title: 'Revenue',
                              value:
                                  '\$${_kpiData['revenue'].toStringAsFixed(0)}',
                              change: '+0%',
                              isPositive: true,
                              icon: 'attach_money',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      PerformanceMetricsWidget(
                        avgLoadTime: 1.2,
                        apiResponseRate: 98.5,
                        errorFrequency: _kpiData['errorRate'],
                      ),
                      SizedBox(height: 3.h),
                      BehaviorTrackingWidget(),
                      SizedBox(height: 3.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.analyticsDashboard,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withValues(
                                    alpha: 0.08,
                                  ),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'analytics',
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'User Behavior Analytics',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Deep dive into user interactions',
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
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
