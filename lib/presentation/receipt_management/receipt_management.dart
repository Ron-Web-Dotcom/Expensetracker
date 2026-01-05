import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/expense_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/receipt_grid_item_widget.dart';
import './widgets/receipt_list_item_widget.dart';
import './widgets/receipt_filter_bottom_sheet_widget.dart';
import './widgets/receipt_viewer_widget.dart';

enum ViewMode { grid, list }

class ReceiptManagement extends StatefulWidget {
  const ReceiptManagement({super.key});

  @override
  State<ReceiptManagement> createState() => _ReceiptManagementState();
}

class _ReceiptManagementState extends State<ReceiptManagement> {
  final AnalyticsService _analytics = AnalyticsService();
  final ExpenseDataService _expenseDataService = ExpenseDataService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ViewMode _viewMode = ViewMode.grid;
  bool _isLoading = false;
  bool _isSelectionMode = false;
  List<Map<String, dynamic>> _allReceipts = [];
  List<Map<String, dynamic>> _filteredReceipts = [];
  Set<String> _selectedReceipts = {};
  Map<String, dynamic> _activeFilters = {};
  String _sortBy = 'date'; // date, amount, merchant
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _analytics.trackScreenView('receipt_management');
    _loadReceipts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReceipts() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    // Load real receipts from expense data
    final allExpenses = await _expenseDataService.getAllExpenses();

    _allReceipts = allExpenses
        .where((expense) => (expense['receiptPhotos'] as List).isNotEmpty)
        .map((expense) {
          final receiptPhotos = expense['receiptPhotos'] as List;
          return {
            'id': expense['id'],
            'merchant': expense['description'] ?? 'Unknown',
            'amount': (expense['amount'] as num).toDouble().abs(),
            'date': DateTime.parse(expense['date']),
            'category': expense['category'],
            'imageUrl': receiptPhotos.isNotEmpty ? receiptPhotos[0] : '',
            'ocrText':
                'Receipt from ${expense['description'] ?? 'Unknown'}. Total: \$${(expense['amount'] as num).toDouble().abs().toStringAsFixed(2)}',
          };
        })
        .toList();

    _filteredReceipts = List.from(_allReceipts);
    _applySorting();

