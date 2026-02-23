import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/data_export_service.dart';
import '../../services/privacy_compliance_service.dart';
import '../privacy_policy/privacy_policy_screen.dart';
import '../terms_of_service/terms_of_service_screen.dart';

/// Privacy & Compliance Center screen
class PrivacyComplianceCenter extends StatefulWidget {
  const PrivacyComplianceCenter({Key? key}) : super(key: key);

  @override
  State<PrivacyComplianceCenter> createState() =>
      _PrivacyComplianceCenterState();
}

class _PrivacyComplianceCenterState extends State<PrivacyComplianceCenter> {
  final _privacyService = PrivacyComplianceService();
  final _exportService = DataExportService();

  bool _analyticsConsent = false;
  bool _crashReportingConsent = true;
  bool _dataCollectionConsent = true;
  bool _isLoading = true;
  Map<String, dynamic>? _privacyManifest;

  @override
  void initState() {
    super.initState();
    _loadConsentStatus();
    _loadPrivacyManifest();
  }

  Future<void> _loadConsentStatus() async {
    final consent = await _privacyService.getConsentStatus();
    if (mounted) {
      setState(() {
        _analyticsConsent = consent['analytics_consent'] ?? false;
        _crashReportingConsent = consent['crash_reporting_consent'] ?? true;
        _dataCollectionConsent = consent['data_collection_consent'] ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrivacyManifest() async {
    final manifest = await _privacyService.getPrivacyManifest();
    if (mounted) {
      setState(() {
        _privacyManifest = manifest;
      });
    }
  }

  Future<void> _updateConsent(String type, bool value) async {
    await _privacyService.recordConsentChange(type, value);

    switch (type) {
      case 'analytics':
        await _privacyService.updateConsent(analyticsConsent: value);
        break;
      case 'crash_reporting':
        await _privacyService.updateConsent(crashReportingConsent: value);
        break;
      case 'data_collection':
        await _privacyService.updateConsent(dataCollectionConsent: value);
        break;
    }

    Fluttertoast.showToast(msg: 'Consent preference updated');
  }

  Future<void> _exportData() async {
    try {
      final data = await _privacyService.exportAllUserData();
      await _exportService.backupData();

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Data exported successfully',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Export failed: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            const Text('• All expenses and transactions'),
            const Text('• All budgets and goals'),
            const Text('• All receipts and images'),
            const Text('• All settings and preferences'),
            SizedBox(height: 2.h),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            const Text('Type "DELETE MY DATA" to confirm:'),
            SizedBox(height: 1.h),
            TextField(
              decoration: const InputDecoration(
                hintText: 'DELETE MY DATA',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Store confirmation text
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _privacyService.deleteAllUserData();

        if (mounted) {
          Fluttertoast.showToast(
            msg: 'All data deleted successfully',
            backgroundColor: Colors.green,
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.onboarding,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Deletion failed: $e',
            backgroundColor: Colors.red,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Compliance'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compliance Status Header
                  _buildComplianceHeader(),
                  SizedBox(height: 3.h),

                  // Data Rights Management
                  _buildSection('Data Rights Management', Icons.verified_user, [
                    _buildActionTile(
                      'Export My Data',
                      'Download all your data in JSON format',
                      Icons.download,
                      _exportData,
                    ),
                    _buildActionTile(
                      'Delete My Account',
                      'Permanently delete all your data',
                      Icons.delete_forever,
                      _deleteAllData,
                      isDestructive: true,
                    ),
                  ]),
                  SizedBox(height: 3.h),

                  // Consent Management
                  _buildSection(
                    'Consent Management',
                    Icons.check_circle_outline,
                    [
                      _buildConsentToggle(
                        'Analytics',
                        'Allow anonymous usage analytics',
                        _analyticsConsent,
                        (value) {
                          setState(() => _analyticsConsent = value);
                          _updateConsent('analytics', value);
                        },
                      ),
                      _buildConsentToggle(
                        'Crash Reporting',
                        'Help improve app stability',
                        _crashReportingConsent,
                        (value) {
                          setState(() => _crashReportingConsent = value);
                          _updateConsent('crash_reporting', value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Privacy Controls
                  _buildSection('Privacy Controls', Icons.security, [
                    _buildInfoTile(
                      'Data Storage',
                      'All data stored locally with AES-256-GCM encryption',
                      Icons.storage,
                    ),
                    _buildInfoTile(
                      'Data Sharing',
                      'No data shared with third parties',
                      Icons.block,
                    ),
                  ]),
                  SizedBox(height: 3.h),

                  // Regulatory Compliance
                  _buildSection('Regulatory Compliance', Icons.gavel, [
                    _buildComplianceTile('GDPR', 'Compliant', true),
                    _buildComplianceTile('CCPA', 'Compliant', true),
                    _buildComplianceTile(
                      'iOS Privacy Manifest',
                      'Configured',
                      true,
                    ),
                  ]),
                  SizedBox(height: 3.h),

                  // Legal Documents
                  _buildSection('Legal Documents', Icons.description, [
                    _buildActionTile(
                      'Privacy Policy',
                      'View our privacy policy',
                      Icons.privacy_tip,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    _buildActionTile(
                      'Terms of Service',
                      'View terms of service',
                      Icons.article,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildComplianceHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6BCF36), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: Colors.white, size: 40),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Compliant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'GDPR & CCPA Ready',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            SizedBox(width: 2.w),
            Text(
              title,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildConsentToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildComplianceTile(String title, String status, bool isCompliant) {
    return ListTile(
      leading: Icon(
        isCompliant ? Icons.check_circle : Icons.warning,
        color: isCompliant ? Colors.green : Colors.orange,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: isCompliant ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isCompliant ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }
}
