import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';
import 'package:aj_money_manager/db/category/category_db.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/models/search_filter_model.dart';
import 'package:aj_money_manager/services/search_service.dart';
import 'package:aj_money_manager/widgets/empty_state.dart';
import 'package:aj_money_manager/widgets/loading_shimmer.dart';
import 'package:aj_money_manager/widgets/modern_search_bar.dart';
import 'package:aj_money_manager/widgets/transaction_card.dart';

/// Full-screen search interface for transactions
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> _allTransactions = [];
  List<CategoryModel> _filteredTransactions = [];
  List<String> _recentSearches = [];
  SearchFilter _currentFilter = SearchFilter();
  bool _isLoading = true;
  bool _showFilters = false;

  // Filter controllers
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
      final transactions = categoryDB.values.toList();
      
      // Sort by date (most recent first)
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    // In a real app, you'd load this from SharedPreferences or Hive
    // For now, we'll use an empty list
    setState(() {
      _recentSearches = [];
    });
  }

  void _saveRecentSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
    
    // In a real app, save to SharedPreferences or Hive
  }

  void _performSearch(String query) {
    _saveRecentSearch(query);
    
    setState(() {
      _currentFilter = _currentFilter.copyWith(query: query);
      _filteredTransactions = SearchService.searchWithFilters(
        query,
        _currentFilter,
        _allTransactions,
      );
    });
  }

  void _applyFilters() {
    setState(() {
      _currentFilter = SearchFilter(
        query: _searchController.text,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
        categoryType: _selectedType,
      );

      _filteredTransactions = SearchService.searchWithFilters(
        _searchController.text,
        _currentFilter,
        _allTransactions,
      );
      _showFilters = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _selectedType = null;
      _currentFilter = SearchFilter(query: _searchController.text);
      
      _filteredTransactions = SearchService.searchWithFilters(
        _searchController.text,
        _currentFilter,
        _allTransactions,
      );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentFilter = SearchFilter();
      _filteredTransactions = _allTransactions;
    });
  }

  bool get _hasActiveFilters {
    return _startDate != null ||
        _endDate != null ||
        _minAmount != null ||
        _maxAmount != null ||
        _selectedType != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Transactions',
          style: AppTextStyles.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ModernSearchBar(
              controller: _searchController,
              hintText: 'Search by purpose or amount...',
              autofocus: true,
              onChanged: _performSearch,
              onClear: _clearSearch,
            ),
          ),

          // Filter button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    ),
                    label: Text(_hasActiveFilters
                        ? 'Filters Applied'
                        : 'Add Filters'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _hasActiveFilters
                          ? AppColors.primaryLight
                          : Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(
                        color: _hasActiveFilters
                            ? AppColors.primaryLight
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getActiveFilterCount().toString(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Filter panel
          if (_showFilters) _buildFilterPanel(),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const ListItemShimmer(itemCount: 6);
    }

    if (_searchController.text.isEmpty && !_hasActiveFilters) {
      return _buildRecentSearches();
    }

    if (_filteredTransactions.isEmpty) {
      return EmptySearchState(
        searchQuery: _searchController.text,
      );
    }

    return _buildSearchResults();
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Search your transactions',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find transactions by purpose, amount, or date',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _recentSearches.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${_filteredTransactions.length} result${_filteredTransactions.length == 1 ? '' : 's'} found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _filteredTransactions[index];
              return _buildHighlightedTransactionCard(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedTransactionCard(CategoryModel transaction) {
    return TransactionCard(
      transaction: transaction,
      onTap: () {
        // Could navigate to transaction details
      },
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Date range filter
          Text(
            'Date Range',
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _startDate != null
                        ? DateFormat('MMM dd, yyyy').format(_startDate!)
                        : 'Start Date',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _endDate != null
                        ? DateFormat('MMM dd, yyyy').format(_endDate!)
                        : 'End Date',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Amount range filter
          Text(
            'Amount Range',
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Min Amount',
                    prefixText: '₹',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minAmount = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Max Amount',
                    prefixText: '₹',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxAmount = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category type filter
          Text(
            'Transaction Type',
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: const Text('Income'),
                  selected: _selectedType == 'income',
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? 'income' : null;
                    });
                  },
                  selectedColor: AppColors.incomeColor.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.incomeColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Text('Expense'),
                  selected: _selectedType == 'expense',
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? 'expense' : null;
                    });
                  },
                  selectedColor: AppColors.expenseColor.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.expenseColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_startDate != null || _endDate != null) count++;
    if (_minAmount != null || _maxAmount != null) count++;
    if (_selectedType != null) count++;
    return count;
  }
}
