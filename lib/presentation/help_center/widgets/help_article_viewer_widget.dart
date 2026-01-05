import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';

class HelpArticleViewer extends StatefulWidget {
  final Map<String, dynamic> article;

  const HelpArticleViewer({super.key, required this.article});

  @override
  State<HelpArticleViewer> createState() => _HelpArticleViewerState();
}

class _HelpArticleViewerState extends State<HelpArticleViewer> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _isHelpful = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll) : 0.0;
      });
    }
  }

  Map<String, dynamic> _getArticleContent() {
    final title = widget.article['title'] as String;

    if (title.contains('first expense')) {
      return {
        'sections': [
          {
            'title': 'Step 1: Open Add Expense Screen',
            'content':
                'Tap the "+" button in the bottom navigation bar to open the Add Expense screen. This is your main entry point for recording all transactions.',
          },
          {
            'title': 'Step 2: Enter Amount',
            'content':
                'Enter the expense amount using the numeric keypad. The amount field is the first and most important piece of information for tracking your spending.',
          },
          {
            'title': 'Step 3: Select Category',
            'content':
                'Choose the appropriate category for your expense (e.g., Food, Transport, Shopping). Categories help you understand where your money goes.',
          },
          {
            'title': 'Step 4: Add Details (Optional)',
            'content':
                'Add a description, select payment method, attach a receipt photo, or add location information. These details make it easier to review expenses later.',
          },
          {
            'title': 'Step 5: Save Transaction',
            'content':
                'Tap the "Save" button to record your expense. You\'ll see a confirmation and the expense will appear in your transaction history immediately.',
          },
        ],
        'tips': [
          'Use the camera feature to capture receipts instantly',
          'Add descriptions to remember what you bought',
          'Review your expenses daily for better tracking',
        ],
      };
    } else if (title.contains('categories')) {
      return {
        'sections': [
          {
            'title': 'What Are Expense Categories?',
            'content':
                'Categories are labels that help you organize your spending into meaningful groups. ExpenseTracker provides default categories like Food, Transport, Shopping, Bills, and Entertainment.',
          },
          {
            'title': 'Why Use Categories?',
            'content':
                'Categories allow you to see spending patterns, set budgets for specific areas, and understand where most of your money goes each month.',
          },
          {
            'title': 'Choosing the Right Category',
            'content':
                'Select the category that best matches your expense. If you\'re unsure, choose the closest match. Consistent categorization improves your financial insights.',
          },
          {
            'title': 'Category-Based Budgets',
            'content':
                'You can set spending limits for each category in the Budget Management screen. This helps you control spending in specific areas of your life.',
          },
        ],
        'tips': [
          'Be consistent with category selection',
          'Review category spending in Analytics',
          'Set budgets for high-spending categories',
        ],
      };
    } else if (title.contains('monthly budgets')) {
      return {
        'sections': [
          {
            'title': 'Step 1: Navigate to Budget Management',
            'content':
                'Open the Budget Management screen from the main menu. This is where you\'ll create and monitor all your spending limits.',
          },
          {
            'title': 'Step 2: Select a Category',
            'content':
                'Choose which category you want to set a budget for. Start with your highest spending categories like Food or Shopping.',
          },
          {
            'title': 'Step 3: Set Your Limit',
            'content':
                'Enter a realistic monthly spending limit for the category. Review your past spending to set achievable goals.',
          },
          {
            'title': 'Step 4: Enable Alerts',
            'content':
                'Turn on budget alerts to receive notifications when you reach 50%, 75%, and 90% of your limit. This helps you stay on track.',
          },
          {
            'title': 'Step 5: Monitor Progress',
            'content':
                'Check your budget progress regularly in the Budget Management screen. Adjust limits as needed based on your actual spending patterns.',
          },
        ],
        'tips': [
          'Start with realistic budgets you can achieve',
          'Review and adjust budgets monthly',
          'Enable alerts to stay informed',
        ],
      };
    } else if (title.contains('analytics')) {
      return {
        'sections': [
          {
            'title': 'Understanding the Dashboard',
            'content':
                'The Analytics Dashboard shows your spending trends, category breakdowns, and smart insights. Use the period selector to view weekly, monthly, or yearly data.',
          },
          {
            'title': 'Spending Trends Chart',
            'content':
                'The line chart shows how your spending changes over time. Look for patterns like increased spending on weekends or at month-end.',
          },
          {
            'title': 'Category Breakdown',
            'content':
                'The pie chart shows what percentage of your budget goes to each category. This helps identify areas where you can cut back.',
          },
          {
            'title': 'Smart Insights',
            'content':
                'AI-powered insights highlight unusual spending patterns, suggest budget adjustments, and celebrate your savings achievements.',
          },
        ],
        'tips': [
          'Check analytics weekly to spot trends early',
          'Compare different time periods',
          'Act on smart insights to improve spending',
        ],
      };
    } else if (title.contains('receipt')) {
      return {
        'sections': [
          {
            'title': 'Capturing Receipts',
            'content':
                'When adding an expense, tap the camera icon to capture a receipt photo. The app uses OCR technology to extract amount and merchant information automatically.',
          },
          {
            'title': 'Viewing Receipts',
            'content':
                'Access all your receipts in the Receipt Management screen. View them as a list or grid, and tap any receipt to see the full image.',
          },
          {
            'title': 'Organizing Receipts',
            'content':
                'Receipts are automatically linked to their corresponding expenses. Use filters to find receipts by date, category, or amount.',
          },
          {
            'title': 'Receipt Storage',
            'content':
                'All receipts are stored securely on your device. You can export them along with expense reports for tax purposes or reimbursement.',
          },
        ],
        'tips': [
          'Capture receipts immediately after purchases',
          'Ensure good lighting for clear OCR results',
          'Review and verify extracted information',
        ],
      };
    } else if (title.contains('export')) {
      return {
        'sections': [
          {
            'title': 'Export Options',
            'content':
                'ExpenseTracker supports exporting your financial data in CSV and PDF formats. Choose the format that works best for your needs.',
          },
          {
            'title': 'Selecting Date Range',
            'content':
                'Before exporting, select the date range you want to include. You can export a single month, quarter, or entire year of data.',
          },
          {
            'title': 'CSV Export',
            'content':
                'CSV files contain all transaction details in a spreadsheet format. Perfect for importing into accounting software or Excel for further analysis.',
          },
          {
            'title': 'PDF Reports',
            'content':
                'PDF reports include formatted summaries, charts, and transaction lists. Ideal for tax preparation, expense reimbursement, or financial reviews.',
          },
        ],
        'tips': [
          'Export monthly for regular record-keeping',
          'Keep exported files backed up securely',
          'Use CSV for detailed analysis in Excel',
        ],
      };
    }

    return {
      'sections': [
        {
          'title': 'Overview',
          'content':
              widget.article['description'] ??
              'Learn more about this feature in ExpenseTracker.',
        },
        {
          'title': 'Getting Started',
          'content':
              'This feature helps you manage your finances more effectively. Explore the app to discover all available options and settings.',
        },
        {
          'title': 'Best Practices',
          'content':
              'Use this feature regularly to get the most value from ExpenseTracker. Check back often for updates and new capabilities.',
        },
      ],
      'tips': [
        'Explore all features to maximize benefits',
        'Check the Help Center for detailed guides',
        'Contact support if you need assistance',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final content = _getArticleContent();
    final sections = content['sections'] as List<Map<String, dynamic>>;
    final tips = content['tips'] as List<String>;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Help Article',
        variant: CustomAppBarVariant.withBack,
        actions: [
          IconButton(
            icon: const CustomIconWidget(iconName: 'share'),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing article...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_scrollProgress > 0)
            LinearProgressIndicator(
              value: _scrollProgress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme),
                  SizedBox(height: 3.h),
                  ...sections.map(
                    (section) => _buildSection(
                      section['title'] as String,
                      section['content'] as String,
                      colorScheme,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildTipsBox(tips, colorScheme),
                  SizedBox(height: 3.h),
                  _buildHelpfulSection(colorScheme),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomIconWidget(
            iconName: widget.article['icon'] ?? 'help',
            color: colorScheme.primary,
            size: 32,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.article['title'],
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.article['description'],
          style: TextStyle(
            fontSize: 13.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildInfoChip(
              'schedule',
              widget.article['readTime'] ?? '5 min',
              colorScheme,
            ),
            SizedBox(width: 2.w),
            _buildInfoChip(
              'category',
              widget.article['category'] ?? 'General',
              colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsBox(List<String> tips, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Pro Tips',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...tips.map(
            (tip) => Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpfulSection(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Was this article helpful?',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeedbackButton(
                icon: 'thumb_up',
                label: 'Yes',
                isSelected: _isHelpful,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isHelpful = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                colorScheme: colorScheme,
              ),
              SizedBox(width: 4.w),
              _buildFeedbackButton(
                icon: 'thumb_down',
                label: 'No',
                isSelected: false,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('We\'ll work on improving this article'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required String icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
