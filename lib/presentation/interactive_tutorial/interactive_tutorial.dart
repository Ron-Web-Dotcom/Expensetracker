import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/tutorial_progress_widget.dart';
import './widgets/tutorial_step_widget.dart';

/// Interactive Tutorial - Contextual hands-on guidance with overlay coaching
class InteractiveTutorial extends StatefulWidget {
  const InteractiveTutorial({super.key});

  @override
  State<InteractiveTutorial> createState() => _InteractiveTutorialState();
}

class _InteractiveTutorialState extends State<InteractiveTutorial>
    with SingleTickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  bool _showOverlay = true;
  String _selectedSection = 'all';

  // Tutorial sections
  final List<Map<String, dynamic>> _tutorialSections = [
    {
      "id": "all",
      "title": "Complete Tutorial",
      "icon": "school",
      "color": Color(0xFF4CAF50),
      "stepCount": 12,
    },
    {
      "id": "expenses",
      "title": "Adding Expenses",
      "icon": "add_circle",
      "color": Color(0xFF2196F3),
      "stepCount": 4,
    },
    {
      "id": "budgets",
      "title": "Setting Budgets",
      "icon": "account_balance_wallet",
      "color": Color(0xFFFF9800),
      "stepCount": 3,
    },
    {
      "id": "analytics",
      "title": "Viewing Analytics",
      "icon": "insights",
      "color": Color(0xFF9C27B0),
      "stepCount": 3,
    },
    {
      "id": "receipts",
      "title": "Managing Receipts",
      "icon": "camera_alt",
      "color": Color(0xFFE91E63),
      "stepCount": 2,
    },
  ];

  // Tutorial steps for complete tutorial
  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      "title": "Welcome to ExpenseTracker",
      "description":
          "Let's take a quick tour of the app's main features. You'll learn how to track expenses, set budgets, and view analytics.",
      "icon": "waving_hand",
      "highlightArea": "none",
      "action": "Tap Next to begin",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a4214581-1767498401520.png",
      "semanticLabel":
          "Welcome screen with colorful expense tracking interface",
    },
    {
      "title": "Dashboard Overview",
      "description":
          "This is your main dashboard. Here you can see your monthly spending, recent transactions, and quick actions.",
      "icon": "dashboard",
      "highlightArea": "dashboard",
      "action": "Explore the dashboard",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_119b3721b-1770471763165.png",
      "semanticLabel":
          "Dashboard showing spending summary and transaction list",
    },
    {
      "title": "Add Your First Expense",
      "description":
          "Tap the green '+' button to add an expense. You can enter the amount, select a category, and attach a receipt photo.",
      "icon": "add_circle",
      "highlightArea": "add_button",
      "action": "Try adding an expense",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ce6bb00a-1766785973851.png",
      "semanticLabel":
          "Add expense screen with amount input and category selector",
    },
    {
      "title": "Choose a Category",
      "description":
          "Select from predefined categories like Food, Transportation, or Shopping. Categories help organize your spending.",
      "icon": "category",
      "highlightArea": "category_selector",
      "action": "Select a category",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f1f11e6b-1766610131969.png",
      "semanticLabel": "Category selection grid with colorful icons",
    },
    {
      "title": "Capture Receipt Photos",
      "description":
          "Use your camera to capture receipt photos. The app will automatically extract key information using OCR technology.",
      "icon": "camera_alt",
      "highlightArea": "camera_button",
      "action": "Take a photo",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1242923e8-1769035904229.png",
      "semanticLabel": "Camera interface capturing receipt with OCR overlay",
    },
    {
      "title": "Set Monthly Budgets",
      "description":
          "Create spending limits for each category. Visual progress rings show how much of your budget you've used.",
      "icon": "account_balance_wallet",
      "highlightArea": "budget_tab",
      "action": "Set a budget",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1546aed22-1766888236448.png",
      "semanticLabel": "Budget screen with circular progress indicators",
    },
    {
      "title": "Track Budget Progress",
      "description":
          "Monitor your spending in real-time. The app alerts you when you're approaching or exceeding budget limits.",
      "icon": "pie_chart",
      "highlightArea": "budget_progress",
      "action": "View progress",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1546aed22-1766888236448.png",
      "semanticLabel": "Budget progress chart with percentage indicators",
    },
    {
      "title": "View Spending Analytics",
      "description":
          "Discover spending patterns with interactive charts. See trends over time and identify areas to save money.",
      "icon": "trending_up",
      "highlightArea": "analytics_tab",
      "action": "Explore analytics",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f142a6b7-1767729425078.png",
      "semanticLabel": "Analytics dashboard with line graphs and bar charts",
    },
    {
      "title": "Transaction History",
      "description":
          "Access all your past transactions. Filter by date, category, or amount to find specific expenses quickly.",
      "icon": "history",
      "highlightArea": "history_tab",
      "action": "Browse history",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1fa463b57-1766849749855.png",
      "semanticLabel": "Transaction list with filter options and search bar",
    },
    {
      "title": "Export Reports",
      "description":
          "Generate CSV or PDF reports for tax preparation or expense reimbursement. Choose date ranges and categories.",
      "icon": "file_download",
      "highlightArea": "export_button",
      "action": "Export data",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e004d64d-1768726510236.png",
      "semanticLabel": "Export options screen with file format selection",
    },
    {
      "title": "Customize Settings",
      "description":
          "Personalize your experience with theme options, notification preferences, and currency settings.",
      "icon": "settings",
      "highlightArea": "settings",
      "action": "Adjust settings",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10e221d39-1767014223377.png",
      "semanticLabel": "Settings screen with customization options",
    },
    {
      "title": "You're All Set!",
      "description":
          "You've completed the tutorial! Start tracking your expenses and take control of your finances. You can replay this tutorial anytime from Settings.",
      "icon": "check_circle",
      "highlightArea": "none",
      "action": "Start using the app",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a910fd12-1768471616604.png",
      "semanticLabel": "Success screen with checkmark and celebration confetti",
    },
  ];

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('interactive_tutorial');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
      HapticFeedback.selectionClick();
      _analytics.trackEvent(
        'tutorial_step_completed',
        parameters: {'step': _currentStep},
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _skipTutorial() {
    HapticFeedback.lightImpact();
    _analytics.trackEvent(
      'tutorial_skipped',
      parameters: {'step': _currentStep},
    );
    Navigator.pop(context);
  }

  void _completeTutorial() {
    HapticFeedback.mediumImpact();
    _analytics.trackEvent('tutorial_completed');
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tutorial completed! You\'re ready to start tracking.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _restartTutorial() {
    setState(() {
      _currentStep = 0;
    });
    _animationController.reset();
    _animationController.forward();
    HapticFeedback.lightImpact();
    _analytics.trackEvent('tutorial_restarted');
  }

  void _selectSection(String sectionId) {
    setState(() {
      _selectedSection = sectionId;
      _currentStep = 0;
    });
    HapticFeedback.selectionClick();
    _analytics.trackEvent(
      'tutorial_section_selected',
      parameters: {'section': sectionId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentStepData = _tutorialSteps[_currentStep];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _skipTutorial,
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Interactive Tutorial',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: _restartTutorial,
                        icon: CustomIconWidget(
                          iconName: 'refresh',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress indicator
                TutorialProgressWidget(
                  currentStep: _currentStep,
                  totalSteps: _tutorialSteps.length,
                ),

                SizedBox(height: 2.h),

                // Tutorial step content
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: TutorialStepWidget(
                            stepData: currentStepData,
                            stepNumber: _currentStep + 1,
                            totalSteps: _tutorialSteps.length,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'arrow_back',
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Previous',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 3.w),
                      Expanded(
                        flex: _currentStep == 0 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep == _tutorialSteps.length - 1
                                    ? 'Complete'
                                    : 'Next',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName:
                                    _currentStep == _tutorialSteps.length - 1
                                    ? 'check_circle'
                                    : 'arrow_forward',
                                color: Colors.white,
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

          // Tutorial sections overlay (shown at start)
          if (_currentStep == 0 && _showOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOverlay = false;
                  });
                },
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Choose a Tutorial Section',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Or start with the complete tutorial',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            itemCount: _tutorialSections.length,
                            itemBuilder: (context, index) {
                              final section = _tutorialSections[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _selectSection(section['id']);
                                      setState(() {
                                        _showOverlay = false;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(3.w),
                                            decoration: BoxDecoration(
                                              color: (section['color'] as Color)
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: CustomIconWidget(
                                              iconName: section['icon'],
                                              color: section['color'] as Color,
                                              size: 32,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  section['title'],
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                SizedBox(height: 0.5.h),
                                                Text(
                                                  '${section['stepCount']} steps',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const CustomIconWidget(
                                            iconName: 'chevron_right',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showOverlay = false;
                              });
                            },
                            child: Text(
                              'Start Complete Tutorial',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
