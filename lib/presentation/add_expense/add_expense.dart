import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../services/expense_data_service.dart';
import '../../services/budget_data_service.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/location_toggle_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/receipt_attachment_widget.dart';
import './widgets/animated_background_widget.dart';
import './widgets/transaction_type_toggle_widget.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final BudgetDataService _budgetDataService = BudgetDataService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<String> _receiptPhotos = [];
  String _selectedPaymentMethod = 'Cash';
  bool _enableLocation = false;
  bool _isSaving = false;

  String? _amountError;
  String? _categoryError;
  String? _descriptionError;

  bool _isEditMode = false;
  String? _editingTransactionId;
  String _transactionType = 'expense'; // 'expense' or 'income'

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('add_expense');
    _loadDefaultCategory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      // Set transaction type
      if (args['transactionType'] != null && _transactionType == 'expense') {
        _transactionType = args['transactionType'] as String;
      }

      // Handle edit mode
      if (args['isEdit'] == true && !_isEditMode) {
        _isEditMode = true;
        _editingTransactionId = args['transactionId'] as String?;
        _transactionType = args['transactionType'] as String? ?? 'expense';

        final amount = args['amount'];
        if (amount is double) {
          _amountController.text = amount.abs().toStringAsFixed(2);
        } else if (amount is num) {
          _amountController.text = amount.toDouble().abs().toStringAsFixed(2);
        }

        _selectedCategory = args['category'] as String?;
        _descriptionController.text = args['description'] as String? ?? '';

        final date = args['date'];
        if (date is DateTime) {
          // Validate date is not in the future
          if (date.isAfter(DateTime.now())) {
            _selectedDate = DateTime.now();
          } else {
            _selectedDate = date;
          }
        } else if (date is String) {
          try {
            final parsedDate = DateTime.parse(date);
            _selectedDate = parsedDate.isAfter(DateTime.now())
                ? DateTime.now()
                : parsedDate;
          } catch (e) {
            _selectedDate = DateTime.now();
          }
        } else {
          _selectedDate = DateTime.now();
        }

        _selectedPaymentMethod = args['paymentMethod'] as String? ?? 'Cash';
        _receiptPhotos = List<String>.from(
          args['receiptPhotos'] as List? ?? [],
        );
        _enableLocation = args['hasLocation'] as bool? ?? false;
        setState(() {});
      }
    }
  }

  Future<void> _loadDefaultCategory() async {
    final defaultCategory = await _settingsService.getDefaultCategory();
    if (mounted) {
      setState(() {
        _selectedCategory = defaultCategory;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _amountError = null;
      _categoryError = null;
      _descriptionError = null;
    });

    // Validate amount
    if (_amountController.text.isEmpty) {
      setState(() {
        _amountError = 'Please enter an amount';
      });
      isValid = false;
    } else {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0 || amount.isNaN || amount.isInfinite) {
        setState(() {
          _amountError = 'Please enter a valid amount greater than 0';
        });
        isValid = false;
      } else if (amount > 1000000) {
        setState(() {
          _amountError = 'Amount cannot exceed \$1,000,000';
        });
        isValid = false;
      }
    }

    // Validate category
    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Please select a category';
      });
      isValid = false;
    }

    // Validate description (required)
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _descriptionError = 'Please enter a description';
      });
      isValid = false;
    }

    return isValid;
  }

  bool get _canSave {
    return _amountController.text.isNotEmpty &&
        _selectedCategory != null &&
        _descriptionController.text.trim().isNotEmpty &&
        !_isSaving;
  }

  void _handleCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
    });
    _analytics.trackFeatureUsage('category_selected');
  }

  void _handleTransactionTypeChanged(String type) {
    setState(() {
      _transactionType = type;
      // Reset category when switching types to avoid invalid category for the new type
      _selectedCategory = null;
      _categoryError = null;
    });
    _analytics.trackFeatureUsage('transaction_type_changed');
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleReceiptAdded(String photoPath) {
    setState(() {
      _receiptPhotos.add(photoPath);
    });
    _analytics.trackFeatureUsage('receipt_added');
  }

  void _handleReceiptRemoved(String photoPath) {
    setState(() {
      _receiptPhotos.remove(photoPath);
    });
  }

  void _handleReceiptScanned(Map<String, dynamic> extractedData) {
    // Auto-populate fields from OCR data
    final amount = extractedData['amount'];
    final merchant = extractedData['merchant'];
    final date = extractedData['date'];

    setState(() {
      if (amount != null) {
        _amountController.text = amount.toStringAsFixed(2);
        _amountError = null;
      }
      if (merchant != null && _descriptionController.text.isEmpty) {
        _descriptionController.text = merchant;
      }
      if (date != null) {
        _selectedDate = date;
      }
    });

    _analytics.trackFeatureUsage('receipt_scanned');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt data extracted successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePaymentMethodChanged(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _handleLocationToggled(bool enabled) {
    setState(() {
      _enableLocation = enabled;
    });
  }

  Future<void> _saveExpense() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    // Clean and parse amount safely
    final cleanAmount = _amountController.text.replaceAll(',', '').trim();
    final expenseAmount = double.tryParse(cleanAmount);

    if (expenseAmount == null) {
      setState(() {
        _isSaving = false;
        _amountError = 'Invalid amount format';
      });
      return;
    }

    // Save expense to local storage
    await _expenseDataService.saveExpense(
      amount: expenseAmount,
      category: _selectedCategory!,
      date: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      description: _descriptionController.text.trim(),
      receiptPhotos: _receiptPhotos,
      hasLocation: _enableLocation,
      transactionType: _transactionType,
    );

    // Track expense addition
    await _analytics.trackExpenseAdded(
      amount: expenseAmount,
      category: _selectedCategory!,
      paymentMethod: _selectedPaymentMethod,
    );

    // Simulate AI categorization tracking
    await _analytics.trackAICategorization(
      suggestedCategory: _selectedCategory!,
      finalCategory: _selectedCategory!,
      wasAccepted: true,
    );

    // Check budget alerts after adding expense
    await _checkBudgetAlertsAfterExpense();

    if (!mounted) return;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Expense saved successfully',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to dashboard
    Navigator.pushReplacementNamed(context, '/expense-dashboard');
  }

  Future<void> _checkBudgetAlertsAfterExpense() async {
    final budgetAlertsEnabled = await _settingsService.isBudgetAlertsEnabled();
    if (!budgetAlertsEnabled) return;

    final expenseAmount = double.parse(_amountController.text);

    // Get real budget data from service
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Get category budget and spending
    if (_selectedCategory != null) {
      final allBudgets = await _budgetDataService.getAllCategoryBudgets();
      final categoryBudgetData = allBudgets.firstWhere(
        (b) => b['categoryName'] == _selectedCategory,
        orElse: () => {},
      );

      if (categoryBudgetData.isNotEmpty) {
        final categoryBudget = (categoryBudgetData['budgetLimit'] as num)
            .toDouble();
        final categorySpent = await _expenseDataService.getSpendingByCategory(
          startDate: startOfMonth,
          endDate: endOfMonth,
        );

        final currentSpent = (categorySpent[_selectedCategory!] ?? 0.0).abs();
        final newSpent = currentSpent + expenseAmount;

        await _notificationService.checkAndSendBudgetAlert(
          spent: newSpent,
          budget: categoryBudget,
          categoryName: _selectedCategory!,
        );
      }
    }

    // Check overall budget
    final totalBudget = await _budgetDataService.getTotalBudget();

    if (totalBudget > 0) {
      final totalSpent = await _expenseDataService.getTotalSpending(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final newTotalSpent = totalSpent + expenseAmount;

      await _notificationService.checkAndSendBudgetAlert(
        spent: newTotalSpent,
        budget: totalBudget,
        categoryName: 'Total Budget',
      );
    }
  }

  void _handleCancel() {
    if (_amountController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategory != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Discard Changes?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/expense-dashboard');
              },
              child: Text(
                'Discard',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/expense-dashboard');
    }
  }

  Color get _primaryColor {
    return _transactionType == 'income'
        ? const Color(0xFF4CAF50) // Green for income
        : const Color(0xFFEF5350); // Red for expense
  }

  String get _screenTitle {
    if (_isEditMode) {
      return _transactionType == 'income' ? 'Edit Income' : 'Edit Expense';
    }
    return _transactionType == 'income' ? 'Add Income' : 'Add Expense';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Animated Background with dynamic color
          AnimatedBackgroundWidget(color: _primaryColor),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: theme.colorScheme.onSurface,
                          size: 24,
                        ),
                        onPressed: _handleCancel,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: _transactionType == 'income'
                                  ? 'trending_up'
                                  : 'trending_down',
                              color: _primaryColor,
                              size: 24,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _screenTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _canSave ? _saveExpense : null,
                        child: Text(
                          'Save',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _canSave
                                ? _primaryColor
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),

                            // Transaction Type Toggle (only show if not in edit mode)
                            if (!_isEditMode)
                              Column(
                                children: [
                                  TransactionTypeToggleWidget(
                                    selectedType: _transactionType,
                                    onTypeChanged:
                                        _handleTransactionTypeChanged,
                                  ),
                                  SizedBox(height: 3.h),
                                ],
                              ),

                            // Amount Input
                            AmountInputWidget(
                              controller: _amountController,
                              errorText: _amountError,
                              onChanged: (value) {
                                setState(() {
                                  _amountError = null;
                                });
                              },
                              transactionType: _transactionType,
                            ),

                            SizedBox(height: 3.h),

                            // Category Selector
                            CategorySelectorWidget(
                              selectedCategory: _selectedCategory,
                              onCategorySelected: _handleCategorySelected,
                              errorText: _categoryError,
                              transactionType: _transactionType,
                            ),

                            SizedBox(height: 3.h),

                            // Date Picker
                            DatePickerWidget(
                              selectedDate: _selectedDate,
                              onDateSelected: _handleDateSelected,
                            ),

                            SizedBox(height: 3.h),

                            // Description Input
                            DescriptionInputWidget(
                              controller: _descriptionController,
                              errorText: _descriptionError,
                              onChanged: (value) {
                                setState(() {
                                  _descriptionError = null;
                                });
                              },
                            ),

                            SizedBox(height: 3.h),

                            // Receipt Attachment
                            ReceiptAttachmentWidget(
                              receiptPhotos: _receiptPhotos,
                              onReceiptAdded: _handleReceiptAdded,
                              onReceiptRemoved: _handleReceiptRemoved,
                              onReceiptScanned: _handleReceiptScanned,
                            ),

                            SizedBox(height: 3.h),

                            // Payment Method
                            PaymentMethodWidget(
                              selectedMethod: _selectedPaymentMethod,
                              onMethodChanged: _handlePaymentMethodChanged,
                            ),

                            SizedBox(height: 3.h),

                            // Location Toggle
                            LocationToggleWidget(
                              enabled: _enableLocation,
                              onToggled: _handleLocationToggled,
                            ),

                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
