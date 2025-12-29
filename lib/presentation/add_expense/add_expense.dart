import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/location_toggle_widget.dart';
import './widgets/payment_method_widget.dart';
import './widgets/receipt_attachment_widget.dart';
import './widgets/animated_background_widget.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final AnalyticsService _analytics = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();
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

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('add_expense');
    _loadDefaultCategory();
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
      if (amount == null || amount <= 0) {
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
        !_isSaving;
  }

  void _handleCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
    });
    _analytics.trackFeatureUsage('category_selected');
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

    // Track expense addition
    await _analytics.trackExpenseAdded(
      amount: double.parse(_amountController.text),
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

    // Simulate save operation
    await Future.delayed(const Duration(milliseconds: 800));

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
    Navigator.pop(context);
  }

  Future<void> _checkBudgetAlertsAfterExpense() async {
    final budgetAlertsEnabled = await _settingsService.isBudgetAlertsEnabled();
    if (!budgetAlertsEnabled) return;

    final expenseAmount = double.parse(_amountController.text);

    // Mock budget data - in a real app, this would come from a database
    final Map<String, double> categoryBudgets = {
      'Food & Dining': 600.0,
      'Transportation': 400.0,
      'Shopping': 500.0,
      'Housing': 800.0,
      'Entertainment': 300.0,
      'Healthcare': 200.0,
      'Utilities': 250.0,
      'Education': 400.0,
    };

    final Map<String, double> categorySpent = {
      'Food & Dining': 485.0,
      'Transportation': 320.0,
      'Shopping': 450.0,
      'Housing': 800.0,
      'Entertainment': 95.0,
      'Healthcare': 0.0,
      'Utilities': 180.0,
      'Education': 250.0,
    };

    // Update spent amount for the selected category
    if (categoryBudgets.containsKey(_selectedCategory)) {
      final currentSpent = categorySpent[_selectedCategory!] ?? 0.0;
      final newSpent = currentSpent + expenseAmount;
      final budget = categoryBudgets[_selectedCategory!]!;

      await _notificationService.checkAndSendBudgetAlert(
        spent: newSpent,
        budget: budget,
        categoryName: _selectedCategory!,
      );
    }

    // Check overall budget
    final totalBudget = 3000.0;
    final totalSpent =
        categorySpent.values.fold(0.0, (sum, val) => sum + val) + expenseAmount;

    await _notificationService.checkAndSendBudgetAlert(
      spent: totalSpent,
      budget: totalBudget,
      categoryName: 'Total Budget',
    );
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
                Navigator.pop(context);
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Animated Background
          const AnimatedBackgroundWidget(),

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
                        child: Text(
                          'Add Expense',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: _canSave ? _saveExpense : null,
                        child: Text(
                          'Save',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _canSave
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.4,
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

                            // Amount Input
                            AmountInputWidget(
                              controller: _amountController,
                              errorText: _amountError,
                              onChanged: (value) {
                                setState(() {
                                  _amountError = null;
                                });
                              },
                            ),

                            SizedBox(height: 3.h),

                            // Category Selector
                            CategorySelectorWidget(
                              selectedCategory: _selectedCategory,
                              onCategorySelected: _handleCategorySelected,
                              errorText: _categoryError,
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
