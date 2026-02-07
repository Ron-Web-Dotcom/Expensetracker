import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/analytics_service.dart';
import '../../services/expense_notifier.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/alert_configuration_widget.dart';
import './widgets/api_monitoring_widget.dart';
import './widgets/app_performance_widget.dart';
import './widgets/database_performance_widget.dart';
import './widgets/system_health_widget.dart';
import './widgets/user_experience_metrics_widget.dart';

class PerformanceMetricsCenter extends StatefulWidget {
  const PerformanceMetricsCenter({super.key});

  @override
  State<PerformanceMetricsCenter> createState() =>
      _PerformanceMetricsCenterState();
}

class _PerformanceMetricsCenterState extends State<PerformanceMetricsCenter>
    with SingleTickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();
  late TabController _tabController;
  int _currentBottomNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _analytics.trackScreenView('performance_metrics_center');
    _expenseNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Performance Metrics',
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () {
              setState(() {});
              _analytics.trackEvent('performance_metrics_refreshed');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              _showSettingsMenu();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(fontSize: 13.sp),
              tabs: const [
                Tab(text: 'App Performance'),
                Tab(text: 'API Monitoring'),
                Tab(text: 'Database'),
                Tab(text: 'User Experience'),
                Tab(text: 'System Health'),
                Tab(text: 'Alerts'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AppPerformanceWidget(),
                ApiMonitoringWidget(),
                DatabasePerformanceWidget(),
                UserExperienceMetricsWidget(),
                SystemHealthWidget(),
                AlertConfigurationWidget(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
          _handleBottomNavigation(index);
        },
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.expenseDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.transactionHistory);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.budgetManagement);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.analyticsDashboard);
        break;
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Alert Preferences',
                    onTap: () {
                      Navigator.pop(context);
                      _tabController.animateTo(5);
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.download_outlined,
                    title: 'Export Performance Report',
                    onTap: () {
                      Navigator.pop(context);
                      _analytics.trackEvent('performance_report_exported');
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.history,
                    title: 'Historical Data',
                    onTap: () {
                      Navigator.pop(context);
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
      onTap: onTap,
    );
  }
}
