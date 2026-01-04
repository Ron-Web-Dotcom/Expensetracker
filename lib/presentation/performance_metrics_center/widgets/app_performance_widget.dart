import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppPerformanceWidget extends StatelessWidget {
  const AppPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(3.w),
      children: [
        _buildMetricCard(
          context,
          title: 'Load Times',
          icon: Icons.speed,
          metrics: [
            {'label': 'App Launch', 'value': '1.2s', 'status': 'good'},
            {'label': 'Screen Transition', 'value': '0.3s', 'status': 'good'},
            {'label': 'Data Load', 'value': '0.8s', 'status': 'good'},
          ],
        ),
        SizedBox(height: 2.h),
        _buildMetricCard(
          context,
          title: 'Memory Usage',
          icon: Icons.memory,
          metrics: [
            {'label': 'Current Usage', 'value': '142 MB', 'status': 'good'},
            {'label': 'Peak Usage', 'value': '198 MB', 'status': 'warning'},
            {'label': 'Average', 'value': '156 MB', 'status': 'good'},
          ],
        ),
        SizedBox(height: 2.h),
        _buildMetricCard(
          context,
          title: 'Battery Consumption',
          icon: Icons.battery_charging_full,
          metrics: [
            {'label': 'Last Hour', 'value': '3.2%', 'status': 'good'},
            {'label': 'Daily Average', 'value': '5.8%', 'status': 'good'},
            {'label': 'Background', 'value': '0.4%', 'status': 'good'},
          ],
        ),
        SizedBox(height: 2.h),
        _buildCrashAnalytics(context),
        SizedBox(height: 2.h),
        _buildDeviceBreakdown(context),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, String>> metrics,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...metrics.map(
            (metric) => _buildMetricRow(
              context,
              label: metric['label']!,
              value: metric['value']!,
              status: metric['status']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    required String status,
  }) {
    final theme = Theme.of(context);
    Color statusColor;

    switch (status) {
      case 'good':
        statusColor = Colors.green;
        break;
      case 'warning':
        statusColor = Colors.orange;
        break;
      case 'critical':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrashAnalytics(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Crash Analytics',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCrashStat(context, '0.02%', 'Crash Rate'),
              _buildCrashStat(context, '99.98%', 'Stability'),
              _buildCrashStat(context, '2', 'Last 7 Days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCrashStat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceBreakdown(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.devices,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Device Breakdown',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildDeviceBar(context, 'iOS', 0.62, Colors.blue),
          SizedBox(height: 1.h),
          _buildDeviceBar(context, 'Android', 0.38, Colors.green),
        ],
      ),
    );
  }

  Widget _buildDeviceBar(
    BuildContext context,
    String platform,
    double percentage,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              platform,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
