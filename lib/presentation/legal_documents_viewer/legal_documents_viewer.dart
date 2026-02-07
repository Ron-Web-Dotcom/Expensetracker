import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/privacy_service.dart';
import 'file_saver.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

class LegalDocumentsViewer extends StatefulWidget {
  const LegalDocumentsViewer({Key? key}) : super(key: key);

  @override
  State<LegalDocumentsViewer> createState() => _LegalDocumentsViewerState();
}

class _LegalDocumentsViewerState extends State<LegalDocumentsViewer> {
  final _privacyService = PrivacyService();
  String _selectedDocument = 'privacy_policy';
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Legal & Privacy',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Document selector
          Container(
            padding: EdgeInsets.all(3.w),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: _buildDocumentTab('Privacy Policy', 'privacy_policy'),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildDocumentTab(
                    'Terms of Service',
                    'terms_of_service',
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildDocumentTab('Your Rights', 'user_rights'),
                ),
              ],
            ),
          ),

          // Document content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: _buildDocumentContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTab(String title, String documentId) {
    final isSelected = _selectedDocument == documentId;
    return GestureDetector(
      onTap: () => setState(() => _selectedDocument = documentId),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    switch (_selectedDocument) {
      case 'privacy_policy':
        return _buildPrivacyPolicy();
      case 'terms_of_service':
        return _buildTermsOfService();
      case 'user_rights':
        return _buildUserRights();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPrivacyPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Privacy Policy'),
        _buildVersionInfo('Version 1.0', 'Last Updated: January 2026'),
        SizedBox(height: 2.h),
        _buildSectionTitle('1. Information We Collect'),
        _buildParagraph(
          'ExpenseTracker collects and processes the following data locally on your device:',
        ),
        _buildBulletPoint(
          'Financial transaction data (expenses, income, budgets)',
        ),
        _buildBulletPoint('Receipt images captured or uploaded by you'),
        _buildBulletPoint('App preferences and settings'),
        _buildBulletPoint(
          'Biometric authentication data (stored securely on device)',
        ),
        SizedBox(height: 2.h),
        _buildSectionTitle('2. How We Use Your Data'),
        _buildParagraph(
          'All data is stored locally on your device with AES-256-GCM encryption. We use your data to:',
        ),
        _buildBulletPoint(
          'Provide expense tracking and budget management features',
        ),
        _buildBulletPoint('Generate financial analytics and insights'),
        _buildBulletPoint('Send reminders and notifications (if enabled)'),
        _buildBulletPoint('Improve app performance and fix crashes'),
        SizedBox(height: 2.h),
        _buildSectionTitle('3. Data Sharing'),
        _buildParagraph(
          'We do NOT share your personal data with third parties. Your financial data never leaves your device except:',
        ),
        _buildBulletPoint('Anonymous crash reports (via Firebase Crashlytics)'),
        _buildBulletPoint('When you explicitly export your data'),
        SizedBox(height: 2.h),
        _buildSectionTitle('4. Data Security'),
        _buildParagraph('We implement industry-standard security measures:'),
        _buildBulletPoint('AES-256-GCM encryption for all financial data'),
        _buildBulletPoint(
          'Biometric authentication (Face ID/Touch ID/Fingerprint)',
        ),
        _buildBulletPoint('Secure storage using platform-specific encryption'),
        _buildBulletPoint('Certificate pinning for future API communications'),
        SizedBox(height: 2.h),
        _buildSectionTitle('5. Your Rights'),
        _buildParagraph('Under GDPR and CCPA, you have the right to:'),
        _buildBulletPoint('Access your data (export feature)'),
        _buildBulletPoint('Delete your data (right to be forgotten)'),
        _buildBulletPoint('Withdraw consent at any time'),
        _buildBulletPoint('Request data portability'),
        SizedBox(height: 2.h),
        _buildSectionTitle('6. Contact Us'),
        _buildParagraph(
          'For privacy concerns or data requests, contact us at:\nsupport@expensetracker.com',
        ),
      ],
    );
  }

  Widget _buildTermsOfService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Terms of Service'),
        _buildVersionInfo('Version 1.0', 'Effective Date: January 2026'),
        SizedBox(height: 2.h),
        _buildSectionTitle('1. Acceptance of Terms'),
        _buildParagraph(
          'By using ExpenseTracker, you agree to these Terms of Service. If you do not agree, please do not use the app.',
        ),
        SizedBox(height: 2.h),
        _buildSectionTitle('2. Service Description'),
        _buildParagraph(
          'ExpenseTracker is a personal finance management application that helps you track expenses, manage budgets, and analyze spending patterns. All data is stored locally on your device.',
        ),
        SizedBox(height: 2.h),
        _buildSectionTitle('3. User Responsibilities'),
        _buildParagraph('You are responsible for:'),
        _buildBulletPoint('Maintaining the security of your device'),
        _buildBulletPoint('Keeping your biometric authentication secure'),
        _buildBulletPoint('Backing up your data regularly'),
        _buildBulletPoint('Using the app in compliance with applicable laws'),
        SizedBox(height: 2.h),
        _buildSectionTitle('4. Limitations of Liability'),
        _buildParagraph(
          'ExpenseTracker is provided "as is" without warranties. We are not liable for:',
        ),
        _buildBulletPoint('Data loss due to device failure or user error'),
        _buildBulletPoint('Financial decisions made based on app data'),
        _buildBulletPoint('Inaccuracies in OCR receipt scanning'),
        _buildBulletPoint('Service interruptions or bugs'),
        SizedBox(height: 2.h),
        _buildSectionTitle('5. Intellectual Property'),
        _buildParagraph(
          'All app content, design, and code are owned by ExpenseTracker. You may not copy, modify, or distribute the app without permission.',
        ),
        SizedBox(height: 2.h),
        _buildSectionTitle('6. Termination'),
        _buildParagraph(
          'You may stop using the app at any time. We reserve the right to terminate access for violations of these terms.',
        ),
        SizedBox(height: 2.h),
        _buildSectionTitle('7. Changes to Terms'),
        _buildParagraph(
          'We may update these terms periodically. Continued use of the app constitutes acceptance of updated terms.',
        ),
        SizedBox(height: 2.h),
        _buildSectionTitle('8. Governing Law'),
        _buildParagraph(
          'These terms are governed by the laws of your jurisdiction. Disputes will be resolved through binding arbitration.',
        ),
      ],
    );
  }

  Widget _buildUserRights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Your Privacy Rights'),
        _buildVersionInfo('GDPR & CCPA Compliance', 'Updated: January 2026'),
        SizedBox(height: 2.h),
        _buildSectionTitle('Data Export'),
        _buildParagraph(
          'Export all your data in JSON format for portability or backup purposes.',
        ),
        SizedBox(height: 1.h),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _handleExportData,
          icon: _isExporting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_isExporting ? 'Exporting...' : 'Export My Data'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 6.h),
          ),
        ),
        SizedBox(height: 3.h),
        _buildSectionTitle('Delete All Data'),
        _buildParagraph(
          'Permanently delete all your data from this device. This action cannot be undone.',
        ),
        SizedBox(height: 1.h),
        ElevatedButton.icon(
          onPressed: _isDeleting ? null : _handleDeleteData,
          icon: _isDeleting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_forever),
          label: Text(_isDeleting ? 'Deleting...' : 'Delete All My Data'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 6.h),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        SizedBox(height: 3.h),
        _buildSectionTitle('Your Rights Under GDPR'),
        _buildBulletPoint('Right to Access: View and export your data'),
        _buildBulletPoint('Right to Erasure: Delete all your data'),
        _buildBulletPoint(
          'Right to Portability: Export data in standard format',
        ),
        _buildBulletPoint('Right to Withdraw Consent: Stop data collection'),
        _buildBulletPoint('Right to Rectification: Correct inaccurate data'),
        SizedBox(height: 2.h),
        _buildSectionTitle('Your Rights Under CCPA'),
        _buildBulletPoint(
          'Right to Know: What data we collect and how we use it',
        ),
        _buildBulletPoint('Right to Delete: Request deletion of your data'),
        _buildBulletPoint(
          'Right to Opt-Out: Stop sale of personal data (we don\'t sell data)',
        ),
        _buildBulletPoint(
          'Right to Non-Discrimination: Equal service regardless of privacy choices',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildVersionInfo(String version, String date) {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              '$version • $date',
              style: TextStyle(
                fontSize: 11.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(text, style: TextStyle(fontSize: 12.sp, height: 1.5)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 12.sp)),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.sp, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportData() async {
    setState(() => _isExporting = true);
    try {
      final jsonData = await _privacyService.exportUserData();
      final fileName =
          'expensetracker_data_${DateTime.now().millisecondsSinceEpoch}.json';

      await saveFile(fileName, jsonData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _handleDeleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your expenses, budgets, receipts, and settings. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await _privacyService.deleteAllUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to onboarding
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
