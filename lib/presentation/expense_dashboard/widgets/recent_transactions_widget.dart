import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/expense_data_service.dart';
import '../../../services/expense_notifier.dart';

/// Recent transactions list with swipe actions
class RecentTransactionsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final VoidCallback onViewAll;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.onViewAll,
  });

  @override
  State<RecentTransactionsWidget> createState() =>
      _RecentTransactionsWidgetState();
}

class _RecentTransactionsWidgetState extends State<RecentTransactionsWidget> {
  final ExpenseNotifier _expenseNotifier = ExpenseNotifier();

  @override
  void initState() {
    super.initState();
    _expenseNotifier.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _expenseNotifier.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleEdit(BuildContext context, Map<String, dynamic> transaction) {
    HapticFeedback.mediumImpact();

    final amount = (transaction["amount"] as num).toDouble().abs();
    final transactionType =
        transaction["transactionType"] as String? ??
        ((transaction["amount"] as num).toDouble() > 0 ? 'income' : 'expense');

    Navigator.pushNamed(
      context,
      AppRoutes.addExpense,
      arguments: {
        'isEdit': true,
        'transaction': {
          'id': transaction['id'],
          'amount': amount,
          'category': transaction['category'],
          'date': transaction['date'],
          'paymentMethod': transaction['paymentMethod'] ?? 'Cash',
          'description': transaction['description'] ?? '',
          'receiptPhotos': transaction['receiptPhotos'] ?? [],
          'hasLocation': transaction['hasLocation'] ?? false,
          'transactionType': transactionType,
        },
      },
    );
  }

  Future<void> _handleDuplicate(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) async {
    HapticFeedback.mediumImpact();

    try {
      final expenseService = ExpenseDataService();
      final amount = (transaction['amount'] as num).toDouble();
      final transactionType =
          transaction['transactionType'] as String? ??
          (amount > 0 ? 'income' : 'expense');

      await expenseService.saveExpense(
        amount: amount.abs(),
        category: transaction['category'] as String,
        date: DateTime.now(),
        paymentMethod: transaction['paymentMethod'] as String? ?? 'Cash',
        description: '${transaction['description']} (Copy)',
        receiptPhotos: transaction['receiptPhotos'] as List<String>? ?? [],
        hasLocation: transaction['hasLocation'] as bool? ?? false,
        transactionType: transactionType,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duplicated: ${transaction["description"]}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) async {
    HapticFeedback.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete "${transaction["description"]}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final expenseService = ExpenseDataService();
        final transactionId = transaction['id'] as String;

        await expenseService.deleteExpense(transactionId);

        if (context.mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted: ${transaction["description"]}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: widget.onViewAll,
                child: Text(
                  'View All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        widget.transactions.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.transactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final transaction = widget.transactions[index];
                  return _buildTransactionItem(context, transaction);
                },
              ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final theme = Theme.of(context);
    final amount = transaction["amount"] as double;
    final isIncome = amount > 0;
    final transactionType =
        transaction["transactionType"] as String? ??
        (amount > 0 ? 'income' : 'expense');

    return Slidable(
      key: ValueKey(transaction["id"]),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (context) => _handleEdit(context, transaction),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(0),
          ),
          SlidableAction(
            onPressed: (context) => _handleDuplicate(context, transaction),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: Icons.content_copy,
            label: 'Duplicate',
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _handleDelete(context, transaction),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        color: theme.colorScheme.surface,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                    : theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: transaction["categoryIcon"] as String,
                  color: isIncome
                      ? const Color(0xFF4CAF50)
                      : theme.colorScheme.error,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction["description"] as String? ??
                        transaction["category"] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    children: [
                      Text(
                        transaction["category"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        '${transaction["date"]} at ${transaction["time"]}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isIncome
                        ? const Color(0xFF4CAF50)
                        : theme.colorScheme.error,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  transaction["date"] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'receipt_long',
                color: theme.colorScheme.primary,
                size: 40,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'No Transactions Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start tracking your expenses by\nadding your first transaction',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