    setState(() => _isLoading = false);
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredReceipts = List.from(_allReceipts);
      } else {
        _filteredReceipts = _allReceipts.where((receipt) {
          final merchant = receipt['merchant'].toString().toLowerCase();
          final ocrText = receipt['ocrText'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return merchant.contains(searchQuery) ||
              ocrText.contains(searchQuery);
        }).toList();
      }
      _applySorting();
    });
  }

  void _toggleViewMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    });
    _analytics.trackFeatureUsage('receipt_view_toggle');
  }

  void _showFilterSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptFilterBottomSheetWidget(
        activeFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFilters();
          });
          _analytics.trackFeatureUsage('receipt_filter_applied');
        },
      ),
    );
  }

  void _applyFilters() {
    _filteredReceipts = List.from(_allReceipts);

    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as Map<String, DateTime>;
      _filteredReceipts = _filteredReceipts.where((receipt) {
        final date = receipt['date'] as DateTime;
        return date.isAfter(dateRange['start']!) &&
            date.isBefore(dateRange['end']!.add(const Duration(days: 1)));
      }).toList();
    }

    if (_activeFilters['categories'] != null) {
      final categories = _activeFilters['categories'] as List<String>;
      _filteredReceipts = _filteredReceipts.where((receipt) {
        return categories.contains(receipt['category']);
      }).toList();
    }

    if (_activeFilters['amountRange'] != null) {
      final amountRange = _activeFilters['amountRange'] as Map<String, double>;
      _filteredReceipts = _filteredReceipts.where((receipt) {
        final amount = receipt['amount'] as double;
        return amount >= amountRange['min']! && amount <= amountRange['max']!;
      }).toList();
    }

    if (_activeFilters['merchant'] != null) {
      final merchant = _activeFilters['merchant'].toString().toLowerCase();
      _filteredReceipts = _filteredReceipts.where((receipt) {
        return receipt['merchant'].toString().toLowerCase().contains(merchant);
      }).toList();
    }

    _applySorting();
  }

  void _applySorting() {
    _filteredReceipts.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'amount':
          comparison = (a['amount'] as double).compareTo(b['amount'] as double);
          break;
        case 'merchant':
          comparison = a['merchant'].toString().compareTo(
            b['merchant'].toString(),
          );
          break;
        case 'date':
        default:
          comparison = (a['date'] as DateTime).compareTo(b['date'] as DateTime);
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _showSortOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sort By',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'calendar_today',
                color: _sortBy == 'date'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text('Date', style: theme.textTheme.bodyLarge),
              trailing: _sortBy == 'date'
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'date');
                _applySorting();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'attach_money',
                color: _sortBy == 'amount'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text('Amount', style: theme.textTheme.bodyLarge),
              trailing: _sortBy == 'amount'
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'amount');
                _applySorting();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'store',
                color: _sortBy == 'merchant'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text('Merchant', style: theme.textTheme.bodyLarge),
              trailing: _sortBy == 'merchant'
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'merchant');
                _applySorting();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: Text('Ascending Order', style: theme.textTheme.bodyLarge),
              value: _sortAscending,
              activeThumbColor: theme.colorScheme.primary,
              onChanged: (value) {
                setState(() => _sortAscending = value);
                _applySorting();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _toggleSelectionMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedReceipts.clear();
      }
    });
  }

  void _toggleReceiptSelection(String receiptId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedReceipts.contains(receiptId)) {
        _selectedReceipts.remove(receiptId);
      } else {
        _selectedReceipts.add(receiptId);
      }
    });
  }

  void _deleteSelectedReceipts() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receipts'),
        content: Text(
          'Are you sure you want to delete ${_selectedReceipts.length} receipt(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allReceipts.removeWhere(
                  (receipt) => _selectedReceipts.contains(receipt['id']),
                );
                _filteredReceipts.removeWhere(
                  (receipt) => _selectedReceipts.contains(receipt['id']),
                );
                _selectedReceipts.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Receipts deleted')));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _exportSelectedReceipts() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedReceipts.length} receipt(s)...'),
      ),
    );
    _analytics.trackFeatureUsage('receipt_export');
  }

  void _openReceiptViewer(Map<String, dynamic> receipt) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptViewerWidget(receipt: receipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: _isSelectionMode
            ? '${_selectedReceipts.length} selected'
            : 'Receipt Management',
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _selectedReceipts.isEmpty
                  ? null
                  : _deleteSelectedReceipts,
            ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: _selectedReceipts.isEmpty
                  ? null
                  : _exportSelectedReceipts,
            ),
          ] else ...[
            IconButton(
              icon: Icon(
                _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
              ),
              onPressed: _toggleViewMode,
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortOptions,
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectionMode,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          if (_activeFilters.isNotEmpty) _buildActiveFiltersChips(theme),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _filteredReceipts.isEmpty
                ? _buildEmptyState(theme)
                : _viewMode == ViewMode.grid
                ? _buildGridView(theme)
                : _buildListView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search receipts...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.5.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: _activeFilters.isNotEmpty
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _activeFilters.isNotEmpty
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: _showFilterSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips(ThemeData theme) {
    final List<Widget> chips = [];

    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as Map<String, DateTime>;
      final start = DateFormat('MMM d').format(dateRange['start']!);
      final end = DateFormat('MMM d').format(dateRange['end']!);
      chips.add(_buildFilterChip(theme, '$start - $end', 'dateRange'));
    }

    if (_activeFilters['categories'] != null) {
      final categories = _activeFilters['categories'] as List<String>;
      chips.add(
        _buildFilterChip(
          theme,
          '${categories.length} categories',
          'categories',
        ),
      );
    }

    if (_activeFilters['amountRange'] != null) {
      chips.add(_buildFilterChip(theme, 'Amount range', 'amountRange'));
    }

    if (_activeFilters['merchant'] != null) {
      chips.add(
        _buildFilterChip(
          theme,
          _activeFilters['merchant'].toString(),
          'merchant',
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
      child: Wrap(spacing: 2.w, runSpacing: 1.h, children: chips),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String filterKey) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () {
        setState(() {
          _activeFilters.remove(filterKey);
          _applyFilters();
        });
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = _filteredReceipts[index];
        final isSelected = _selectedReceipts.contains(receipt['id']);

        return ReceiptGridItemWidget(
          receipt: receipt,
          isSelected: isSelected,
          isSelectionMode: _isSelectionMode,
          onTap: () {
            if (_isSelectionMode) {
              _toggleReceiptSelection(receipt['id']);
            } else {
              _openReceiptViewer(receipt);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleReceiptSelection(receipt['id']);
            }
          },
        );
      },
    );
  }

  Widget _buildListView(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemCount: _filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = _filteredReceipts[index];
        final isSelected = _selectedReceipts.contains(receipt['id']);

        return ReceiptListItemWidget(
          receipt: receipt,
          isSelected: isSelected,
          isSelectionMode: _isSelectionMode,
          onTap: () {
            if (_isSelectionMode) {
              _toggleReceiptSelection(receipt['id']);
            } else {
              _openReceiptViewer(receipt);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleReceiptSelection(receipt['id']);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            _searchController.text.isNotEmpty || _activeFilters.isNotEmpty
                ? 'No receipts found'
                : 'No receipts yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchController.text.isNotEmpty || _activeFilters.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Start by adding expenses with receipts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isEmpty && _activeFilters.isEmpty) ...[
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-expense');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ],
      ),
    );
  }
}
