import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReminderTypeSelectorWidget extends StatelessWidget {
  final List<String> selectedTypes;
  final Function(List<String>) onTypesChanged;

  const ReminderTypeSelectorWidget({
    super.key,
    required this.selectedTypes,
    required this.onTypesChanged,
  });

  void _toggleType(String type) {
    final newTypes = List<String>.from(selectedTypes);
    if (newTypes.contains(type)) {
      if (newTypes.length > 1) {
        newTypes.remove(type);
      }
    } else {
      newTypes.add(type);
    }
    onTypesChanged(newTypes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final reminderOptions = [
      {
        'type': 'expense_logging',
        'title': 'Expense Logging',
        'subtitle': 'Remind me to log daily expenses',
        'icon': Icons.receipt_long,
      },
      {
        'type': 'budget_review',
        'title': 'Budget Review',
        'subtitle': 'Check my spending progress',
        'icon': Icons.account_balance_wallet,
      },
      {
        'type': 'receipt_capture',
        'title': 'Receipt Capture',
        'subtitle': 'Snap photos of receipts',
        'icon': Icons.camera_alt,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder Types',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Select what you want to be reminded about',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE0E0E0),
          ),
          ...reminderOptions.map((option) {
            final isSelected = selectedTypes.contains(option['type']);
            return Column(
              children: [
                InkWell(
                  onTap: () => _toggleType(option['type'] as String),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withAlpha(26)
                                : (isDark
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            option['icon'] as IconData,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                      ? const Color(0xFFB0B0B0)
                                      : const Color(0xFF757575)),
                            size: 5.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['title'] as String,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF212121),
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                option['subtitle'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark
                                        ? const Color(0xFF3D3D3D)
                                        : const Color(0xFFE0E0E0)),
                              width: 2,
                            ),
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 3.w,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                if (option != reminderOptions.last)
                  Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF3D3D3D)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
