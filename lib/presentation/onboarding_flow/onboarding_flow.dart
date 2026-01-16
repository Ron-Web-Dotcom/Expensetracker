import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/onboarding_page_widget.dart';

/// Onboarding flow screen that introduces new users to expense tracking concepts
/// Uses stack navigation with custom page indicator and gesture-based progression
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding pages data
  final List<Map<String, dynamic>> _onboardingPages = [
    {
      "title": "Track Every Expense",
      "description":
          "Quickly log expenses with camera capture and smart category selection. Your financial journey starts here.",
      "image": "https://images.unsplash.com/photo-1640757706590-dabcc7734f57",
      "semanticLabel":
          "Smartphone displaying expense tracking app with camera icon and colorful category buttons on screen",
      "primaryColor": Color(0xFF4CAF50),
      "features": [
        {"icon": "camera_alt", "text": "Camera Capture"},
        {"icon": "category", "text": "Smart Categories"},
        {"icon": "speed", "text": "Quick Entry"},
      ],
    },
    {
      "title": "Set Smart Budgets",
      "description":
          "Create spending limits with visual progress rings. Stay on track with real-time budget monitoring.",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1546aed22-1766888236448.png",
      "semanticLabel":
          "Circular progress chart showing budget allocation with colorful segments and percentage indicators",
      "primaryColor": Color(0xFF2196F3),
      "features": [
        {"icon": "account_balance_wallet", "text": "Budget Limits"},
        {"icon": "pie_chart", "text": "Visual Progress"},
        {"icon": "notifications_active", "text": "Smart Alerts"},
      ],
    },
    {
      "title": "Gain Financial Insights",
      "description":
          "Discover spending patterns with animated charts and trend visualizations. Make informed financial decisions.",
      "image": "https://images.unsplash.com/photo-1642751226315-e6dc6b47fd54",
      "semanticLabel":
          "Analytics dashboard with line graphs and bar charts showing financial trends and statistics",
      "primaryColor": Color(0xFFFF9800),
      "features": [
        {"icon": "trending_up", "text": "Trend Analysis"},
        {"icon": "insights", "text": "Smart Reports"},
        {"icon": "file_download", "text": "Export Data"},
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.selectionClick();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/expense-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _onboardingPages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingPages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    pageData: _onboardingPages[index],
                    isActive: _currentPage == index,
                  );
                },
              ),
            ),

            // Page indicator and navigation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                children: [
                  // Smooth page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingPages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor:
                          _onboardingPages[_currentPage]["primaryColor"]
                              as Color,
                      dotColor: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      dotHeight: 1.h,
                      dotWidth: 2.w,
                      expansionFactor: 3,
                      spacing: 1.w,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Navigation button
                  SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _onboardingPages[_currentPage]["primaryColor"]
                                as Color,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _onboardingPages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName:
                                _currentPage == _onboardingPages.length - 1
                                ? 'check_circle'
                                : 'arrow_forward',
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
