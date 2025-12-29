import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/budget_overview_card.dart';
import './widgets/budget_period_selector.dart';
import './widgets/category_budget_item.dart';
import './widgets/historical_comparison_card.dart';

class BudgetManagement extends StatefulWidget {
  const BudgetManagement({super.key});

  @override
  State<BudgetManagement> createState() => _BudgetManagementState();
}

class _BudgetManagementState extends State<BudgetManagement> {
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();
  String _selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('budget_management');
    _calculateBudgetValues();
    _checkBudgetAlerts();
    _checkAchievements();
  }

  int _currentBottomNavIndex = 2;
  DateTime _currentMonth = DateTime.now();
  bool _alertsEnabled = true;

  // Mock data for budget overview
  final double _totalBudget = 3000.0;
  final double _spentAmount = 2150.0;
  late double _remainingAmount;
  late double _spendingPercentage;

  // Mock data for category budgets
  final List<Map<String, dynamic>> _categoryBudgets = [
    {
      "categoryName": "Food & Dining",
      "icon": Icons.restaurant,
      "color": const Color(0xFFFF6B6B),
      "budgetLimit": 600.0,
      "spentAmount": 485.0,
    },
    {
      "categoryName": "Transportation",
      "icon": Icons.directions_car,
      "color": const Color(0xFF4ECDC4),
      "budgetLimit": 400.0,
      "spentAmount": 320.0,
    },
    {
      "categoryName": "Shopping",
      "icon": Icons.shopping_bag,
      "color": const Color(0xFFFFBE0B),
      "budgetLimit": 500.0,
      "spentAmount": 450.0,
    },
    {
      "categoryName": "Housing",
      "icon": Icons.home,
      "color": const Color(0xFF95E1D3),
      "budgetLimit": 800.0,
      "spentAmount": 800.0,
    },
    {
      "categoryName": "Entertainment",
      "icon": Icons.movie,
      "color": const Color(0xFFAA96DA),
      "budgetLimit": 300.0,
      "spentAmount": 95.0,
    },
    {
      "categoryName": "Healthcare",
      "icon": Icons.medical_services,
      "color": const Color(0xFFFF8FAB),
      "budgetLimit": 200.0,
      "spentAmount": 0.0,
    },
  ];

  // Mock data for historical comparison
  final double _previousPeriodSpent = 1980.0;

  void _calculateBudgetValues() {
    _remainingAmount = _totalBudget - _spentAmount;
    _spendingPercentage = (_spentAmount / _totalBudget * 100).clamp(0, 100);
  }

  Future<void> _checkBudgetAlerts() async {
    final budgetAlertsEnabled = await _settingsService.isBudgetAlertsEnabled();
    if (!budgetAlertsEnabled) return;

    // Check overall budget
    await _notificationService.checkAndSendBudgetAlert(
      spent: _spentAmount,
      budget: _totalBudget,
      categoryName: 'Total Budget',
    );

    // Check each category budget
    for (final category in _categoryBudgets) {
      final spent = category['spentAmount'] as double;
      final budget = category['budgetLimit'] as double;
      final categoryName = category['categoryName'] as String;

      await _notificationService.checkAndSendBudgetAlert(
        spent: spent,
        budget: budget,
        categoryName: categoryName,
      );
    }
  }

  Future<void> _checkAchievements() async {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    await _notificationService.checkAchievements(
      totalSpent: _spentAmount,
      budget: _totalBudget,
      daysInMonth: now.day,
    );
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    HapticFeedback.lightImpact();
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    HapticFeedback.lightImpact();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });

    if (period == 'Custom') {
      _showCustomPeriodPicker();
    }
  }

  void _showCustomPeriodPicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _showEditBudgetDialog(String categoryName, double currentLimit) {
    final TextEditingController controller = TextEditingController(
      text: currentLimit.toStringAsFixed(0),
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Edit Budget Limit', style: theme.textTheme.titleLarge),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Budget Limit *',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget limit';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount greater than 0';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Budget limit updated to \$${controller.text}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController limitController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Add Category Budget', style: theme.textTheme.titleLarge),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Budget Limit *',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget limit';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text} budget created'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertSettingsDialog() {
    bool alert75 = true;
    bool alert90 = true;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Alert Settings', style: theme.textTheme.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Alert at 75% spent'),
                    value: alert75,
                    onChanged: (value) {
                      setDialogState(() => alert75 = value);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Alert at 90% spent'),
                    value: alert90,
                    onChanged: (value) {
                      setDialogState(() => alert90 = value);
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert settings updated'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getMonthYearString() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBarFactory.standard(
        title: 'Budget Management',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _alertsEnabled
                  ? 'notifications_active'
                  : 'notifications_off',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              setState(() => _alertsEnabled = !_alertsEnabled);
              HapticFeedback.lightImpact();
              _showAlertSettingsDialog();
            },
            tooltip: 'Alert Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Navigation Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'chevron_left',
                        color: theme.colorScheme.onSurface,
                        size: 28,
                      ),
                      onPressed: _navigateToPreviousMonth,
                      tooltip: 'Previous Month',
                    ),
                    Flexible(
                      child: Text(
                        _getMonthYearString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: theme.colorScheme.onSurface,
                        size: 28,
                      ),
                      onPressed: _navigateToNextMonth,
                      tooltip: 'Next Month',
                    ),
                  ],
                ),
              ),

              // Budget Period Selector
              BudgetPeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
              ),

              // Budget Overview Card
              BudgetOverviewCard(
                totalBudget: _totalBudget,
                spentAmount: _spentAmount,
                remainingAmount: _remainingAmount,
                spendingPercentage: _spendingPercentage,
              ),

              // Historical Comparison
              HistoricalComparisonCard(
                previousPeriodSpent: _previousPeriodSpent,
                currentPeriodSpent: _spentAmount,
                periodLabel: 'Last Month',
              ),

              // Category Budgets Section Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Category Budgets',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showAddCategoryDialog,
                      icon: CustomIconWidget(
                        iconName: 'add',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),

              // Category Budget List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categoryBudgets.length,
                itemBuilder: (context, index) {
                  final category = _categoryBudgets[index];
                  return CategoryBudgetItem(
                    categoryName: category["categoryName"] as String,
                    categoryIcon: category["icon"] as IconData,
                    categoryColor: category["color"] as Color,
                    budgetLimit: category["budgetLimit"] as double,
                    spentAmount: category["spentAmount"] as double,
                    onTap: () => _showEditBudgetDialog(
                      category["categoryName"],
                      category["budgetLimit"],
                    ),
                    onAdjustLimit: () => _showEditBudgetDialog(
                      category["categoryName"],
                      category["budgetLimit"],
                    ),
                    onViewTransactions: () {
                      Navigator.pushNamed(context, '/transaction-history');
                    },
                    onSetAlert: () => _showAlertSettingsDialog(),
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Smart Suggestions Card
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Smart Suggestion',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Based on your spending patterns, consider increasing your Food & Dining budget by \$100 next month.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
      ),
    );
  }
}
