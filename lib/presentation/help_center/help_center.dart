import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/analytics_service.dart';
import './widgets/help_category_card_widget.dart';
import './widgets/featured_article_card_widget.dart';
import './widgets/quick_access_button_widget.dart';
import './widgets/help_article_item_widget.dart';

/// Help Center - Comprehensive support hub with guides and troubleshooting
class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  final AnalyticsService _analytics = AnalyticsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _isSearching = false;

  // Help categories data
  final List<Map<String, dynamic>> _helpCategories = [
{ "id": "getting_started",
"title": "Getting Started",
"icon": "rocket_launch",
"articleCount": 12,
"color": Color(0xFF4CAF50),
"popularTopics": ["First expense", "Account setup", "App navigation"],
},
{ "id": "expense_management",
"title": "Expense Management",
"icon": "receipt_long",
"articleCount": 18,
"color": Color(0xFF2196F3),
"popularTopics": ["Add expenses", "Edit transactions", "Categories"],
},
{ "id": "budget_planning",
"title": "Budget Planning",
"icon": "account_balance_wallet",
"articleCount": 15,
"color": Color(0xFFFF9800),
"popularTopics": ["Set budgets", "Track spending", "Budget alerts"],
},
{ "id": "analytics",
"title": "Analytics",
"icon": "insights",
"articleCount": 10,
"color": Color(0xFF9C27B0),
"popularTopics": ["View reports", "Export data", "Spending trends"],
},
{ "id": "account_settings",
"title": "Account Settings",
"icon": "settings",
"articleCount": 14,
"color": Color(0xFF607D8B),
"popularTopics": ["Profile", "Security", "Preferences"],
},
];

  // Featured articles
  final List<Map<String, dynamic>> _featuredArticles = [
{ "title": "Year-End Financial Review Guide",
"description": "Prepare for tax season with comprehensive expense reports",
"image": "https://images.unsplash.com/photo-1584346881556-19b8804d414f",
"semanticLabel": "Calendar and financial documents on desk with calculator and pen",
"readTime": "8 min",
"category": "Analytics",
},
{ "title": "Smart Budget Tips for 2026",
"description": "Optimize your spending with AI-powered insights",
"image": "https://img.rocket.new/generatedImages/rocket_gen_img_1ceb05abc-1764672316473.png",
"semanticLabel": "Person reviewing budget charts and graphs on tablet device",
"readTime": "5 min",
"category": "Budget Planning",
},
];

  // All help articles
  final List<Map<String, dynamic>> _allArticles = [
{ "title": "How to add your first expense",
"description": "Step-by-step guide to logging expenses with camera capture",
"category": "Getting Started",
"readTime": "3 min",
"helpfulness": 4.8,
"icon": "add_circle",
},
{ "title": "Understanding expense categories",
"description": "Learn how to organize transactions with smart categories",
"category": "Expense Management",
"readTime": "4 min",
"helpfulness": 4.6,
"icon": "category",
},
{ "title": "Setting up monthly budgets",
"description": "Create spending limits and track progress in real-time",
"category": "Budget Planning",
"readTime": "6 min",
"helpfulness": 4.9,
"icon": "account_balance_wallet",
},
{ "title": "Viewing spending analytics",
"description": "Discover patterns with charts and trend visualizations",
"category": "Analytics",
"readTime": "5 min",
"helpfulness": 4.7,
"icon": "trending_up",
},
{ "title": "Managing receipt attachments",
"description": "Capture and organize receipts with OCR technology",
"category": "Expense Management",
"readTime": "4 min",
"helpfulness": 4.5,
"icon": "camera_alt",
},
{ "title": "Exporting financial reports",
"description": "Generate CSV and PDF reports for tax preparation",
"category": "Analytics",
"readTime": "3 min",
"helpfulness": 4.8,
"icon": "file_download",
},
];

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('help_center');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = query.isNotEmpty;
    });
    _analytics.trackEvent('help_search', parameters: {'query': query});
  }

  void _handleCategorySelect(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
    HapticFeedback.selectionClick();
    _analytics.trackEvent('help_category_selected', parameters: {'category': categoryId});
  }

  void _handleArticleOpen(String articleTitle) {
    HapticFeedback.lightImpact();
    _analytics.trackEvent('help_article_opened', parameters: {'article': articleTitle});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $articleTitle'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleContactSupport() {
    HapticFeedback.mediumImpact();
    _analytics.trackEvent('contact_support_clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening support chat...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredArticles() {
    var articles = _allArticles;
    
    if (_selectedCategory != 'all') {
      final categoryTitle = _helpCategories
          .firstWhere((cat) => cat['id'] == _selectedCategory)['title'];
      articles = articles.where((article) => article['category'] == categoryTitle).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      articles = articles.where((article) {
        return article['title'].toString().toLowerCase().contains(_searchQuery) ||
               article['description'].toString().toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    return articles;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredArticles = _getFilteredArticles();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Help Center',
        variant: CustomAppBarVariant.withBack,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearch,
                decoration: InputDecoration(
                  hintText: 'Search help articles...',
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ),

          // Quick access buttons
          if (!_isSearching) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Access',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: QuickAccessButtonWidget(
                            icon: 'play_circle',
                            label: 'Video Tutorials',
                            color: const Color(0xFFE91E63),
                            onTap: () {
                              _analytics.trackEvent('video_tutorials_clicked');
                            },
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: QuickAccessButtonWidget(
                            icon: 'chat',
                            label: 'Live Chat',
                            color: const Color(0xFF00BCD4),
                            onTap: _handleContactSupport,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: QuickAccessButtonWidget(
                            icon: 'help',
                            label: 'FAQ',
                            color: const Color(0xFFFF9800),
                            onTap: () {
                              _analytics.trackEvent('faq_clicked');
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),

            // Featured articles
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'Featured Articles',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 20.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _featuredArticles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 3.w),
                          child: FeaturedArticleCardWidget(
                            article: _featuredArticles[index],
                            onTap: () => _handleArticleOpen(
                              _featuredArticles[index]['title'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),

            // Help categories
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Browse by Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(4.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return HelpCategoryCardWidget(
                      category: _helpCategories[index],
                      isSelected: _selectedCategory == _helpCategories[index]['id'],
                      onTap: () => _handleCategorySelect(
                        _helpCategories[index]['id'],
                      ),
                    );
                  },
                  childCount: _helpCategories.length,
                ),
              ),
            ),
          ],

          // Article list
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSearching
                        ? 'Search Results (${filteredArticles.length})'
                        : _selectedCategory == 'all'
                            ? 'All Articles'
                            : '${_helpCategories.firstWhere((cat) => cat['id'] == _selectedCategory)['title']} Articles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedCategory != 'all')
                    TextButton(
                      onPressed: () => _handleCategorySelect('all'),
                      child: const Text('View All'),
                    ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: filteredArticles.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No articles found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try a different search term',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return HelpArticleItemWidget(
                          article: filteredArticles[index],
                          onTap: () => _handleArticleOpen(
                            filteredArticles[index]['title'],
                          ),
                        );
                      },
                      childCount: filteredArticles.length,
                    ),
                  ),
          ),

          // Contact support button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Still need help?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Our support team is here to assist you',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: _handleContactSupport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.5.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CustomIconWidget(
                            iconName: 'support_agent',
                            color: Color(0xFF6BCF36),
                          ),
                          SizedBox(width: 2.w),
                          const Text('Contact Support'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        ],
      ),
    );
  }
}