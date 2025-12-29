import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/monthly_spending_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_transactions_widget.dart';

/// Expense Dashboard - Primary hub for financial overview
/// Implements bottom tab navigation with Dashboard tab active
class ExpenseDashboard extends StatefulWidget {
  const ExpenseDashboard({super.key});

  @override
  State<ExpenseDashboard> createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  String _userName = 'User';

  // Mock data for dashboard - starts empty
  final Map<String, dynamic> _dashboardData = {
    "userName": "User",
    "currentDate": "December 28, 2025",
    "monthlySpending": 0.0,
    "monthlyBudget": 3500.00,
    "spendingPercentage": 0.0,
    "recentTransactions": [],
  };

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('expense_dashboard');
    _analytics.trackSessionStart();
    _loadUserName();
    _checkWeeklySummary();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    setState(() {
      _userName = name;
      _dashboardData['userName'] = name;
    });
  }

  Future<void> _checkWeeklySummary() async {
    final weeklySummaryEnabled = await _settingsService
        .isWeeklySummaryEnabled();
    if (!weeklySummaryEnabled) return;

    // Mock weekly data - in a real app, this would come from a database
    final totalSpent = _dashboardData['monthlySpending'] as double;
    final transactionCount =
        (_dashboardData['recentTransactions'] as List).length;

    await _notificationService.scheduleWeeklySummary(
      totalSpent: totalSpent,
      transactionCount: transactionCount,
      topCategory: 'Food & Dining',
    );
  }

  @override
  void dispose() {
    _analytics.trackSessionEnd();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    // Simulate data sync
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isRefreshing = false);
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard updated',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleBalanceVisibility() {
    HapticFeedback.selectionClick();
    setState(() => _isBalanceVisible = !_isBalanceVisible);
  }

  void _navigateToAddExpense() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-expense');
  }

  void _navigateToTransactionHistory() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/transaction-history');
  }

  void _navigateToBudgetManagement() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/budget-management');
  }

  void _navigateToAnalytics() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/analytics-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBarFactory.standard(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isBalanceVisible ? 'visibility' : 'visibility_off',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _toggleBalanceVisibility,
            tooltip: _isBalanceVisible ? 'Hide Balance' : 'Show Balance',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header
                  GreetingHeaderWidget(
                    userName: _dashboardData["userName"] as String,
                    currentDate: _dashboardData["currentDate"] as String,
                  ),

                  SizedBox(height: 2.h),

                  // Monthly Spending Card
                  MonthlySpendingCardWidget(
                    monthlySpending:
                        _dashboardData["monthlySpending"] as double,
                    monthlyBudget: _dashboardData["monthlyBudget"] as double,
                    spendingPercentage:
                        _dashboardData["spendingPercentage"] as double,
                    isBalanceVisible: _isBalanceVisible,
                  ),

                  SizedBox(height: 3.h),

                  // Recent Transactions
                  RecentTransactionsWidget(
                    transactions: (_dashboardData["recentTransactions"] as List)
                        .map((t) => t as Map<String, dynamic>)
                        .toList(),
                    onViewAll: _navigateToTransactionHistory,
                  ),

                  SizedBox(height: 3.h),

                  // Quick Actions
                  QuickActionsWidget(
                    onAddExpense: _navigateToAddExpense,
                    onAddIncome: _navigateToAddExpense,
                    onViewBudget: _navigateToBudgetManagement,
                    onGenerateReport: _navigateToAnalytics,
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        tooltip: 'Add Expense',
        child: CustomIconWidget(
          iconName: 'camera_alt',
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          HapticFeedback.selectionClick();
          // Bottom bar navigation handled by CustomBottomBar
        },
      ),
    );
  }
}
