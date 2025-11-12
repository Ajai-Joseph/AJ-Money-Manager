/// Model for search filter criteria.
/// 
/// Encapsulates all possible filter options for transaction search,
/// including text query, date range, amount range, and category type.
/// All fields are optional to allow flexible filtering.
/// 
/// Example:
/// ```dart
/// final filter = SearchFilter(
///   query: 'groceries',
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31),
///   categoryType: 'expense',
/// );
/// ```
class SearchFilter {
  /// Text query to search in transaction purposes and amounts
  final String? query;
  
  /// Start date for date range filter (inclusive)
  final DateTime? startDate;
  
  /// End date for date range filter (inclusive)
  final DateTime? endDate;
  
  /// Minimum amount for amount range filter (inclusive)
  final double? minAmount;
  
  /// Maximum amount for amount range filter (inclusive)
  final double? maxAmount;
  
  /// Category type filter ('income' or 'expense')
  final String? categoryType;

  /// Creates a SearchFilter instance with optional filter criteria.
  SearchFilter({
    this.query,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.categoryType,
  });

  /// Creates a copy of this filter with updated values.
  /// 
  /// Only the provided parameters will be updated; others remain unchanged.
  /// 
  /// Example:
  /// ```dart
  /// final newFilter = filter.copyWith(query: 'transport');
  /// ```
  SearchFilter copyWith({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? categoryType,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      categoryType: categoryType ?? this.categoryType,
    );
  }

  /// Checks if any filter is currently active.
  /// 
  /// Returns `true` if at least one filter criterion is set.
  bool get hasActiveFilters {
    return query != null ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null ||
        categoryType != null;
  }

  /// Clears all filters and returns a new empty SearchFilter.
  /// 
  /// Example:
  /// ```dart
  /// final emptyFilter = filter.clear();
  /// ```
  SearchFilter clear() {
    return SearchFilter();
  }
}
