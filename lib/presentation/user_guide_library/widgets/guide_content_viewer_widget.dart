import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_app_bar.dart';

class GuideContentViewer extends StatefulWidget {
  final Map<String, dynamic> guide;

  const GuideContentViewer({super.key, required this.guide});

  @override
  State<GuideContentViewer> createState() => _GuideContentViewerState();
}

class _GuideContentViewerState extends State<GuideContentViewer> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _isBookmarked = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Guide',
        variant: CustomAppBarVariant.withBack,
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isBookmarked = !_isBookmarked);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _shareGuide();
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
                  _buildContent(colorScheme),
                  SizedBox(height: 3.h),
                  _buildRelatedGuides(colorScheme),
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
            color: (widget.guide['color'] as Color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.guide['icon'] as IconData,
            color: widget.guide['color'] as Color,
            size: 32,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.guide['title'],
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.guide['description'],
          style: TextStyle(
            fontSize: 13.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            _buildInfoChip(
              Icons.access_time,
              widget.guide['duration'],
              colorScheme,
            ),
            SizedBox(width: 2.w),
            _buildInfoChip(
              Icons.signal_cellular_alt,
              widget.guide['difficulty'],
              colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
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

  Widget _buildContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guide Content',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildSection(
          'Step 1: Getting Started',
          'Begin by opening the ExpenseTracker app and navigating to the main dashboard. Familiarize yourself with the layout and available features.',
          colorScheme,
        ),
        _buildSection(
          'Step 2: Adding Your First Expense',
          'Tap the Add button in the bottom navigation bar. Enter the amount, select a category, and add any relevant details like description or receipt.',
          colorScheme,
        ),
        _buildSection(
          'Step 3: Reviewing Your Expenses',
          'Navigate to the Transaction History to view all your recorded expenses. Use filters to find specific transactions or analyze spending patterns.',
          colorScheme,
        ),
        _buildSection(
          'Step 4: Setting Up Budgets',
          'Go to Budget Management to create spending limits for different categories. Monitor your progress throughout the month.',
          colorScheme,
        ),
        _buildTipBox(
          'Pro Tip',
          'Enable notifications to receive alerts when you approach your budget limits or when recurring expenses are due.',
          colorScheme,
        ),
      ],
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

  Widget _buildTipBox(String title, String content, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 24),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedGuides(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Guides',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Continue learning with these guides',
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        _buildRelatedGuideCard(
          'Managing Receipts',
          'Learn how to capture and organize receipts',
          Icons.camera_alt,
          const Color(0xFF9C27B0),
          colorScheme,
        ),
        _buildRelatedGuideCard(
          'Understanding Analytics',
          'Interpret your spending trends and patterns',
          Icons.analytics,
          const Color(0xFF00BCD4),
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildRelatedGuideCard(
    String title,
    String description,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${widget.guide['title']}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
