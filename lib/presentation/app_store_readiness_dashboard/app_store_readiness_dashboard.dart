import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// App Store Readiness Dashboard screen
class AppStoreReadinessDashboard extends StatefulWidget {
  const AppStoreReadinessDashboard({Key? key}) : super(key: key);

  @override
  State<AppStoreReadinessDashboard> createState() =>
      _AppStoreReadinessDashboardState();
}

class _AppStoreReadinessDashboardState
    extends State<AppStoreReadinessDashboard> {
  late Map<String, dynamic> _readinessData;
  int _overallScore = 0;

  @override
  void initState() {
    super.initState();
    _calculateReadiness();
  }

  void _calculateReadiness() {
    _readinessData = {
      'ios_privacy_manifest': {
        'status': 'completed',
        'items': [
          {'name': 'PrivacyInfo.xcprivacy created', 'completed': true},
          {'name': 'Data collection disclosed', 'completed': true},
          {'name': 'Required reason APIs declared', 'completed': true},
          {'name': 'Tracking domains configured', 'completed': true},
        ],
      },
      'crash_reporting': {
        'status': 'completed',
        'items': [
          {'name': 'Firebase Crashlytics integrated', 'completed': true},
          {'name': 'Error handlers configured', 'completed': true},
          {'name': 'Symbolication setup', 'completed': true},
          {'name': 'Platform-aware implementation', 'completed': true},
        ],
      },
      'app_metadata': {
        'status': 'warning',
        'items': [
          {'name': 'App description updated', 'completed': true},
          {'name': 'Screenshots prepared', 'completed': false},
          {'name': 'App icons generated', 'completed': false},
          {'name': 'Keywords selected', 'completed': false},
        ],
      },
      'privacy_compliance': {
        'status': 'completed',
        'items': [
          {'name': 'GDPR data export', 'completed': true},
          {'name': 'CCPA data deletion', 'completed': true},
          {'name': 'Consent management', 'completed': true},
          {'name': 'Privacy Policy created', 'completed': true},
          {'name': 'Terms of Service created', 'completed': true},
        ],
      },
      'release_configuration': {
        'status': 'warning',
        'items': [
          {'name': 'Android signing configured', 'completed': true},
          {'name': 'iOS Bundle ID set', 'completed': false},
          {'name': 'ProGuard enabled', 'completed': true},
          {'name': 'Build variants configured', 'completed': true},
        ],
      },
    };

    // Calculate overall score
    int totalItems = 0;
    int completedItems = 0;

    _readinessData.forEach((key, value) {
      final items = value['items'] as List;
      totalItems += items.length;
      completedItems += items.where((item) => item['completed'] == true).length;
    });

    setState(() {
      _overallScore = ((completedItems / totalItems) * 100).round();
    });
  }

  String _getCategoryStatus(String category) {
    final data = _readinessData[category];
    if (data == null) return 'unknown';
    return data['status'] as String;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Store Readiness'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Readiness Score
            _buildReadinessHeader(),
            SizedBox(height: 3.h),

            // Next Actions
            _buildNextActions(),
            SizedBox(height: 3.h),

            // Checklist Categories
            _buildChecklistSection(
              'iOS Privacy Manifest',
              'ios_privacy_manifest',
              Icons.shield,
            ),
            SizedBox(height: 2.h),

            _buildChecklistSection(
              'Crash Reporting Integration',
              'crash_reporting',
              Icons.bug_report,
            ),
            SizedBox(height: 2.h),

            _buildChecklistSection(
              'App Metadata',
              'app_metadata',
              Icons.description,
            ),
            SizedBox(height: 2.h),

            _buildChecklistSection(
              'Privacy Compliance',
              'privacy_compliance',
              Icons.verified_user,
            ),
            SizedBox(height: 2.h),

            _buildChecklistSection(
              'Release Configuration',
              'release_configuration',
              Icons.settings,
            ),
            SizedBox(height: 3.h),

            // Submission Preview
            _buildSubmissionPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessHeader() {
    final color = _overallScore >= 80
        ? Colors.green
        : _overallScore >= 60
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withAlpha(179)]),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Text(
            'Overall Readiness',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '$_overallScore%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: _overallScore / 100,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 1.h),
          Text(
            _overallScore >= 80
                ? 'Ready for submission'
                : _overallScore >= 60
                ? 'Almost ready - fix warnings'
                : 'Critical blockers present',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildNextActions() {
    final actions = [
      if (_overallScore < 100) 'Complete remaining checklist items',
      'Generate app screenshots (5-6 for iOS, 2-8 for Android)',
      'Create app icons for all required sizes',
      'Set iOS Bundle ID in Xcode',
      'Setup TestFlight for beta testing',
      'Configure Google Play internal testing',
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.blue),
              SizedBox(width: 2.w),
              Text(
                'Next Required Actions',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...actions
              .take(3)
              .map(
                (action) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 20, color: Colors.blue),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(action, style: TextStyle(fontSize: 12.sp)),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(
    String title,
    String categoryKey,
    IconData icon,
  ) {
    final status = _getCategoryStatus(categoryKey);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final items = _readinessData[categoryKey]['items'] as List;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: statusColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            SizedBox(width: 2.w),
            const Icon(Icons.expand_more),
          ],
        ),
        children: items.map((item) {
          final completed = item['completed'] as bool;
          return ListTile(
            leading: Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? Colors.green : Colors.grey,
            ),
            title: Text(
              item['name'],
              style: TextStyle(
                fontSize: 12.sp,
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed ? Colors.grey : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionPreview() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: Colors.purple),
              SizedBox(width: 2.w),
              Text(
                'Submission Preview',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildPreviewItem('App Name', 'ExpenseTracker'),
          _buildPreviewItem('Version', '1.0.0 (1)'),
          _buildPreviewItem('Bundle ID (iOS)', 'com.expensetracker.app'),
          _buildPreviewItem('Package Name (Android)', 'com.expensetracker.app'),
          _buildPreviewItem('Category', 'Finance'),
          _buildPreviewItem('Privacy Compliance', 'GDPR & CCPA Ready'),
          SizedBox(height: 2.h),
          Text(
            'Estimated Review Time:',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '• Apple App Store: 1-3 days',
            style: TextStyle(fontSize: 11.sp),
          ),
          Text(
            '• Google Play Store: 1-7 days',
            style: TextStyle(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}