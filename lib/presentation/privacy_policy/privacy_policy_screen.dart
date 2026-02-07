import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Privacy Policy viewer screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ExpenseTracker Privacy Policy',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 3.h),
            _buildSection(
              'Introduction',
              'ExpenseTracker ("we", "our", or "us") is committed to protecting your privacy. '
                  'This Privacy Policy explains how we collect, use, and safeguard your personal information '
                  'when you use our mobile application.',
            ),
            _buildSection(
              'Information We Collect',
              '• Financial Information: Expense amounts, categories, descriptions, dates, and payment methods you enter\n'
                  '• Photos: Receipt images you capture or upload for expense tracking\n'
                  '• Usage Data: App interactions, feature usage, and analytics data\n'
                  '• Device Information: Device type, operating system, and app version\n\n'
                  'All data is stored locally on your device and encrypted using AES-256-GCM encryption.',
            ),
            _buildSection(
              'How We Use Your Information',
              '• To provide expense tracking and budget management functionality\n'
                  '• To generate analytics and spending insights\n'
                  '• To send reminders and alerts based on your preferences\n'
                  '• To improve app performance and user experience\n\n'
                  'We do NOT transmit your financial data to external servers.',
            ),
            _buildSection(
              'Data Storage and Security',
              '• All data is stored locally on your device\n'
                  '• Financial data is encrypted using AES-256-GCM encryption\n'
                  '• iOS backups use NSFileProtectionComplete for secure backup\n'
                  '• Biometric authentication protects app access\n'
                  '• We implement certificate pinning for future API communications',
            ),
            _buildSection(
              'Third-Party Services',
              'We use the following third-party services:\n\n'
                  '• Firebase Crashlytics: For crash reporting (optional, requires consent)\n'
                  '• Google Fonts: For typography (no personal data collected)\n\n'
                  'We do NOT share your financial data with any third parties.',
            ),
            _buildSection(
              'Your Privacy Rights (GDPR/CCPA)',
              '• Right to Access: Export all your data in JSON format\n'
                  '• Right to Erasure: Delete all your data permanently\n'
                  '• Right to Rectification: Edit or correct your data anytime\n'
                  '• Right to Data Portability: Export data in machine-readable format\n'
                  '• Right to Withdraw Consent: Disable analytics and crash reporting\n\n'
                  'Access these rights in Settings > Privacy & Compliance Center.',
            ),
            _buildSection(
              'Data Retention',
              'Your data is retained on your device until you:\n'
                  '• Delete the app\n'
                  '• Request data deletion through the Privacy & Compliance Center\n'
                  '• Clear app data through device settings',
            ),
            _buildSection(
              'Children\'s Privacy',
              'ExpenseTracker is not intended for users under 13 years of age. '
                  'We do not knowingly collect personal information from children.',
            ),
            _buildSection(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. '
                  'We will notify you of significant changes through the app. '
                  'Continued use of the app after changes constitutes acceptance of the updated policy.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: privacy@expensetracker.app\n'
                  'Website: https://expensetracker.app/privacy',
            ),
            SizedBox(height: 3.h),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Text(content, style: TextStyle(fontSize: 13.sp, height: 1.5)),
        ],
      ),
    );
  }
}
