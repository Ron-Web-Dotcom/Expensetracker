import 'package:flutter/material.dart';

import '../presentation/add_expense/add_expense.dart';
import '../presentation/analytics_admin_dashboard/analytics_admin_dashboard.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';
import '../presentation/biometric_authentication/biometric_authentication.dart';
import '../presentation/budget_management/budget_management.dart';
import '../presentation/expense_dashboard/expense_dashboard.dart';
import '../presentation/help_center/help_center.dart';
import '../presentation/interactive_tutorial/interactive_tutorial.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/performance_metrics_center/performance_metrics_center.dart';
import '../presentation/receipt_camera/receipt_camera_screen.dart';
import '../presentation/receipt_management/receipt_management.dart';
import '../presentation/smart_alerts_center/smart_alerts_center.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/transaction_history/transaction_history.dart';
import '../presentation/user_behavior_analytics/user_behavior_analytics.dart';
import '../presentation/user_guide_library/user_guide_library.dart';

class AppRoutes {
  static const String initial = splash;
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String biometricAuth = '/biometric-auth';
  static const String expenseDashboard = '/expense-dashboard';
  static const String addExpense = '/add-expense';
  static const String transactionHistory = '/transaction-history';
  static const String budgetManagement = '/budget-management';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String analyticsAdminDashboard = '/analytics-admin-dashboard';
  static const String userBehaviorAnalytics = '/user-behavior-analytics';
  static const String receiptCamera = '/receipt-camera';
  static const String receiptManagement = '/receipt-management';
  static const String helpCenter = '/help-center';
  static const String interactiveTutorial = '/interactive-tutorial';
  static const String userGuideLibrary = '/user-guide-library';
  static const String performanceMetricsCenter = '/performance-metrics-center';
  static const String smartAlertsCenter = '/smart-alerts-center';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingFlow(),
    biometricAuth: (context) => const BiometricAuthentication(),
    expenseDashboard: (context) => const ExpenseDashboard(),
    addExpense: (context) => const AddExpense(),
    transactionHistory: (context) => const TransactionHistory(),
    budgetManagement: (context) => const BudgetManagement(),
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    analyticsAdminDashboard: (context) => const AnalyticsAdminDashboard(),
    userBehaviorAnalytics: (context) => const UserBehaviorAnalytics(),
    receiptCamera: (context) => const ReceiptCameraScreen(),
    receiptManagement: (context) => const ReceiptManagement(),
    helpCenter: (context) => const HelpCenter(),
    interactiveTutorial: (context) => const InteractiveTutorial(),
    userGuideLibrary: (context) => const UserGuideLibrary(),
    performanceMetricsCenter: (context) => const PerformanceMetricsCenter(),
    smartAlertsCenter: (context) => const SmartAlertsCenter(),
  };

  /// Generate route with custom animations
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    final WidgetBuilder? builder = routes[routeName];

    if (builder != null) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation);

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          final scaleAnimation = Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).animate(curvedAnimation);

          final exitFadeAnimation = Tween<double>(
            begin: 1.0,
            end: 0.95,
          ).animate(secondaryAnimation);

          return FadeTransition(
            opacity: exitFadeAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: ScaleTransition(scale: scaleAnimation, child: child),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
      );
    }

    return null;
  }
}
