import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransactionMenuBarWidget extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const TransactionMenuBarWidget({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  static const List<Map<String, dynamic>> menuItems = [
    {'id': 'All', 'label': 'All', 'icon': Icons.list_alt},
    {'id': 'Expenses', 'label': 'Expenses', 'icon': Icons.arrow_downward},
    {'id': 'Income', 'label': 'Income', 'icon': Icons.arrow_upward},
    {'id': 'Recurring', 'label': 'Recurring', 'icon': Icons.repeat},
    {'id': 'Receipts', 'label': 'Receipts', 'icon': Icons.receipt},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final isSelected = selectedMenu == item['id'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildMenuItem(
              context,
              theme,
              item['id'] as String,
              item['label'] as String,
              item['icon'] as IconData,
              isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    String id,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onMenuSelected(id);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
