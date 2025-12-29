import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TransactionListItemWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TransactionListItemWidget({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onLongPress,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills & Utilities':
        return Icons.receipt_long;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Salary':
        return Icons.account_balance_wallet;
      case 'Freelance':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category, ThemeData theme) {
    switch (category) {
      case 'Food & Dining':
        return const Color(0xFFFF6B6B);
      case 'Transportation':
        return const Color(0xFF4ECDC4);
      case 'Shopping':
        return const Color(0xFFFFBE0B);
      case 'Entertainment':
        return const Color(0xFF9B59B6);
      case 'Bills & Utilities':
        return const Color(0xFF3498DB);
      case 'Healthcare':
        return const Color(0xFF2ECC71);
      case 'Salary':
        return const Color(0xFF27AE60);
      case 'Freelance':
        return const Color(0xFF16A085);
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = transaction['amount'] as double;
    final isIncome = amount > 0;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String;
    final date = transaction['date'] as DateTime;
    final hasReceipt = transaction['hasReceipt'] as bool;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  category,
                  theme,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(category).codePoint.toString(),
                  color: _getCategoryColor(category, theme),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasReceipt)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: CustomIconWidget(
                            iconName: 'receipt',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isIncome
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFE74C3C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['paymentMethod'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
