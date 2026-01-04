import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../services/budget_data_service.dart';
import '../../services/expense_notifier.dart';
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
  final BudgetDataService _budgetService = BudgetDataService();
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();
  String _selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('budget_management');
    _loadBudgetData();

    // Listen for real-time data changes
    _expenseNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    // Reload budget data when expenses or budgets change
    _loadBudgetData();
  }

  @override
  void dispose() {
    _expenseNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  int _currentBottomNavIndex = 2;
  DateTime _currentMonth = DateTime.now();
  bool _alertsEnabled = true;
  bool _isLoading = true;

  // Budget data
  double _totalBudget = 0.0;
  double _spentAmount = 0.0;
  double _remainingAmount = 0.0;
  double _spendingPercentage = 0.0;
  List<Map<String, dynamic>> _categoryBudgets = [];
  double _previousPeriodSpent = 0.0;

  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);

    try {
      // Load total budget
      _totalBudget = await _budgetService.getTotalBudget();

      // Load category budgets
      final budgets = await _budgetService.getAllCategoryBudgets();

      // Calculate date range based on selected period
      final dateRange = _getDateRangeForPeriod();

      // Load spent amounts for each category
      _categoryBudgets = [];
      for (var budget in budgets) {
        final spentAmount = await _budgetService.getCategorySpentAmount(
          categoryName: budget['categoryName'],
          startDate: dateRange['start']!,
          endDate: dateRange['end']!,
        );

        _categoryBudgets.add({
          'categoryName': budget['categoryName'],
          'icon': _getIconFromName(budget['iconName']),
          'color': _getColorFromHex(budget['colorHex']),
          'budgetLimit': budget['budgetLimit'],
          'spentAmount': spentAmount,
        });
      }

      // Load total spent amount
      _spentAmount = await _budgetService.getTotalSpentAmount(
        startDate: dateRange['start']!,
        endDate: dateRange['end']!,
      );

      // Load previous period spent
      final previousRange = _getPreviousPeriodDateRange();
      _previousPeriodSpent = await _budgetService.getTotalSpentAmount(
        startDate: previousRange['start']!,
        endDate: previousRange['end']!,
      );

      _calculateBudgetValues();
      await _checkBudgetAlerts();
      await _checkAchievements();
    } catch (e) {
      debugPrint('Error loading budget data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, DateTime> _getDateRangeForPeriod() {
    final now = _currentMonth;
    DateTime start, end;

    switch (_selectedPeriod) {
      case 'Weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case 'Yearly':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31);
        break;
      case 'Monthly':
      default:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
    }

    return {'start': start, 'end': end};
  }

  Map<String, DateTime> _getPreviousPeriodDateRange() {
    final now = _currentMonth;
    DateTime start, end;

    switch (_selectedPeriod) {
      case 'Weekly':
        final currentStart = now.subtract(Duration(days: now.weekday - 1));
        start = currentStart.subtract(const Duration(days: 7));
        end = currentStart.subtract(const Duration(days: 1));
        break;
      case 'Yearly':
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year - 1, 12, 31);
        break;
      case 'Monthly':
      default:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
    }

    return {'start': start, 'end': end};
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _calculateBudgetValues() {
    _remainingAmount = _totalBudget - _spentAmount;
    _spendingPercentage = _totalBudget > 0
        ? (_spentAmount / _totalBudget * 100).clamp(0, 100)
        : 0.0;
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
    _loadBudgetData();
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    HapticFeedback.lightImpact();
    _loadBudgetData();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });

    if (period == 'Custom') {
      _showCustomPeriodPicker();
    } else {
      _loadBudgetData();
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);

                  // Find the category to get its icon and color
                  final category = _categoryBudgets.firstWhere(
                    (c) => c['categoryName'] == categoryName,
                  );

                  await _budgetService.saveCategoryBudget(
                    categoryName: categoryName,
                    iconName: _getIconName(category['icon']),
                    colorHex: _getColorHex(category['color']),
                    budgetLimit: double.parse(controller.text),
                  );

                  await _loadBudgetData();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Budget limit updated to \$${controller.text}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.movie) return 'movie';
    if (icon == Icons.medical_services) return 'medical_services';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.fitness_center) return 'fitness_center';
    return 'category';
  }

  String _getColorHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController limitController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String selectedIcon = 'category';
    String selectedColor = 'FF6B6B';

    final availableIcons = [
      {'name': 'restaurant', 'icon': Icons.restaurant},
      {'name': 'directions_car', 'icon': Icons.directions_car},
      {'name': 'shopping_bag', 'icon': Icons.shopping_bag},
      {'name': 'home', 'icon': Icons.home},
      {'name': 'movie', 'icon': Icons.movie},
      {'name': 'medical_services', 'icon': Icons.medical_services},
      {'name': 'school', 'icon': Icons.school},
      {'name': 'fitness_center', 'icon': Icons.fitness_center},
    ];

    final availableColors = [
      'FF6B6B',
      '4ECDC4',
      'FFBE0B',
      '95E1D3',
      'AA96DA',
      'FF8FAB',
      '4CAF50',
      'FF9800',
    ];

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Add Category Budget',
                style: theme.textTheme.titleLarge,
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(height: 2.h),
                      Text('Select Icon', style: theme.textTheme.titleSmall),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: availableIcons.map((iconData) {
                          final isSelected = selectedIcon == iconData['name'];
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = iconData['name'] as String;
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.2,
                                      )
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                iconData['icon'] as IconData,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 2.h),
                      Text('Select Color', style: theme.textTheme.titleSmall),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: availableColors.map((colorHex) {
                          final isSelected = selectedColor == colorHex;
                          final color = Color(
                            int.parse('FF$colorHex', radix: 16),
                          );
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = colorHex;
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);

                      await _budgetService.saveCategoryBudget(
                        categoryName: nameController.text.trim(),
                        iconName: selectedIcon,
                        colorHex: selectedColor,
                        budgetLimit: double.parse(limitController.text),
                      );

                      await _loadBudgetData();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${nameController.text} budget created',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Navigation Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
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

                    // Category Budget List or Empty State
                    _categoryBudgets.isEmpty
                        ? Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 4.h,
                            ),
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No Budget Categories',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Create your first budget category to start tracking your spending',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 3.h),
                                ElevatedButton.icon(
                                  onPressed: _showAddCategoryDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Category'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _categoryBudgets.length,
                            itemBuilder: (context, index) {
                              final category = _categoryBudgets[index];
                              return CategoryBudgetItem(
                                categoryName:
                                    category["categoryName"] as String,
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
                                  Navigator.pushNamed(
                                    context,
                                    '/transaction-history',
                                  );
                                },
                                onSetAlert: () => _showAlertSettingsDialog(),
                              );
                            },
                          ),

                    SizedBox(height: 2.h),

                    // Smart Suggestions Card (only show if there are budgets)
                    if (_categoryBudgets.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
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
                                    _spentAmount > 0
                                        ? 'You\'re doing great! Keep tracking your expenses to stay within budget.'
                                        : 'Start adding expenses to see personalized budget insights.',
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
