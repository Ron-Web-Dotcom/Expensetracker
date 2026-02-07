import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AlertConfigurationWidget extends StatefulWidget {
  const AlertConfigurationWidget({super.key});

  @override
  State<AlertConfigurationWidget> createState() =>
      _AlertConfigurationWidgetState();
}

class _AlertConfigurationWidgetState extends State<AlertConfigurationWidget> {
  bool _performanceDegradation = true;
  bool _errorSpikes = true;
  bool _securityConcerns = true;
  bool _storageWarnings = false;
  bool _apiFailures = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(3.w),
      children: [
        _buildAlertToggles(context),
        SizedBox(height: 2.h),
        _buildThresholdSettings(context),
        SizedBox(height: 2.h),
        _buildRecentAlerts(context),
        SizedBox(height: 2.h),
        _buildNotificationChannels(context),
      ],
    );
  }

  Widget _buildAlertToggles(BuildContext context) {
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
          Text(
            'Alert Types',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAlertToggle(
            context,
            title: 'Performance Degradation',
            subtitle: 'Alert when app performance drops below threshold',
            value: _performanceDegradation,
            onChanged: (value) {
              setState(() {
                _performanceDegradation = value;
              });
            },
          ),
          _buildAlertToggle(
            context,
            title: 'Error Spikes',
            subtitle: 'Alert when error rate increases significantly',
            value: _errorSpikes,
            onChanged: (value) {
              setState(() {
                _errorSpikes = value;
              });
            },
          ),
          _buildAlertToggle(
            context,
            title: 'Security Concerns',
            subtitle: 'Alert on security vulnerabilities or threats',
            value: _securityConcerns,
            onChanged: (value) {
              setState(() {
                _securityConcerns = value;
              });
            },
          ),
          _buildAlertToggle(
            context,
            title: 'Storage Warnings',
            subtitle: 'Alert when storage usage exceeds 80%',
            value: _storageWarnings,
            onChanged: (value) {
              setState(() {
                _storageWarnings = value;
              });
            },
          ),
          _buildAlertToggle(
            context,
            title: 'API Failures',
            subtitle: 'Alert when API success rate drops below 95%',
            value: _apiFailures,
            onChanged: (value) {
              setState(() {
                _apiFailures = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSettings(BuildContext context) {
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
          Text(
            'Threshold Settings',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildThresholdRow(context, 'Response Time', '> 500ms'),
          _buildThresholdRow(context, 'Error Rate', '> 5%'),
          _buildThresholdRow(context, 'Memory Usage', '> 200 MB'),
          _buildThresholdRow(context, 'Crash Rate', '> 0.1%'),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(
    BuildContext context,
    String metric,
    String threshold,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              Text(
                threshold,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.edit,
                size: 16.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlerts(BuildContext context) {
    final theme = Theme.of(context);

    final alerts = [
      {
        'title': 'API Response Time Warning',
        'time': '2 hours ago',
        'severity': 'warning',
      },
      {
        'title': 'Memory Usage Spike',
        'time': '5 hours ago',
        'severity': 'warning',
      },
      {
        'title': 'Security Scan Completed',
        'time': '1 day ago',
        'severity': 'info',
      },
    ];

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
          Text(
            'Recent Alerts',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...alerts.map(
            (alert) => _buildAlertItem(
              context,
              title: alert['title']!,
              time: alert['time']!,
              severity: alert['severity']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context, {
    required String title,
    required String time,
    required String severity,
  }) {
    final theme = Theme.of(context);
    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'warning':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(severityIcon, color: severityColor, size: 18.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationChannels(BuildContext context) {
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
          Text(
            'Notification Channels',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildChannelRow(
            context,
            Icons.notifications,
            'Push Notifications',
            true,
          ),
          _buildChannelRow(context, Icons.email, 'Email Alerts', true),
          _buildChannelRow(context, Icons.sms, 'SMS Alerts', false),
        ],
      ),
    );
  }

  Widget _buildChannelRow(
    BuildContext context,
    IconData icon,
    String label,
    bool enabled,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 18.sp),
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
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.grey,
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}
