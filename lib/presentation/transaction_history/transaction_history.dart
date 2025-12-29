import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/transaction_empty_state_widget.dart';
import './widgets/transaction_list_item_widget.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final AnalyticsService _analytics = AnalyticsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  String _selectedCategory = 'All Categories';
  DateTimeRange? _selectedDateRange;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  List<String> _recentSearches = [];
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('transaction_history');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    _allTransactions = _generateMockTransactions();
    _filteredTransactions = List.from(_allTransactions);

    setState(() => _isLoading = false);
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final moreTransactions = _generateMockTransactions(page: _currentPage + 1);
    _allTransactions.addAll(moreTransactions);
    _applyFilters();
    _currentPage++;

    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshTransactions() async {
    HapticFeedback.mediumImpact();
    _currentPage = 1;
    await _loadTransactions();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredTransactions = List.from(_allTransactions);
      });
      return;
    }

    if (!_recentSearches.contains(query) && query.length > 2) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        final description = (transaction['description'] as String)
            .toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final searchLower = query.toLowerCase();
        return description.contains(searchLower) ||
            category.contains(searchLower);
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    _analytics.trackFeatureUsage('transaction_filter');
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        activeFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as Map<String, DateTime>;
      filtered = filtered.where((transaction) {
        final date = transaction['date'] as DateTime;
        return date.isAfter(dateRange['start']!) &&
            date.isBefore(dateRange['end']!);
      }).toList();
    }

    if (_activeFilters['categories'] != null &&
        (_activeFilters['categories'] as List).isNotEmpty) {
      final categories = _activeFilters['categories'] as List<String>;
      filtered = filtered.where((transaction) {
        return categories.contains(transaction['category']);
      }).toList();
    }

    if (_activeFilters['amountRange'] != null) {
      final amountRange = _activeFilters['amountRange'] as Map<String, double>;
      filtered = filtered.where((transaction) {
        final amount = (transaction['amount'] as double).abs();
        return amount >= amountRange['min']! && amount <= amountRange['max']!;
      }).toList();
    }

    if (_activeFilters['paymentMethods'] != null &&
        (_activeFilters['paymentMethods'] as List).isNotEmpty) {
      final methods = _activeFilters['paymentMethods'] as List<String>;
      filtered = filtered.where((transaction) {
        return methods.contains(transaction['paymentMethod']);
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((transaction) {
        final description = (transaction['description'] as String)
            .toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        return description.contains(query) || category.contains(query);
      }).toList();
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  void _removeFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
      _applyFilters();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchController.clear();
      _applyFilters();
    });
  }

  void _editTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-expense', arguments: transaction);
  }

  void _duplicateTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    final duplicated = Map<String, dynamic>.from(transaction);
    duplicated['id'] = DateTime.now().millisecondsSinceEpoch;
    duplicated['date'] = DateTime.now();

    setState(() {
      _allTransactions.insert(0, duplicated);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction duplicated'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allTransactions.removeAt(0);
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _shareReceipt(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt shared successfully')),
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.mediumImpact();
    final index = _allTransactions.indexWhere(
      (t) => t['id'] == transaction['id'],
    );

    setState(() {
      _allTransactions.removeAt(index);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allTransactions.insert(index, transaction);
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _showTransactionOptions(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'category',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('Change Category'),
                onTap: () {
                  Navigator.pop(context);
                  _changeCategory(transaction);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'repeat',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('Add to Recurring'),
                onTap: () {
                  Navigator.pop(context);
                  _addToRecurring(transaction);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'receipt',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('View Receipt'),
                onTap: () {
                  Navigator.pop(context);
                  _viewReceipt(transaction);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeCategory(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Category changed')));
  }

  void _addToRecurring(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to recurring transactions')),
    );
  }

  void _viewReceipt(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Receipt viewer opened')));
  }

  void _exportTransactions() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Export Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPDF();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'table_chart',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: const Text('Export as CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsCSV();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting as PDF...')));
  }

  void _exportAsCSV() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting as CSV...')));
  }

  List<Map<String, dynamic>> _generateMockTransactions({int page = 1}) {
    final categories = [
      'Food & Dining',
      'Transportation',
      'Shopping',
      'Entertainment',
      'Bills & Utilities',
      'Healthcare',
      'Salary',
      'Freelance',
    ];
    final descriptions = {
      'Food & Dining': [
        'Starbucks Coffee',
        'McDonald\'s',
        'Pizza Hut',
        'Local Restaurant',
        'Grocery Store',
      ],
      'Transportation': [
        'Uber Ride',
        'Gas Station',
        'Metro Card',
        'Parking Fee',
        'Car Maintenance',
      ],
      'Shopping': [
        'Amazon Purchase',
        'Clothing Store',
        'Electronics Shop',
        'Home Depot',
        'Target',
      ],
      'Entertainment': [
        'Netflix Subscription',
        'Movie Tickets',
        'Concert',
        'Gaming',
        'Spotify',
      ],
      'Bills & Utilities': [
        'Electricity Bill',
        'Water Bill',
        'Internet Bill',
        'Phone Bill',
        'Rent',
      ],
      'Healthcare': [
        'Pharmacy',
        'Doctor Visit',
        'Gym Membership',
        'Health Insurance',
        'Dental',
      ],
      'Salary': ['Monthly Salary', 'Bonus', 'Commission'],
      'Freelance': ['Project Payment', 'Consulting Fee', 'Design Work'],
    };
    final paymentMethods = [
      'Credit Card',
      'Debit Card',
      'Cash',
      'Bank Transfer',
      'Digital Wallet',
    ];

    final transactions = <Map<String, dynamic>>[];
    final baseDate = DateTime.now().subtract(Duration(days: (page - 1) * 30));

    for (int i = 0; i < _itemsPerPage; i++) {
      final category = categories[i % categories.length];
      final isIncome = category == 'Salary' || category == 'Freelance';
      final amount = isIncome
          ? (2000 + (i * 500) % 3000).toDouble()
          : -(10 + (i * 15) % 200).toDouble();

      transactions.add({
        'id': DateTime.now().millisecondsSinceEpoch + i + (page * 1000),
        'description':
            (descriptions[category] as List)[i %
                (descriptions[category] as List).length],
        'category': category,
        'amount': amount,
        'date': baseDate.subtract(Duration(days: i, hours: i % 24)),
        'paymentMethod': paymentMethods[i % paymentMethods.length],
        'hasReceipt': i % 3 == 0,
      });
    }

    return transactions;
  }

  Map<String, List<Map<String, dynamic>>> _groupTransactionsByDate() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = DateFormat('MMMM dd, yyyy').format(date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedTransactions = _groupTransactionsByDate();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Transaction History',
        variant: CustomAppBarVariant.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _exportTransactions,
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          if (_activeFilters.isNotEmpty) _buildActiveFiltersChips(theme),
          Expanded(
            child: _isLoading
                ? _buildLoadingState(theme)
                : _filteredTransactions.isEmpty
                ? const TransactionEmptyStateWidget()
                : _buildTransactionList(theme, groupedTransactions),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _activeFilters.isNotEmpty
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _activeFilters.isNotEmpty
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: IconButton(
                    icon: CustomIconWidget(
                      iconName: 'filter_list',
                      color: _activeFilters.isNotEmpty
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: _showFilterBottomSheet,
                    tooltip: 'Filter',
                  ),
                ),
                if (_activeFilters.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_activeFilters.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _activeFilters.entries.map((entry) {
                    String label = '';
                    if (entry.key == 'dateRange') {
                      final range = entry.value as Map<String, DateTime>;
                      label =
                          '${DateFormat('MMM dd').format(range['start']!)} - ${DateFormat('MMM dd').format(range['end']!)}';
                    } else if (entry.key == 'categories') {
                      final categories = entry.value as List<String>;
                      label = categories.length == 1
                          ? categories.first
                          : '${categories.length} categories';
                    } else if (entry.key == 'amountRange') {
                      final range = entry.value as Map<String, double>;
                      label =
                          '\$${range['min']!.toInt()} - \$${range['max']!.toInt()}';
                    } else if (entry.key == 'paymentMethods') {
                      final methods = entry.value as List<String>;
                      label = methods.length == 1
                          ? methods.first
                          : '${methods.length} methods';
                    }

                    return Chip(
                      label: Text(label),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      deleteIcon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onPrimary,
                        size: 16,
                      ),
                      onDeleted: () => _removeFilter(entry.key),
                    );
                  }).toList(),
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Clear All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(
    ThemeData theme,
    Map<String, List<Map<String, dynamic>>> groupedTransactions,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: groupedTransactions.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == groupedTransactions.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final dateKey = groupedTransactions.keys.elementAt(index);
          final transactions = groupedTransactions[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  dateKey,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              ...transactions.map((transaction) {
                return Slidable(
                  key: ValueKey(transaction['id']),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _editTransaction(transaction),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (_) => _duplicateTransaction(transaction),
                        backgroundColor: theme.colorScheme.tertiary,
                        foregroundColor: theme.colorScheme.onTertiary,
                        icon: Icons.content_copy,
                        label: 'Duplicate',
                      ),
                      SlidableAction(
                        onPressed: (_) => _shareReceipt(transaction),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        icon: Icons.share,
                        label: 'Share',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deleteTransaction(transaction),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: TransactionListItemWidget(
                    transaction: transaction,
                    onTap: () => _editTransaction(transaction),
                    onLongPress: () => _showTransactionOptions(transaction),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
