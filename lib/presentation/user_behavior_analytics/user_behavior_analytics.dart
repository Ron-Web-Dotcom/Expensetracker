import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/expense_data_service.dart';
import '../../services/expense_notifier.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/user_journey_widget.dart';
import './widgets/heatmap_visualization_widget.dart';
import './widgets/feature_adoption_timeline_widget.dart';
import './widgets/session_analysis_widget.dart';
import './widgets/cohort_analysis_widget.dart';

class UserBehaviorAnalytics extends StatefulWidget {
  const UserBehaviorAnalytics({super.key});

  @override
  State<UserBehaviorAnalytics> createState() => _UserBehaviorAnalyticsState();
}

class _UserBehaviorAnalyticsState extends State<UserBehaviorAnalytics>
    with SingleTickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();

  late TabController _tabController;
  Map<String, dynamic> _behaviorData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _analytics.trackScreenView('user_behavior_analytics');
    _loadBehaviorData();
    _expenseNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _loadBehaviorData();
  }

  Future<void> _loadBehaviorData() async {
    setState(() => _isLoading = true);

    final analyticsSummary = await _analytics.getAnalyticsSummary();
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final expenses = await _expenseDataService.getExpensesByDateRange(
      startDate: thisMonthStart,
      endDate: now,
    );

    setState(() {
      _behaviorData = {
        'totalSessions': analyticsSummary['total_sessions'] ?? 0,
        'avgSessionDuration': 0,
        'mostUsedFeatures': analyticsSummary['most_used_features'] ?? [],
        'transactionCount': expenses.length,
        'aiAccuracy': analyticsSummary['ai_accuracy'] ?? 0.0,
      };
      _isLoading = false;
    });
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
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text(
                    'Export User Behavior Report',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ListTile(
                    leading: Icon(
                      Icons.picture_as_pdf,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Export as PDF'),
                    onTap: () {
                      Navigator.pop(context);
                      _exportReport('PDF');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.table_chart,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Export as Excel'),
                    onTap: () {
                      Navigator.pop(context);
                      _exportReport('Excel');
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

  Future<void> _exportReport(String format) async {
    await _analytics.trackEvent(
      'behavior_export',
      parameters: {'format': format},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting user behavior report as $format...'),
        duration: const Duration(seconds: 2),
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
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Behavior Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showExportMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Individual Analysis'),
            Tab(text: 'Aggregate Patterns'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildIndividualAnalysisTab(), _buildAggregateTab()],
            ),
    );
  }

  Widget _buildIndividualAnalysisTab() {
    return RefreshIndicator(
      onRefresh: _loadBehaviorData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            UserJourneyWidget(),
            SizedBox(height: 3.h),
            HeatmapVisualizationWidget(),
            SizedBox(height: 3.h),
            FeatureAdoptionTimelineWidget(),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregateTab() {
    return RefreshIndicator(
      onRefresh: _loadBehaviorData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            SessionAnalysisWidget(
              totalSessions: _behaviorData['totalSessions'],
              avgDuration: _behaviorData['avgSessionDuration'],
            ),
            SizedBox(height: 3.h),
            CohortAnalysisWidget(),
            SizedBox(height: 3.h),
            _buildPrivacyNotice(),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.privacy_tip, color: theme.colorScheme.primary, size: 24),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Compliant',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'All data is anonymized and GDPR compliant. No personal information is tracked.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
