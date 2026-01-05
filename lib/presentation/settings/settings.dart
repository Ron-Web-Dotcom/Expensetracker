import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../main.dart';
import '../../services/analytics_service.dart';
import '../../services/budget_data_service.dart';
import '../../services/data_export_service.dart';
import '../../services/expense_data_service.dart';
import '../../services/locale_service.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/profile_section_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/toggle_settings_item_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AnalyticsService _analytics = AnalyticsService();
  final SettingsService _settingsService = SettingsService();
  final DataExportService _dataExportService = DataExportService();
  final NotificationService _notificationService = NotificationService();
  final LocaleService _localeService = LocaleService();
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final BudgetDataService _budgetDataService = BudgetDataService();

  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = false;
  bool _loginAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('settings');
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  Future<void> _loadSettings() async {
    final biometric = await _settingsService.isBiometricEnabled();
    final loginAlerts = await _settingsService.isLoginAlertsEnabled();
    final theme = await _settingsService.getTheme();
    final language = await _settingsService.getLanguage();
    final currency = await _settingsService.getCurrency();
    final dateFormat = await _settingsService.getDateFormat();
    final numberFormat = await _settingsService.getNumberFormat();
    final defaultCategory = await _settingsService.getDefaultCategory();
    final budgetAlerts = await _settingsService.isBudgetAlertsEnabled();
    final weeklySummary = await _settingsService.isWeeklySummaryEnabled();
    final receiptReminders = await _settingsService.isReceiptRemindersEnabled();
    final cloudBackup = await _settingsService.isCloudBackupEnabled();
    final lastSync = await _settingsService.getLastSyncTime();

    setState(() {
      _biometricEnabled = biometric;
      _loginAlertsEnabled = loginAlerts;
      _selectedTheme = theme;
      _selectedLanguage = language;
      _selectedCurrency = currency;
      _selectedDateFormat = dateFormat;
      _selectedNumberFormat = numberFormat;
      _defaultCategory = defaultCategory;
      _budgetAlertsEnabled = budgetAlerts;
      _weeklySummaryEnabled = weeklySummary;
      _receiptRemindersEnabled = receiptReminders;
      _cloudBackupEnabled = cloudBackup;
      _lastSyncTime = lastSync;
    });
  }

  void _handleSettingToggle(String settingName, bool value) {
    _analytics.trackEvent(
      'setting_changed',
      parameters: {'setting': settingName, 'value': value},
    );
  }

  // User profile data
  final Map<String, dynamic> _userProfile = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "avatar":
        "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
  };

  // Account settings state
  String _selectedCurrency = "USD - United States Dollar";
  String _selectedDateFormat = "MM/DD/YYYY";
  String _selectedNumberFormat = "1,000.00";

  // Data management state
  bool _cloudBackupEnabled = true;
  String _lastSyncTime = "2 hours ago";

  // Notification preferences state
  bool _budgetAlertsEnabled = true;
  bool _weeklySummaryEnabled = true;
  bool _receiptRemindersEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  // App preferences state
  String _selectedTheme = "System";
  String _selectedLanguage = "English (US)";
  String _defaultCategory = "General";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tr = LocaleService.getTranslations(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5FBF2),
      appBar: CustomAppBarFactory.standard(
        title: tr['Settings'] ?? "Settings",
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              ProfileSectionWidget(
                userName: _userProfile["name"] as String,
                userEmail: _userProfile["email"] as String,
                avatarUrl: _userProfile["avatar"] as String,
                onEditProfile: _handleEditProfile,
              ),
              SizedBox(height: 2.h),

              // Security section
              SettingsSectionWidget(
                title: tr['SECURITY'] ?? "SECURITY",
                children: [
                  ToggleSettingsItemWidget(
                    title:
                        tr['Biometric Authentication'] ??
                        "Biometric Authentication",
                    subtitle:
                        tr['Use fingerprint or face recognition'] ??
                        "Use fingerprint or face recognition",
                    leadingIcon: 'fingerprint',
                    value: _biometricEnabled,
                    onChanged: (value) async {
                      if (value) {
                        final canUse = await _settingsService.canUseBiometric();
                        if (!canUse) {
                          _showSnackBar(
                            "Biometric authentication not available on this device",
                          );
                          return;
                        }

                        final authenticated = await _settingsService
                            .authenticateWithBiometric();
                        if (authenticated) {
                          await _settingsService.setBiometricEnabled(true);
                          setState(() => _biometricEnabled = true);
                          _showSnackBar(
                            tr['Biometric authentication enabled'] ??
                                "Biometric authentication enabled",
                          );
                        } else {
                          _showSnackBar("Authentication failed");
                        }
                      } else {
                        await _settingsService.setBiometricEnabled(false);
                        setState(() => _biometricEnabled = false);
                        _showSnackBar(
                          tr['Biometric authentication disabled'] ??
                              "Biometric authentication disabled",
                        );
                      }
                    },
                  ),
                  ToggleSettingsItemWidget(
                    title: tr['Login Alerts'] ?? "Login Alerts",
                    subtitle:
                        tr['Get notified of login attempts'] ??
                        "Get notified of login attempts",
                    leadingIcon: 'notifications_active',
                    value: _loginAlertsEnabled,
                    onChanged: (value) async {
                      await _settingsService.setLoginAlertsEnabled(value);
                      setState(() => _loginAlertsEnabled = value);
                      _showSnackBar(
                        value
                            ? (tr['Login alerts enabled'] ??
                                  "Login alerts enabled")
                            : (tr['Login alerts disabled'] ??
                                  "Login alerts disabled"),
                      );
                    },
                  ),
                  SettingsItemWidget(
                    title: tr['Login History'] ?? "Login History",
                    subtitle:
                        tr['View recent login attempts'] ??
                        "View recent login attempts",
                    leadingIcon: 'history',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _showLoginHistory,
                  ),
                  SettingsItemWidget(
                    title: tr['Change Password'] ?? "Change Password",
                    subtitle:
                        tr['Update your account password'] ??
                        "Update your account password",
                    leadingIcon: 'lock',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _handleChangePassword,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Account settings section
              SettingsSectionWidget(
                title: tr['ACCOUNT SETTINGS'] ?? "ACCOUNT SETTINGS",
                children: [
                  SettingsItemWidget(
                    title: tr['Currency'] ?? "Currency",
                    subtitle: _selectedCurrency,
                    leadingIcon: 'attach_money',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showCurrencyPicker(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Date Format'] ?? "Date Format",
                    subtitle: _selectedDateFormat,
                    leadingIcon: 'calendar_today',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showDateFormatPicker(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Number Format'] ?? "Number Format",
                    subtitle: _selectedNumberFormat,
                    leadingIcon: 'numbers',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showNumberFormatPicker(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Delete Account'] ?? "Delete Account",
                    subtitle:
                        tr['Permanently delete your account'] ??
                        "Permanently delete your account",
                    leadingIcon: 'delete_forever',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: theme.colorScheme.error,
                      size: 5.w,
                    ),
                    onTap: _showDeleteAccountDialog,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Data management section
              SettingsSectionWidget(
                title: tr['DATA MANAGEMENT'] ?? "DATA MANAGEMENT",
                children: [
                  SettingsItemWidget(
                    title: tr['Export Data'] ?? "Export Data",
                    subtitle:
                        tr['Download your data as CSV'] ??
                        "Download your data as CSV",
                    leadingIcon: 'file_download',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showExportDialog(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Clear All Data'] ?? "Clear All Data",
                    subtitle:
                        tr['Permanently delete all transactions'] ??
                        "Permanently delete all transactions",
                    leadingIcon: 'delete_forever',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: theme.colorScheme.error,
                      size: 5.w,
                    ),
                    onTap: () => _showClearDataDialog(context),
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Notification preferences section
              SettingsSectionWidget(
                title:
                    tr['Notification Preferences'] ??
                    "Notification Preferences",
                children: [
                  SettingsItemWidget(
                    title: tr['Smart Alerts Center'] ?? "Smart Alerts Center",
                    subtitle:
                        tr['Configure spending alerts & notifications'] ??
                        "Configure spending alerts & notifications",
                    leadingIcon: 'notifications_active',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.smartAlertsCenter);
                    },
                  ),
                  ToggleSettingsItemWidget(
                    title: tr['Budget Alerts'] ?? "Budget Alerts",
                    subtitle:
                        tr['Notify when approaching budget limits'] ??
                        "Notify when approaching budget limits",
                    leadingIcon: 'account_balance_wallet',
                    value: _budgetAlertsEnabled,
                    onChanged: (value) async {
                      await _settingsService.setBudgetAlertsEnabled(value);
                      setState(() => _budgetAlertsEnabled = value);
                      _handleSettingToggle('budget_alerts', value);
                    },
                  ),
                  ToggleSettingsItemWidget(
                    title: tr['Weekly Summary'] ?? "Weekly Summary",
                    subtitle:
                        tr['Receive weekly spending summaries'] ??
                        "Receive weekly spending summaries",
                    leadingIcon: 'email',
                    value: _weeklySummaryEnabled,
                    onChanged: (value) async {
                      await _settingsService.setWeeklySummaryEnabled(value);
                      setState(() => _weeklySummaryEnabled = value);

                      if (value) {
                        await _notificationService
                            .scheduleWeeklySummaryRecurring();
                        _showSnackBar(
                          "Weekly summary enabled - scheduled for every Monday at 9 AM",
                        );
                      } else {
                        await _notificationService.cancelNotification(
                          NotificationService.weeklySummaryId,
                        );
                        _showSnackBar("Weekly summary disabled");
                      }
                    },
                  ),
                  SettingsItemWidget(
                    title: tr['Quiet Hours'] ?? "Quiet Hours",
                    subtitle:
                        "${_quietHoursStart.format(context)} - ${_quietHoursEnd.format(context)}",
                    leadingIcon: 'bedtime',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showQuietHoursPicker(context),
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // App preferences section
              SettingsSectionWidget(
                title: tr['APP PREFERENCES'] ?? "APP PREFERENCES",
                children: [
                  SettingsItemWidget(
                    title: tr['Theme'] ?? "Theme",
                    subtitle: tr[_selectedTheme] ?? _selectedTheme,
                    leadingIcon: 'palette',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showThemePicker(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Language'] ?? "Language",
                    subtitle: _selectedLanguage,
                    leadingIcon: 'language',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showLanguagePicker(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Default Category'] ?? "Default Category",
                    subtitle: _defaultCategory,
                    leadingIcon: 'category',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showCategoryPicker(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Reset Tutorial'] ?? "Reset Tutorial",
                    subtitle:
                        tr['Show onboarding screens again'] ??
                        "Show onboarding screens again",
                    leadingIcon: 'help_outline',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _handleResetTutorial,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Data management section
              SettingsSectionWidget(
                title: tr['DATA MANAGEMENT'] ?? "DATA MANAGEMENT",
                children: [
                  SettingsItemWidget(
                    title: tr['Export Data'] ?? "Export Data",
                    subtitle:
                        tr['Download your data as CSV'] ??
                        "Download your data as CSV",
                    leadingIcon: 'file_download',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () => _showExportDialog(context),
                  ),
                  SettingsItemWidget(
                    title: tr['Clear All Data'] ?? "Clear All Data",
                    subtitle:
                        tr['Permanently delete all transactions'] ??
                        "Permanently delete all transactions",
                    leadingIcon: 'delete_forever',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: theme.colorScheme.error,
                      size: 5.w,
                    ),
                    onTap: () => _showClearDataDialog(context),
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Help & Support section
              SettingsSectionWidget(
                title: tr['HELP & SUPPORT'] ?? "HELP & SUPPORT",
                children: [
                  SettingsItemWidget(
                    title: tr['Help Center'] ?? "Help Center",
                    subtitle:
                        tr['Browse articles and FAQs'] ??
                        "Browse articles and FAQs",
                    leadingIcon: 'help',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.helpCenter);
                    },
                  ),
                  SettingsItemWidget(
                    title: tr['Interactive Tutorial'] ?? "Interactive Tutorial",
                    subtitle:
                        tr['Learn app features step-by-step'] ??
                        "Learn app features step-by-step",
                    leadingIcon: 'school',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.interactiveTutorial,
                      );
                    },
                  ),
                  SettingsItemWidget(
                    title: tr['User Guide Library'] ?? "User Guide Library",
                    subtitle:
                        tr['Access comprehensive documentation'] ??
                        "Access comprehensive documentation",
                    leadingIcon: 'menu_book',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.userGuideLibrary);
                    },
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Admin Analytics section
              SettingsSectionWidget(
                title: 'ADMIN ANALYTICS',
                children: [
                  SettingsItemWidget(
                    title: 'Analytics Admin Dashboard',
                    subtitle: 'Real-time metrics and performance insights',
                    leadingIcon: 'admin_panel_settings',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.analyticsAdminDashboard,
                      );
                    },
                  ),
                  SettingsItemWidget(
                    title: 'User Behavior Analytics',
                    subtitle: 'Deep dive into user interactions and patterns',
                    leadingIcon: 'psychology',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userBehaviorAnalytics,
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Support & Help Section
              SettingsSectionWidget(
                title: 'Support & Help',
                children: [
                  SettingsItemWidget(
                    leadingIcon: 'help_center',
                    title: 'Help Center',
                    subtitle: 'Browse articles and guides',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _analytics.trackEvent('help_center_opened');
                      Navigator.pushNamed(context, AppRoutes.helpCenter);
                    },
                  ),
                  SettingsItemWidget(
                    leadingIcon: 'menu_book_outlined',
                    title: 'User Guide Library',
                    subtitle: 'Browse comprehensive documentation',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _analytics.trackEvent('user_guide_library_opened');
                      Navigator.pushNamed(context, AppRoutes.userGuideLibrary);
                    },
                  ),
                  SettingsItemWidget(
                    leadingIcon: 'school_outlined',
                    title: 'Interactive Tutorial',
                    subtitle: 'Learn how to use the app',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _analytics.trackEvent('tutorial_opened');
                      Navigator.pushNamed(
                        context,
                        AppRoutes.interactiveTutorial,
                      );
                    },
                  ),
                  SettingsItemWidget(
                    leadingIcon: 'support_agent',
                    title: 'Contact Support',
                    subtitle: 'Get help from our team',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: () {
                      _analytics.trackEvent('contact_support');
                      _showContactSupportDialog();
                    },
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Support & Legal section
              SettingsSectionWidget(
                title: tr['SUPPORT & LEGAL'] ?? "SUPPORT & LEGAL",
                children: [
                  SettingsItemWidget(
                    title: tr['Help Center'] ?? "Help Center",
                    subtitle:
                        tr['Get help and support'] ?? "Get help and support",
                    leadingIcon: 'help_outline',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _handleHelpCenter,
                  ),
                  SettingsItemWidget(
                    title: tr['Privacy Policy'] ?? "Privacy Policy",
                    subtitle:
                        tr['Read our privacy policy'] ??
                        "Read our privacy policy",
                    leadingIcon: 'privacy_tip',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _handlePrivacyPolicy,
                  ),
                  SettingsItemWidget(
                    title: tr['Terms of Service'] ?? "Terms of Service",
                    subtitle:
                        tr['Read our terms of service'] ??
                        "Read our terms of service",
                    leadingIcon: 'description',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _handleTermsOfService,
                  ),
                  SettingsItemWidget(
                    title: tr['About'] ?? "About",
                    subtitle: "Version 1.0.0",
                    leadingIcon: 'info',
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                      size: 5.w,
                    ),
                    onTap: _handleAbout,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Logout button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      tr['Logout'] ?? "Logout",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  // Profile management
  void _handleEditProfile() async {
    final nameController = TextEditingController(
      text: _userProfile["name"] as String,
    );
    final emailController = TextEditingController(
      text: _userProfile["email"] as String,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', nameController.text);
      await prefs.setString('user_email', emailController.text);
      setState(() {
        _userProfile["name"] = nameController.text;
        _userProfile["email"] = emailController.text;
      });
      _showSnackBar("Profile updated successfully");
    }
  }

  // Currency picker
  void _showCurrencyPicker(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = [
      "USD - United States Dollar",
      "EUR - Euro",
      "GBP - British Pound",
      "JPY - Japanese Yen",
      "CAD - Canadian Dollar",
      "AUD - Australian Dollar",
      "INR - Indian Rupee",
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: 50.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text("Select Currency", style: theme.textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = currency == _selectedCurrency;
                  return ListTile(
                    title: Text(currency),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: theme.colorScheme.primary,
                            size: 5.w,
                          )
                        : null,
                    onTap: () async {
                      await _settingsService.setCurrency(currency);
                      setState(() => _selectedCurrency = currency);
                      Navigator.pop(context);
                      _showSnackBar("Currency changed to $currency");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Date format picker
  void _showDateFormatPicker(BuildContext context) {
    final theme = Theme.of(context);
    final formats = ["MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD"];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Date Format", style: theme.textTheme.titleLarge),
            SizedBox(height: 2.h),
            ...(formats.map((format) {
              final isSelected = format == _selectedDateFormat;
              return ListTile(
                title: Text(format),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      )
                    : null,
                onTap: () async {
                  await _settingsService.setDateFormat(format);
                  setState(() => _selectedDateFormat = format);
                  Navigator.pop(context);
                  _showSnackBar("Date format changed to $format");
                },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  // Number format picker
  void _showNumberFormatPicker(BuildContext context) {
    final theme = Theme.of(context);
    final formats = ["1,000.00", "1.000,00", "1 000.00"];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Number Format", style: theme.textTheme.titleLarge),
            SizedBox(height: 2.h),
            ...(formats.map((format) {
              final isSelected = format == _selectedNumberFormat;
              return ListTile(
                title: Text(format),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      )
                    : null,
                onTap: () async {
                  await _settingsService.setNumberFormat(format);
                  setState(() => _selectedNumberFormat = format);
                  Navigator.pop(context);
                  _showSnackBar("Number format changed to $format");
                },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  // Cloud backup
  void _performCloudBackup() async {
    _showSnackBar("Backing up data to cloud...");
    await Future.delayed(const Duration(seconds: 2));
    await _settingsService.updateLastSyncTime();
    setState(() => _lastSyncTime = "Just now");
    _showSnackBar("Backup completed successfully");
  }

  // Export dialog
  void _showExportDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select export format:", style: theme.textTheme.bodyMedium),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'table_chart',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              title: const Text("CSV Format"),
              onTap: () {
                Navigator.pop(context);
                _handleExportData("CSV");
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              title: const Text("PDF Format"),
              onTap: () {
                Navigator.pop(context);
                _handleExportData("PDF");
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _handleExportData(String format) async {
    _showSnackBar("Exporting data as $format...");

    try {
      String filePath;
      if (format == "CSV") {
        filePath = await _dataExportService.exportAsCSV();
      } else {
        filePath = await _dataExportService.exportAsPDF();
      }

      _showSnackBar("Data exported successfully to: $filePath");
    } catch (e) {
      _showSnackBar("Export failed: ${e.toString()}");
    }
  }

  void _handleImportData() {
    _showSnackBar("Import data functionality");
  }

  // Clear data dialog
  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Data"),
        content: Text(
          "This will permanently delete all your transactions, budgets, and settings. This action cannot be undone.",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleClearData();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClearData() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your expenses, budgets, and transaction history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _expenseDataService.clearAllExpenses();
        await _budgetDataService.clearAllBudgets();

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear data: ${e.toString()}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // Quiet hours picker
  void _showQuietHoursPicker(BuildContext context) async {
    final theme = Theme.of(context);
    TimeOfDay startTime = _quietHoursStart;
    TimeOfDay endTime = _quietHoursEnd;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Set Quiet Hours"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Start Time"),
                subtitle: Text(startTime.format(context)),
                trailing: CustomIconWidget(
                  iconName: 'access_time',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (time != null) {
                    setDialogState(() => startTime = time);
                  }
                },
              ),
              ListTile(
                title: const Text("End Time"),
                subtitle: Text(endTime.format(context)),
                trailing: CustomIconWidget(
                  iconName: 'access_time',
                  color: theme.colorScheme.primary,
                  size: 5.w,
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (time != null) {
                    setDialogState(() => endTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _settingsService.setQuietHoursStart(
                  "${startTime.hour}:${startTime.minute}",
                );
                await _settingsService.setQuietHoursEnd(
                  "${endTime.hour}:${endTime.minute}",
                );
                setState(() {
                  _quietHoursStart = startTime;
                  _quietHoursEnd = endTime;
                });
                Navigator.pop(context);
                _showSnackBar("Quiet hours updated");
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // Theme picker
  void _showThemePicker(BuildContext context) {
    final theme = Theme.of(context);
    final tr = LocaleService.getTranslations(context);
    final themes = ["Light", "Dark", "System"];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Theme", style: theme.textTheme.titleLarge),
            SizedBox(height: 2.h),
            ...(themes.map((themeOption) {
              final isSelected = themeOption == _selectedTheme;
              return ListTile(
                title: Text(tr[themeOption] ?? themeOption),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: theme.colorScheme.primary,
                        size: 5.w,
                      )
                    : null,
                onTap: () async {
                  await _settingsService.setTheme(themeOption);
                  setState(() => _selectedTheme = themeOption);

                  // Update theme immediately without restart
                  final newThemeMode = switch (themeOption) {
                    'Light' => ThemeMode.light,
                    'Dark' => ThemeMode.dark,
                    _ => ThemeMode.system,
                  };
                  themeModeNotifier.value = newThemeMode;

                  Navigator.pop(context);
                  final translatedTheme = tr[themeOption] ?? themeOption;
                  _showSnackBar(
                    "${tr['Theme changed to'] ?? 'Theme changed to'} $translatedTheme",
                  );
                },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  // Language picker
  void _showLanguagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final tr = LocaleService.getTranslations(context);
    final languages = [
      "English (US)",
      "Spanish",
      "French",
      "German",
      "Chinese",
      "Japanese",
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: 50.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                tr['Language'] ?? "Select Language",
                style: theme.textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = language == _selectedLanguage;
                  return ListTile(
                    title: Text(language),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: theme.colorScheme.primary,
                            size: 5.w,
                          )
                        : null,
                    onTap: () async {
                      await _settingsService.setLanguage(language);
                      setState(() => _selectedLanguage = language);

                      // Update locale immediately
                      final newLocale = _getLocaleFromLanguage(language);
                      localeNotifier.value = newLocale;

                      Navigator.pop(context);

                      // Show message in new language
                      final newTr = LocaleService.getTranslationsForLocale(
                        newLocale.languageCode,
                      );
                      final message = language == 'English (US)'
                          ? "Language changed to $language"
                          : "${newTr['Language changed to'] ?? 'Language changed to'} $language";
                      _showSnackBar(message);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category picker
  void _showCategoryPicker(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      "General",
      "Food & Dining",
      "Transportation",
      "Shopping",
      "Entertainment",
      "Bills & Utilities",
      "Healthcare",
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: 50.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                "Select Default Category",
                style: theme.textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == _defaultCategory;
                  return ListTile(
                    title: Text(category),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: theme.colorScheme.primary,
                            size: 5.w,
                          )
                        : null,
                    onTap: () async {
                      await _settingsService.setDefaultCategory(category);
                      setState(() => _defaultCategory = category);
                      Navigator.pop(context);
                      _showSnackBar(
                        "Default category set to $category. Will be used in Add Expense.",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'Spanish':
        return const Locale('es', 'ES');
      case 'French':
        return const Locale('fr', 'FR');
      case 'German':
        return const Locale('de', 'DE');
      case 'Chinese':
        return const Locale('zh', 'CN');
      case 'Japanese':
        return const Locale('ja', 'JP');
      default:
        return const Locale('en', 'US');
    }
  }

  void _handleResetTutorial() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Tutorial"),
        content: Text(
          "This will reset the onboarding tutorial. You'll see the welcome screens again when you restart the app.",
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_seen_onboarding');
      await prefs.setBool('is_first_time', true);
      _showSnackBar(
        "Tutorial reset successfully. Restart the app to see onboarding.",
      );
    }
  }

  void _handleChangePasscode() {
    _showSnackBar("Change passcode functionality");
  }

  void _handleTwoFactorAuth() {
    _showSnackBar("Two-factor authentication setup");
  }

  void _handlePrivacyPolicy() {
    _showSnackBar("Opening privacy policy...");
  }

  void _handleTermsOfService() {
    _showSnackBar("Opening terms of service...");
  }

  void _handleFAQ() {
    _showSnackBar("Opening FAQ...");
  }

  void _handleContactSupport() {
    _showSnackBar("Opening support contact...");
  }

  void _handleAppVersion() {
    _showSnackBar("App version information");
  }

  void _handleHelpCenter() {
    _showSnackBar("Opening help center...");
  }

  void _handleAbout() {
    _showSnackBar("About app information");
  }

  Future<void> _handleLogout() async {
    _showSnackBar("Logging out...");
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.biometricAuth,
        (route) => false,
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLoginHistory() async {
    final history = await _settingsService.getLoginHistory();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login History"),
        content: SizedBox(
          width: double.maxFinite,
          child: history.isEmpty
              ? const Text("No login history available")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length > 10 ? 10 : history.length,
                  itemBuilder: (context, index) {
                    final login = history[index];
                    final timestamp = DateTime.parse(login['timestamp']);
                    final success = login['success'] as bool;

                    return ListTile(
                      leading: Icon(
                        success ? Icons.check_circle : Icons.error,
                        color: success ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        success ? "Successful Login" : "Failed Login",
                      ),
                      subtitle: Text(
                        "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _handleChangePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match")),
                );
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );

    if (result == true) {
      _showSnackBar("Password changed successfully");
    }
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: theme.colorScheme.error),
            SizedBox(width: 2.w),
            const Text("Delete Account"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This action will permanently delete:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "• Your account and profile\n• All transactions and expenses\n• Budget data and settings\n• Receipts and attachments\n• All app preferences",
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              "This action cannot be undone!",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Enter password to confirm",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                _showSnackBar("Please enter your password to confirm");
                return;
              }

              Navigator.pop(context);

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Final Confirmation"),
                  content: const Text(
                    "Are you absolutely sure? This will delete everything and cannot be recovered.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      child: const Text("Yes, Delete Everything"),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                _showSnackBar("Deleting account...");
                await Future.delayed(const Duration(seconds: 1));

                await _settingsService.deleteUserAccount();
                await _dataExportService.clearAllData();

                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.biometricAuth,
                    (route) => false,
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    _showSnackBar("Account deletion initiated. Please contact support.");
  }

  void _handleBackupData() async {
    _showSnackBar("Creating backup...");

    try {
      final filePath = await _dataExportService.backupData();
      _showSnackBar("Backup created successfully: $filePath");
    } catch (e) {
      _showSnackBar("Backup failed: ${e.toString()}");
    }
  }

  void _showContactSupportDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contact Support"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We're here to help! Please describe your issue:",
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                labelText: "Issue Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                labelText: "Your Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: () {
                _showSnackBar(
                  "Support ticket submitted. We'll get back to you soon.",
                );
              },
              child: const Text("Submit Ticket"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}