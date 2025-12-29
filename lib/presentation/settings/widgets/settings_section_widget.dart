import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Settings section widget with header and list of setting items
class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
              bottom: BorderSide(
                color: isDark
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
