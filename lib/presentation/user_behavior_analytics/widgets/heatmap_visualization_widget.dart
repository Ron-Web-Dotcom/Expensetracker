import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class HeatmapVisualizationWidget extends StatelessWidget {
  const HeatmapVisualizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> heatmapData = [
      {'area': 'Add Expense Button', 'intensity': 0.9, 'taps': 245},
      {'area': 'Dashboard Cards', 'intensity': 0.75, 'taps': 189},
      {'area': 'Analytics Charts', 'intensity': 0.6, 'taps': 142},
      {'area': 'Budget Section', 'intensity': 0.45, 'taps': 98},
      {'area': 'Settings Menu', 'intensity': 0.3, 'taps': 67},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'touch_app',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Interaction Heatmap',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...heatmapData.map(
              (data) => Padding(
                padding: EdgeInsets.only(bottom: 1.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data['area'], style: theme.textTheme.bodyMedium),
                        Text(
                          '${data['taps']} taps',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: data['intensity'],
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getHeatColor(data['intensity'], theme),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem(
                  theme,
                  'Low',
                  AppTheme.successLight.withValues(alpha: 0.3),
                ),
                _buildLegendItem(
                  theme,
                  'Medium',
                  AppTheme.warningLight.withValues(alpha: 0.5),
                ),
                _buildLegendItem(theme, 'High', AppTheme.errorLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeatColor(double intensity, ThemeData theme) {
    if (intensity > 0.7) {
      return AppTheme.errorLight;
    } else if (intensity > 0.4) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
