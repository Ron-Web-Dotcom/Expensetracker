import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AlertSummaryWidget extends StatelessWidget {
  final int activeAlerts;
  final int totalAlerts;
  final String? lastAlertTime;

  const AlertSummaryWidget({
    super.key,
    required this.activeAlerts,
    required this.totalAlerts,
    this.lastAlertTime,
  });

  String _formatLastAlertTime() {
    if (lastAlertTime == null) return 'No recent alerts';

    final alertDate = DateTime.parse(lastAlertTime!);
    final now = DateTime.now();
    final difference = now.difference(alertDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF2D5F8D)]
              : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.white, size: 6.w),
              SizedBox(width: 2.w),
              Text(
                'Alert Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Active',
                activeAlerts.toString(),
                Icons.circle,
                const Color(0xFFFF5252),
              ),
              Container(
                width: 1,
                height: 5.h,
                color: Colors.white.withAlpha(77),
              ),
              _buildStatItem(
                context,
                'Total (30d)',
                totalAlerts.toString(),
                Icons.history,
                Colors.white70,
              ),
              Container(
                width: 1,
                height: 5.h,
                color: Colors.white.withAlpha(77),
              ),
              _buildStatItem(
                context,
                'Last Alert',
                _formatLastAlertTime(),
                Icons.access_time,
                Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 5.w),
        SizedBox(height: 1.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
