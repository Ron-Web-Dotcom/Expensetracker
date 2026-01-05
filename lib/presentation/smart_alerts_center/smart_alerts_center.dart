import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/alert_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/alert_summary_widget.dart';
import './widgets/alert_category_widget.dart';
import './widgets/alert_history_widget.dart';
import './widgets/smart_scheduling_widget.dart';

class SmartAlertsCenter extends StatefulWidget {
  const SmartAlertsCenter({super.key});

  @override
  State<SmartAlertsCenter> createState() => _SmartAlertsCenterState();
}

class _SmartAlertsCenterState extends State<SmartAlertsCenter> {
  final AlertService _alertService = AlertService();
  final AnalyticsService _analytics = AnalyticsService();

  Map<String, dynamic> _alertSettings = {};
  Map<String, dynamic> _alertStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('smart_alerts_center');
    _loadAlertData();
  }

  Future<void> _loadAlertData() async {
    setState(() => _isLoading = true);

    final settings = await _alertService.getAlertSettings();
    final stats = await _alertService.getAlertStatistics();

    setState(() {
      _alertSettings = settings;
      _alertStats = stats;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    await _alertService.updateAlertSetting(key, value);
    setState(() {
      _alertSettings[key] = value;
    });

    _analytics.trackEvent(
      'alert_setting_changed',
      parameters: {'setting': key, 'value': value.toString()},
    );
  }

  Future<void> _testAlert() async {
    await _alertService.checkBudgetLimits();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test alert sent! Check your notifications.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
        title: 'Smart Alerts Center',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _testAlert,
            tooltip: 'Test Alert',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlertData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Alert Summary Dashboard
                    AlertSummaryWidget(
                      activeAlerts: _alertStats['unreadAlerts'] ?? 0,
                      totalAlerts: _alertStats['totalAlerts'] ?? 0,
                      lastAlertTime: _alertStats['lastAlertTime'],
                    ),

                    SizedBox(height: 3.h),

                    // Budget Limits Section
                    AlertCategoryWidget(
                      title: 'Budget Limits',
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF4CAF50),
                      alerts: [
                        {
                          'title': '50% Threshold Warning',
                          'subtitle': 'Alert when reaching 50% of budget',
                          'key': 'budgetLimit50Enabled',
                          'value':
                              _alertSettings['budgetLimit50Enabled'] ?? true,
                        },
                        {
                          'title': '75% Threshold Warning',
                          'subtitle': 'Alert when reaching 75% of budget',
                          'key': 'budgetLimit75Enabled',
                          'value':
                              _alertSettings['budgetLimit75Enabled'] ?? true,
                        },
                        {
                          'title': '90% Threshold Warning',
                          'subtitle': 'Alert when reaching 90% of budget',
                          'key': 'budgetLimit90Enabled',
                          'value':
                              _alertSettings['budgetLimit90Enabled'] ?? true,
                        },
                      ],
                      onToggle: _updateSetting,
                    ),

                    SizedBox(height: 2.h),

                    // Unusual Spending Section
                    AlertCategoryWidget(
                      title: 'Unusual Spending',
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFFFF9800),
                      alerts: [
                        {
                          'title': 'AI-Detected Anomalies',
                          'subtitle': 'Alert for unusual spending patterns',
                          'key': 'unusualSpendingEnabled',
                          'value':
                              _alertSettings['unusualSpendingEnabled'] ?? true,
                        },
                        {
                          'title': 'Large Transactions',
                          'subtitle':
                              'Alert for transactions over \$${(_alertSettings['largeTransactionThreshold'] ?? 500).toStringAsFixed(0)}',
                          'key': 'largeTransactionEnabled',
                          'value':
                              _alertSettings['largeTransactionEnabled'] ?? true,
                        },
                        {
                          'title': 'Frequency Spikes',
                          'subtitle':
                              'Alert when transaction frequency increases',
                          'key': 'frequencySpikeEnabled',
                          'value':
                              _alertSettings['frequencySpikeEnabled'] ?? true,
                        },
                      ],
                      onToggle: _updateSetting,
                    ),

                    SizedBox(height: 2.h),

                    // Milestone Alerts Section
                    AlertCategoryWidget(
                      title: 'Milestone Alerts',
                      icon: Icons.emoji_events,
                      iconColor: const Color(0xFF2196F3),
                      alerts: [
                        {
                          'title': 'Monthly Goals',
                          'subtitle':
                              'Alert when reaching monthly spending goals',
                          'key': 'monthlyGoalEnabled',
                          'value': _alertSettings['monthlyGoalEnabled'] ?? true,
                        },
                        {
                          'title': 'Savings Targets',
                          'subtitle': 'Alert when hitting savings milestones',
                          'key': 'savingsTargetEnabled',
                          'value':
                              _alertSettings['savingsTargetEnabled'] ?? true,
                        },
                        {
                          'title': 'Spending Streaks',
                          'subtitle': 'Alert for consecutive days under budget',
                          'key': 'spendingStreakEnabled',
                          'value':
                              _alertSettings['spendingStreakEnabled'] ?? true,
                        },
                      ],
                      onToggle: _updateSetting,
                    ),

                    SizedBox(height: 2.h),

                    // Overspending Warnings Section
                    AlertCategoryWidget(
                      title: 'Overspending Warnings',
                      icon: Icons.warning,
                      iconColor: const Color(0xFFF44336),
                      alerts: [
                        {
                          'title': 'Budget Exceeded',
                          'subtitle': 'Critical alert when budget is exceeded',
                          'key': 'budgetExceededEnabled',
                          'value':
                              _alertSettings['budgetExceededEnabled'] ?? true,
                        },
                        {
                          'title': 'Category Limit Breached',
                          'subtitle': 'Alert when category budget is exceeded',
                          'key': 'categoryLimitBreachedEnabled',
                          'value':
                              _alertSettings['categoryLimitBreachedEnabled'] ??
                              true,
                        },
                      ],
                      onToggle: _updateSetting,
                    ),

                    SizedBox(height: 2.h),

                    // Smart Scheduling
                    SmartSchedulingWidget(
                      settings: _alertSettings,
                      onUpdate: _updateSetting,
                    ),

                    SizedBox(height: 2.h),

                    // Alert History
                    AlertHistoryWidget(onRefresh: _loadAlertData),

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
    );
  }
}
