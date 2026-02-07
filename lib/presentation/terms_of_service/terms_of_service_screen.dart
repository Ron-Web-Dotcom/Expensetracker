import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Terms of Service viewer screen
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ExpenseTracker Terms of Service',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 3.h),
            _buildSection(
              'Acceptance of Terms',
              'By downloading, installing, or using ExpenseTracker, you agree to be bound by these Terms of Service. '
                  'If you do not agree to these terms, please do not use the app.',
            ),
            _buildSection(
              'Description of Service',
              'ExpenseTracker is a personal finance management application that allows you to:\n\n'
                  '• Track expenses and income\n'
                  '• Manage budgets and financial goals\n'
                  '• Scan and store receipts\n'
                  '• Analyze spending patterns\n'
                  '• Set reminders and alerts\n\n'
                  'The app operates primarily offline with local data storage.',
            ),
            _buildSection(
              'User Responsibilities',
              'You agree to:\n\n'
                  '• Provide accurate financial information\n'
                  '• Maintain the security of your device and biometric authentication\n'
                  '• Use the app for lawful purposes only\n'
                  '• Not attempt to reverse engineer or modify the app\n'
                  '• Not use the app for commercial purposes without authorization\n'
                  '• Backup your data regularly',
            ),
            _buildSection(
              'Data Ownership',
              'You retain full ownership of all data you enter into ExpenseTracker. '
                  'We do not claim any rights to your financial information, receipts, or personal data. '
                  'You may export or delete your data at any time.',
            ),
            _buildSection(
              'Disclaimer of Warranties',
              'ExpenseTracker is provided "AS IS" without warranties of any kind. We do not guarantee:\n\n'
                  '• Uninterrupted or error-free operation\n'
                  '• Accuracy of calculations or analytics\n'
                  '• Compatibility with all devices\n'
                  '• Data backup or recovery\n\n'
                  'You are responsible for verifying all financial calculations and maintaining backups.',
            ),
            _buildSection(
              'Limitation of Liability',
              'To the maximum extent permitted by law, ExpenseTracker and its developers shall not be liable for:\n\n'
                  '• Loss of data or financial information\n'
                  '• Financial losses or decisions based on app data\n'
                  '• Damages resulting from app malfunction\n'
                  '• Unauthorized access to your device\n\n'
                  'Your use of the app is at your own risk.',
            ),
            _buildSection(
              'Intellectual Property',
              'ExpenseTracker, including its design, code, and features, is protected by copyright and intellectual property laws. '
                  'You may not copy, modify, distribute, or create derivative works without permission.',
            ),
            _buildSection(
              'Biometric Authentication',
              'If you enable biometric authentication (Face ID, Touch ID, fingerprint):\n\n'
                  '• You are responsible for managing enrolled biometrics on your device\n'
                  '• We do not store or transmit biometric data\n'
                  '• Biometric authentication uses device-native security features\n'
                  '• You should disable biometric access if your device security is compromised',
            ),
            _buildSection(
              'Receipt Scanning and OCR',
              'Receipt scanning uses optical character recognition (OCR) technology:\n\n'
                  '• OCR accuracy may vary based on image quality\n'
                  '• You should verify extracted data for accuracy\n'
                  '• Receipt images are stored locally and encrypted\n'
                  '• We are not responsible for OCR errors or misinterpretations',
            ),
            _buildSection(
              'Updates and Modifications',
              'We reserve the right to:\n\n'
                  '• Update the app with new features or bug fixes\n'
                  '• Modify these Terms of Service with notice\n'
                  '• Discontinue features or the app entirely\n\n'
                  'Continued use after updates constitutes acceptance of changes.',
            ),
            _buildSection(
              'Termination',
              'You may terminate your use of ExpenseTracker at any time by:\n\n'
                  '• Deleting the app from your device\n'
                  '• Requesting data deletion through Privacy & Compliance Center\n\n'
                  'We may terminate or suspend access if you violate these terms.',
            ),
            _buildSection(
              'Governing Law',
              'These Terms of Service are governed by applicable laws. '
                  'Any disputes shall be resolved through binding arbitration or in courts of competent jurisdiction.',
            ),
            _buildSection(
              'Contact Information',
              'For questions about these Terms of Service:\n\n'
                  'Email: support@expensetracker.app\n'
                  'Website: https://expensetracker.app/terms',
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
