import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
import '../../widgets/error_boundary.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> with ErrorHandlerMixin {
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
        if (date == null) {
          _selectedDate = DateTime.now();
        } else if (date is DateTime) {
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
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
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
    } else if (_descriptionController.text.trim().length > 200) {
      setState(() {
        _descriptionError = 'Description cannot exceed 200 characters';
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
    await safeAsync(() async {
      // Clear previous errors
      setState(() {
        _amountError = null;
        _categoryError = null;
        _descriptionError = null;
      });

      // Validate inputs
      bool isValid = true;

      // Validate amount
      final amountText = _amountController.text.trim();
      final amount = double.tryParse(amountText);

      if (amount == null || amount <= 0 || amount.isNaN || amount.isInfinite) {
        setState(
          () => _amountError = 'Please enter a valid amount greater than 0',
        );
        isValid = false;
      } else if (amount > 1000000) {
        setState(() => _amountError = 'Amount cannot exceed \$1,000,000');
        isValid = false;
      }

      // Validate category
      if (_selectedCategory == null || _selectedCategory!.isEmpty) {
        setState(() => _categoryError = 'Please select a category');
        isValid = false;
      }

      if (!isValid) {
        _analytics.trackFormSubmission(
          'add_expense',
          false,
          errorMessage: 'Validation failed',
        );
        return;
      }

      setState(() => _isSaving = true);

      if (_isEditMode && _editingTransactionId != null) {
        // Update existing expense
        await _expenseDataService.updateExpense(
          id: _editingTransactionId!,
          amount: amount!,
          category: _selectedCategory!,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          description: _descriptionController.text.trim(),
          receiptPhotos: _receiptPhotos,
          hasLocation: _enableLocation,
          transactionType: _transactionType,
        );

        _analytics.trackEvent(
          'expense_updated',
          parameters: {
            'category': _selectedCategory!,
            'amount': amount,
            'transaction_type': _transactionType,
          },
        );
      } else {
        // Save new expense
        await _expenseDataService.saveExpense(
          amount: amount!,
          category: _selectedCategory!,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          description: _descriptionController.text.trim(),
          receiptPhotos: _receiptPhotos,
          hasLocation: _enableLocation,
          transactionType: _transactionType,
        );

        _analytics.trackExpenseAdded(
          amount: amount,
          category: _selectedCategory!,
          paymentMethod: _selectedPaymentMethod,
        );
        _analytics.trackFormSubmission('add_expense', true);
      }

      // Check budget alerts
      await _checkBudgetAlertsAfterExpense();

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, true);
      }
    }, context: 'Saving expense');
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
    return ErrorBoundary(
      screenName: 'AddExpense',
      child: Semantics(
        label: 'Add Expense Screen',
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Semantics(
              label: _isEditMode
                  ? 'Edit ${_transactionType == "expense" ? "Expense" : "Income"}'
                  : 'Add ${_transactionType == "expense" ? "Expense" : "Income"}',
              child: Text(
                _isEditMode
                    ? 'Edit ${_transactionType == "expense" ? "Expense" : "Income"}'
                    : 'Add ${_transactionType == "expense" ? "Expense" : "Income"}',
              ),
            ),
            leading: Semantics(
              label: 'Go back',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, semanticLabel: 'Back'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: Stack(
            children: [
              const AnimatedBackgroundWidget(),
              Semantics(
                label: 'Expense entry form',
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Transaction type selector',
                          child: TransactionTypeToggleWidget(
                            selectedType: _transactionType,
                            onTypeChanged: (type) {
                              setState(() => _transactionType = type);
                              _analytics.trackEvent(
                                'transaction_type_changed',
                                parameters: {'type': type},
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Semantics(
                          label: 'Amount input field',
                          textField: true,
                          child: AmountInputWidget(
                            controller: _amountController,
                            errorText: _amountError,
                            transactionType: _transactionType,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Category selector',
                          button: true,
                          child: CategorySelectorWidget(
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                                _categoryError = null;
                              });
                            },
                            errorText: _categoryError,
                            transactionType: _transactionType,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Date picker',
                          button: true,
                          child: DatePickerWidget(
                            selectedDate: _selectedDate,
                            onDateSelected: (date) =>
                                setState(() => _selectedDate = date),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Description input field',
                          textField: true,
                          child: DescriptionInputWidget(
                            controller: _descriptionController,
                            errorText: _descriptionError,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Payment method selector',
                          child: PaymentMethodWidget(
                            selectedMethod: _selectedPaymentMethod,
                            onMethodChanged: (method) =>
                                setState(() => _selectedPaymentMethod = method),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Receipt attachment options',
                          child: ReceiptAttachmentWidget(
                            receiptPhotos: _receiptPhotos,
                            onReceiptAdded: _handleReceiptAdded,
                            onReceiptRemoved: _handleReceiptRemoved,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Semantics(
                          label: 'Location tracking toggle',
                          child: LocationToggleWidget(
                            enabled: _enableLocation,
                            onToggled: (value) =>
                                setState(() => _enableLocation = value),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Semantics(
                          label: _isEditMode
                              ? 'Update ${_transactionType == "expense" ? "expense" : "income"}'
                              : 'Save ${_transactionType == "expense" ? "expense" : "income"}',
                          button: true,
                          onTap: _isSaving ? null : _saveExpense,
                          child: SizedBox(
                            width: double.infinity,
                            height: 6.h,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveExpense,
                              child: _isSaving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _isEditMode
                                          ? 'Update ${_transactionType == "expense" ? "Expense" : "Income"}'
                                          : 'Save ${_transactionType == "expense" ? "Expense" : "Income"}',
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
