import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AlertCategoryWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Map<String, dynamic>> alerts;
  final Function(String key, bool value) onToggle;

  const AlertCategoryWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.alerts,
    required this.onToggle,
  });

  @override
  State<AlertCategoryWidget> createState() => _AlertCategoryWidgetState();
}

class _AlertCategoryWidgetState extends State<AlertCategoryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF212121),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${widget.alerts.length} alert types',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? const Color(0xFFB0B0B0)
                                : const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : const Color(0xFF757575),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF3D3D3D)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: widget.alerts.map((alert) {
                  return _buildAlertItem(
                    context,
                    alert['title'] as String,
                    alert['subtitle'] as String,
                    alert['key'] as String,
                    alert['value'] as bool,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    String title,
    String subtitle,
    String key,
    bool value,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              widget.onToggle(key, newValue);
            },
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
