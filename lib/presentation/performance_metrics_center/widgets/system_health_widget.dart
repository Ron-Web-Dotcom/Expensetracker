import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SystemHealthWidget extends StatelessWidget {
  const SystemHealthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(3.w),
      children: [
        _buildOverallHealth(context),
        SizedBox(height: 2.h),
        _buildServerUptime(context),
        SizedBox(height: 2.h),
        _buildDataIntegrity(context),
        SizedBox(height: 2.h),
        _buildSecurityStatus(context),
        SizedBox(height: 2.h),
        _buildComplianceStatus(context),
      ],
    );
  }

  Widget _buildOverallHealth(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 35.sp),
          SizedBox(height: 1.h),
          Text(
            'System Healthy',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'All systems operational',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHealthStat('99.9%', 'Uptime'),
              _buildHealthStat('0', 'Critical Issues'),
              _buildHealthStat('2', 'Warnings'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildServerUptime(BuildContext context) {
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
                Icons.cloud_done,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Server Uptime',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildUptimeRow(context, 'Last 24 Hours', '100%', Colors.green),
          _buildUptimeRow(context, 'Last 7 Days', '99.95%', Colors.green),
          _buildUptimeRow(context, 'Last 30 Days', '99.87%', Colors.green),
          _buildUptimeRow(context, 'Last 90 Days', '99.82%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildUptimeRow(
    BuildContext context,
    String period,
    String uptime,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 2.w),
              Text(
                uptime,
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

  Widget _buildDataIntegrity(BuildContext context) {
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
                Icons.verified_user,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Data Integrity Checks',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildIntegrityRow(
            context,
            'Last Check',
            '15 minutes ago',
            Icons.schedule,
          ),
          _buildIntegrityRow(
            context,
            'Status',
            'All Passed',
            Icons.check_circle,
          ),
          _buildIntegrityRow(
            context,
            'Records Validated',
            '12,458',
            Icons.fact_check,
          ),
          _buildIntegrityRow(context, 'Errors Found', '0', Icons.error_outline),
        ],
      ),
    );
  }

  Widget _buildIntegrityRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 16.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus(BuildContext context) {
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
                Icons.security,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Security Scan Results',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSecurityRow(
            context,
            'Vulnerabilities',
            '0 Critical',
            Colors.green,
          ),
          _buildSecurityRow(context, 'Last Scan', '3 hours ago', Colors.blue),
          _buildSecurityRow(context, 'Encryption', 'Active', Colors.green),
          _buildSecurityRow(context, 'Authentication', 'Secure', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSecurityRow(
    BuildContext context,
    String label,
    String value,
    Color statusColor,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface,
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
                  fontSize: 13.sp,
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

  Widget _buildComplianceStatus(BuildContext context) {
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
              Icon(Icons.policy, color: theme.colorScheme.primary, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                'Compliance Status',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildComplianceRow(context, 'GDPR', 'Compliant', Icons.check_circle),
          _buildComplianceRow(
            context,
            'Data Privacy',
            'Compliant',
            Icons.check_circle,
          ),
          _buildComplianceRow(
            context,
            'Security Standards',
            'Compliant',
            Icons.check_circle,
          ),
          _buildComplianceRow(
            context,
            'Last Audit',
            '2 weeks ago',
            Icons.event,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 16.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
