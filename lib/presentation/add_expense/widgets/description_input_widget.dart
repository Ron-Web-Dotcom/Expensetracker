import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DescriptionInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const DescriptionInputWidget({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: hasError ? theme.colorScheme.error : null,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          constraints: BoxConstraints(minHeight: 18.h, maxHeight: 28.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: hasError ? 2 : 1,
            ),
            boxShadow: hasError
                ? [
                    BoxShadow(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            minLines: 5,
            maxLength: 200,
            textAlignVertical: TextAlignVertical.top,
            style: theme.textTheme.bodyMedium,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Add a note about this expense...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        if (hasError) SizedBox(height: 1.h),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
