import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Settings item with toggle switch
class ToggleSettingsItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? leadingIcon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const ToggleSettingsItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                CustomIconWidget(
                  iconName: leadingIcon!,
                  color: isDark
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF757575),
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF212121),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? const Color(0xFFB0B0B0)
                              : const Color(0xFF757575),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Padding(
              padding: EdgeInsets.only(left: leadingIcon != null ? 12.w : 4.w),
              child: Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFE0E0E0),
              ),
            ),
          ),
      ],
    );
  }
}
