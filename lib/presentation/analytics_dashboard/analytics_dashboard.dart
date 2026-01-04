import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/expense_notifier.dart';
import '../../services/data_export_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_breakdown_widget.dart';
import './widgets/monthly_comparison_widget.dart';
import './widgets/period_selector_widget.dart';
import './widgets/smart_insights_widget.dart';
import './widgets/spending_patterns_widget.dart';
import './widgets/spending_trend_chart_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final AnalyticsService _analytics = AnalyticsService();
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();
  final DataExportService _exportService = DataExportService();
  String _selectedPeriod = 'This Month';
  Map<String, dynamic> _analyticsSummary = {};

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('analytics_dashboard');
    _loadAnalyticsSummary();

    // Listen for real-time data changes
    _expenseNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    // Reload analytics when expenses or budgets change
    _loadAnalyticsSummary();
    // Force rebuild of all child widgets
    setState(() {});
  }

  Future<void> _loadAnalyticsSummary() async {
    final summary = await _analytics.getAnalyticsSummary();
    setState(() {
      _analyticsSummary = summary;
    });
  }

  int _currentBottomNavIndex = 3;

  int _currentChartIndex = 0;
  final PageController _chartPageController = PageController();

  @override
  void dispose() {
    _chartPageController.dispose();
    _expenseNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  void _showExportMenu() {
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Report',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'picture_as_pdf',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(
                      'Export as PDF',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      'Detailed report with charts',
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Generating PDF report...'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        final filePath = await _exportService.exportAsPDF();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'PDF exported successfully to: $filePath',
                              ),
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
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'table_chart',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(
                      'Export as CSV',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      'Raw data for analysis',
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Generating CSV file...'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        final filePath = await _exportService.exportAsCSV();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'CSV exported successfully to: $filePath',
                              ),
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
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Date Range',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: CustomIconWidget(
                          iconName: 'calendar_today',
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        label: Text('Start Date'),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: CustomIconWidget(
                          iconName: 'calendar_today',
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        label: Text('End Date'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            'All',
                            'Food',
                            'Transport',
                            'Shopping',
                            'Bills',
                            'Entertainment',
                          ]
                          .map(
                            (category) => FilterChip(
                              label: Text(category),
                              selected: category == 'All',
                              onSelected: (selected) {},
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Methods',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            'All',
                            'Cash',
                            'Credit Card',
                            'Debit Card',
                            'Digital Wallet',
                          ]
                          .map(
                            (method) => FilterChip(
                              label: Text(method),
                              selected: method == 'All',
                              onSelected: (selected) {},
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Analytics',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showExportMenu,
            tooltip: 'Export',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PeriodSelectorWidget(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
              ),
              SizedBox(height: 2.h),
              SizedBox(
                height: 35.h,
                child: PageView(
                  controller: _chartPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentChartIndex = index;
                    });
                  },
                  children: [
                    SpendingTrendChartWidget(period: _selectedPeriod),
                    CategoryBreakdownWidget(period: _selectedPeriod),
                    SpendingPatternsWidget(period: _selectedPeriod),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: _currentChartIndex == index ? 8.w : 2.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: _currentChartIndex == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.3,
                            ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              MonthlyComparisonWidget(period: _selectedPeriod),
              SizedBox(height: 2.h),
              SmartInsightsWidget(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }
}
