import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../services/expense_data_service.dart';
import '../../services/expense_notifier.dart';
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
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  String _userName = 'User';

  // Mock data for dashboard - starts empty
  final Map<String, dynamic> _dashboardData = {
    "userName": "User",
    "monthlySpending": 0.0,
    "monthlyBudget": 0.0,
    "spendingPercentage": 0.0,
    "recentTransactions": [],
  };

  // Category icon mapping
  final Map<String, String> _categoryIcons = {
    'Food & Dining': 'restaurant',
    'Transportation': 'directions_car',
    'Shopping': 'shopping_bag',
    'Entertainment': 'movie',
    'Bills & Utilities': 'receipt_long',
    'Healthcare': 'local_hospital',
    'Education': 'school',
    'Travel': 'flight',
    'Groceries': 'shopping_cart',
    'Personal Care': 'face',
    'Gifts & Donations': 'card_giftcard',
    'Other': 'more_horiz',
  };

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('expense_dashboard');
    _analytics.trackSessionStart();
    _loadUserName();
    _loadDashboardData();
    _checkWeeklySummary();

    // Listen for real-time data changes
    _expenseNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    // Reload dashboard data when expenses or budgets change
    if (mounted) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthlySpending = await _expenseDataService.getTotalSpending(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final recentExpenses = await _expenseDataService.getExpensesByDateRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    // Sort by date descending and take top 5
    recentExpenses.sort(
      (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
    );
    final recentTransactions = recentExpenses.take(5).map((expense) {
      final expenseDate = DateTime.parse(expense['date']);
      final category = expense['category'] as String;
      final amount = (expense['amount'] as num).toDouble();
      return {
        'id': expense['id'],
        'description': expense['description'] ?? 'Expense',
        'amount': amount,
        'category': category,
        'categoryIcon': _categoryIcons[category] ?? 'more_horiz',
        'date': expense['date'],
        'time': DateFormat('h:mm a').format(expenseDate),
        'paymentMethod': expense['paymentMethod'],
        'hasReceipt': (expense['receiptPhotos'] as List).isNotEmpty,
        'receiptPhotos': expense['receiptPhotos'],
        'hasLocation': expense['hasLocation'] ?? false,
        'transactionType':
            expense['transactionType'] ?? (amount > 0 ? 'income' : 'expense'),
      };
    }).toList();

    if (mounted) {
      setState(() {
        _dashboardData['monthlySpending'] = monthlySpending;
        _dashboardData['recentTransactions'] = recentTransactions;
        _dashboardData['spendingPercentage'] =
            _dashboardData['monthlyBudget'] > 0
            ? (monthlySpending / _dashboardData['monthlyBudget']) * 100
            : 0.0;
      });
    }
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

    // Get real weekly data from service
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final totalSpent = await _expenseDataService.getTotalSpending(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    final allExpenses = await _expenseDataService.getExpensesByDateRange(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
    final transactionCount = allExpenses.length;

    // Get top category from real data
    final categorySpending = await _expenseDataService.getSpendingByCategory(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    String topCategory = 'General';
    if (categorySpending.isNotEmpty) {
      topCategory = categorySpending.entries
          .reduce((a, b) => a.value.abs() > b.value.abs() ? a : b)
          .key;
    }

    await _notificationService.scheduleWeeklySummary(
      totalSpent: totalSpent,
      transactionCount: transactionCount,
      topCategory: topCategory,
    );
  }

  @override
  void dispose() {
    _analytics.trackSessionEnd();
    _scrollController.dispose();
    _expenseNotifier.removeListener(_onDataChanged);
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
    Navigator.pushNamed(
      context,
      '/add-expense',
      arguments: {'transactionType': 'expense'},
    );
  }

  void _navigateToAddIncome() {
    Navigator.pushNamed(
      context,
      '/add-expense',
      arguments: {'transactionType': 'income'},
    );
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
                    onAddIncome: _navigateToAddIncome,
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
