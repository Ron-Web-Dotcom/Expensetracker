import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../services/analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/guide_card_widget.dart';
import './widgets/guide_content_viewer_widget.dart';
import './widgets/guide_search_widget.dart';
import './widgets/quick_start_section_widget.dart';
import './widgets/recently_viewed_widget.dart';

class UserGuideLibrary extends StatefulWidget {
  const UserGuideLibrary({super.key});

  @override
  State<UserGuideLibrary> createState() => _UserGuideLibraryState();
}

class _UserGuideLibraryState extends State<UserGuideLibrary>
    with SingleTickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedTopic = 'All';
  List<String> _bookmarkedGuides = [];
  List<String> _recentlyViewed = [];

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('user_guide_library');
    _tabController = TabController(length: 4, vsync: this);
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    setState(() {
      _recentlyViewed = ['getting-started', 'budget-setup'];
      _bookmarkedGuides = ['expense-tracking', 'receipt-management'];
    });
  }

  List<Map<String, dynamic>> get _filteredGuides {
    List<Map<String, dynamic>> guides = _allGuides;

    if (_searchQuery.isNotEmpty) {
      guides = guides
          .where(
            (guide) =>
                guide['title'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                guide['description'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedDifficulty != 'All') {
      guides = guides
          .where((guide) => guide['difficulty'] == _selectedDifficulty)
          .toList();
    }

    if (_selectedTopic != 'All') {
      guides = guides
          .where((guide) => guide['topic'] == _selectedTopic)
          .toList();
    }

    return guides;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'User Guide Library',
        variant: CustomAppBarVariant.withBack,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showBookmarks();
            },
            tooltip: 'Bookmarks',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showOfflineDownloadOptions();
            },
            tooltip: 'Offline Downloads',
          ),
        ],
      ),
      body: Column(
        children: [
          GuideSearchWidget(
            controller: _searchController,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
              _analytics.trackEvent(
                'guide_search',
                parameters: {'query': query},
              );
            },
          ),
          _buildFilterChips(colorScheme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllGuidesTab(),
                _buildQuickStartTab(),
                _buildDetailedGuidesTab(),
                _buildAdvancedTipsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', _selectedDifficulty, (value) {
              setState(() => _selectedDifficulty = value);
            }, colorScheme),
            SizedBox(width: 2.w),
            _buildFilterChip('Beginner', _selectedDifficulty, (value) {
              setState(() => _selectedDifficulty = value);
            }, colorScheme),
            SizedBox(width: 2.w),
            _buildFilterChip('Intermediate', _selectedDifficulty, (value) {
              setState(() => _selectedDifficulty = value);
            }, colorScheme),
            SizedBox(width: 2.w),
            _buildFilterChip('Advanced', _selectedDifficulty, (value) {
              setState(() => _selectedDifficulty = value);
            }, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selectedValue,
    Function(String) onSelected,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedValue == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.lightImpact();
        onSelected(label);
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'All Guides'),
          Tab(text: 'Quick Start'),
          Tab(text: 'Detailed'),
          Tab(text: 'Advanced'),
        ],
      ),
    );
  }

  Widget _buildAllGuidesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recentlyViewed.isNotEmpty)
          RecentlyViewedWidget(
            recentGuides: _recentlyViewed
                .map((id) => _allGuides.firstWhere((g) => g['id'] == id))
                .toList(),
            onGuideTap: _openGuide,
          ),
        Expanded(child: _buildGuideList(_filteredGuides)),
      ],
    );
  }

  Widget _buildQuickStartTab() {
    final quickStartGuides = _filteredGuides
        .where((g) => g['type'] == 'quick-start')
        .toList();
    return QuickStartSectionWidget(
      guides: quickStartGuides,
      onGuideTap: _openGuide,
    );
  }

  Widget _buildDetailedGuidesTab() {
    final detailedGuides = _filteredGuides
        .where((g) => g['type'] == 'detailed')
        .toList();
    return _buildGuideList(detailedGuides);
  }

  Widget _buildAdvancedTipsTab() {
    final advancedGuides = _filteredGuides
        .where((g) => g['type'] == 'advanced')
        .toList();
    return _buildGuideList(advancedGuides);
  }

  Widget _buildGuideList(List<Map<String, dynamic>> guides) {
    if (guides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 2.h),
            Text(
              'No guides found',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(4.w),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];
        final isBookmarked = _bookmarkedGuides.contains(guide['id']);
        return GuideCardWidget(
          guide: guide,
          isBookmarked: isBookmarked,
          onTap: () => _openGuide(guide),
          onBookmarkToggle: () => _toggleBookmark(guide['id']),
        );
      },
    );
  }

  void _openGuide(Map<String, dynamic> guide) {
    HapticFeedback.lightImpact();
    _analytics.trackEvent(
      'guide_opened',
      parameters: {'guide_id': guide['id']},
    );

    setState(() {
      if (!_recentlyViewed.contains(guide['id'])) {
        _recentlyViewed.insert(0, guide['id']);
        if (_recentlyViewed.length > 5) {
          _recentlyViewed.removeLast();
        }
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GuideContentViewer(guide: guide)),
    );
  }

  void _toggleBookmark(String guideId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_bookmarkedGuides.contains(guideId)) {
        _bookmarkedGuides.remove(guideId);
      } else {
        _bookmarkedGuides.add(guideId);
      }
    });
    _analytics.trackEvent(
      'guide_bookmark_toggled',
      parameters: {'guide_id': guideId},
    );
  }

  void _showBookmarks() {
    final bookmarkedGuides = _bookmarkedGuides
        .map((id) => _allGuides.firstWhere((g) => g['id'] == id))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookmarked Guides',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookmarkedGuides.isEmpty
                  ? Center(
                      child: Text(
                        'No bookmarked guides yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: bookmarkedGuides.length,
                      itemBuilder: (context, index) {
                        return GuideCardWidget(
                          guide: bookmarkedGuides[index],
                          isBookmarked: true,
                          onTap: () {
                            Navigator.pop(context);
                            _openGuide(bookmarkedGuides[index]);
                          },
                          onBookmarkToggle: () =>
                              _toggleBookmark(bookmarkedGuides[index]['id']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineDownloadOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Downloads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Download guides for offline access:'),
            SizedBox(height: 2.h),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Essential Guides'),
              subtitle: const Text('5 guides • 2.3 MB'),
              onTap: () {
                Navigator.pop(context);
                _downloadEssentialGuides();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('All Guides'),
              subtitle: const Text('24 guides • 12.8 MB'),
              onTap: () {
                Navigator.pop(context);
                _downloadAllGuides();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _downloadEssentialGuides() {
    _analytics.trackEvent('guides_download', parameters: {'type': 'essential'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading essential guides...')),
    );
  }

  void _downloadAllGuides() {
    _analytics.trackEvent('guides_download', parameters: {'type': 'all'});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading all guides...')));
  }

  final List<Map<String, dynamic>> _allGuides = [
    {
      'id': 'getting-started',
      'title': 'Getting Started with ExpenseTracker',
      'description':
          'Learn the basics of tracking your expenses and managing your finances',
      'type': 'quick-start',
      'difficulty': 'Beginner',
      'topic': 'Basics',
      'duration': '5 min',
      'icon': Icons.rocket_launch,
      'color': Color(0xFF6BCF36),
    },
    {
      'id': 'expense-tracking',
      'title': 'How to Track Expenses',
      'description':
          'Step-by-step guide to adding and categorizing your daily expenses',
      'type': 'quick-start',
      'difficulty': 'Beginner',
      'topic': 'Expenses',
      'duration': '7 min',
      'icon': Icons.receipt_long,
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'budget-setup',
      'title': 'Setting Up Your First Budget',
      'description':
          'Create and manage budgets for different spending categories',
      'type': 'quick-start',
      'difficulty': 'Beginner',
      'topic': 'Budgets',
      'duration': '10 min',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFFFF9800),
    },
    {
      'id': 'receipt-management',
      'title': 'Managing Receipts',
      'description':
          'Capture, organize, and attach receipts to your expense records',
      'type': 'detailed',
      'difficulty': 'Intermediate',
      'topic': 'Receipts',
      'duration': '12 min',
      'icon': Icons.camera_alt,
      'color': Color(0xFF9C27B0),
    },
    {
      'id': 'analytics-dashboard',
      'title': 'Understanding Your Analytics',
      'description':
          'Interpret spending trends, patterns, and financial insights',
      'type': 'detailed',
      'difficulty': 'Intermediate',
      'topic': 'Analytics',
      'duration': '15 min',
      'icon': Icons.analytics,
      'color': Color(0xFF00BCD4),
    },
    {
      'id': 'categories-customization',
      'title': 'Customizing Expense Categories',
      'description':
          'Create and manage custom categories for better expense organization',
      'type': 'detailed',
      'difficulty': 'Intermediate',
      'topic': 'Categories',
      'duration': '8 min',
      'icon': Icons.category,
      'color': Color(0xFFE91E63),
    },
    {
      'id': 'data-export',
      'title': 'Exporting Your Financial Data',
      'description':
          'Export expense reports in various formats for tax and accounting',
      'type': 'advanced',
      'difficulty': 'Advanced',
      'topic': 'Data Management',
      'duration': '10 min',
      'icon': Icons.file_download,
      'color': Color(0xFF607D8B),
    },
    {
      'id': 'advanced-filters',
      'title': 'Advanced Filtering Techniques',
      'description':
          'Master complex filters to analyze specific expense patterns',
      'type': 'advanced',
      'difficulty': 'Advanced',
      'topic': 'Analytics',
      'duration': '12 min',
      'icon': Icons.filter_alt,
      'color': Color(0xFF795548),
    },
    {
      'id': 'budget-optimization',
      'title': 'Budget Optimization Strategies',
      'description':
          'Advanced techniques for maximizing savings and reducing expenses',
      'type': 'advanced',
      'difficulty': 'Advanced',
      'topic': 'Budgets',
      'duration': '18 min',
      'icon': Icons.trending_up,
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'recurring-expenses',
      'title': 'Managing Recurring Expenses',
      'description':
          'Set up and track subscriptions and regular monthly payments',
      'type': 'detailed',
      'difficulty': 'Intermediate',
      'topic': 'Expenses',
      'duration': '9 min',
      'icon': Icons.repeat,
      'color': Color(0xFFFF5722),
    },
  ];
}
