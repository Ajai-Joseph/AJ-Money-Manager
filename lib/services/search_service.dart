import '../models/category_model.dart';
import '../models/search_filter_model.dart';

/// Service for searching and filtering transactions.
/// 
/// This service provides comprehensive search and filtering capabilities
/// for transaction data, including text search, date range filtering,
/// amount range filtering, and category type filtering.
/// 
/// Features:
/// - Case-insensitive text search
/// - Date range filtering
/// - Amount range filtering
/// - Category type filtering (Income/Expense)
/// - Combined filter application
/// 
/// Example usage:
/// ```dart
/// final results = SearchService.searchTransactions('groceries', transactions);
/// final filtered = SearchService.filterByDateRange(startDate, endDate, transactions);
/// ```
class SearchService {
  /// Searches transactions by query string.
  /// 
  /// Matches against the purpose field (case-insensitive).
  /// Returns all transactions if query is empty.
  /// 
  /// Parameters:
  /// - [query]: The search text to match against transaction purposes
  /// - [transactions]: The list of transactions to search through
  /// 
  /// Returns a filtered list of transactions matching the query.
  static List<CategoryModel> searchTransactions(
    String query,
    List<CategoryModel> transactions,
  ) {
    if (query.isEmpty) {
      return transactions;
    }

    final lowerQuery = query.toLowerCase();
    return transactions.where((transaction) {
      return transaction.purpose.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filters transactions by date range.
  /// 
  /// Returns transactions where dateTime is between start and end (inclusive).
  /// 
  /// Parameters:
  /// - [start]: The start date of the range (inclusive)
  /// - [end]: The end date of the range (inclusive)
  /// - [transactions]: The list of transactions to filter
  /// 
  /// Returns a filtered list of transactions within the date range.
  static List<CategoryModel> filterByDateRange(
    DateTime start,
    DateTime end,
    List<CategoryModel> transactions,
  ) {
    return transactions.where((transaction) {
      final date = transaction.dateTime;
      return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
          (date.isBefore(end) || date.isAtSameMomentAs(end));
    }).toList();
  }

  /// Filters transactions by amount range.
  /// 
  /// Returns transactions where amount is between min and max (inclusive).
  /// 
  /// Parameters:
  /// - [min]: The minimum amount (inclusive)
  /// - [max]: The maximum amount (inclusive)
  /// - [transactions]: The list of transactions to filter
  /// 
  /// Returns a filtered list of transactions within the amount range.
  static List<CategoryModel> filterByAmountRange(
    double min,
    double max,
    List<CategoryModel> transactions,
  ) {
    return transactions.where((transaction) {
      return transaction.amount >= min && transaction.amount <= max;
    }).toList();
  }

  /// Filters transactions by category type.
  /// 
  /// Returns transactions matching the specified type (Income/Expense).
  /// Returns all transactions if type is empty.
  /// 
  /// Parameters:
  /// - [type]: The category type to filter by ('income' or 'expense')
  /// - [transactions]: The list of transactions to filter
  /// 
  /// Returns a filtered list of transactions matching the type.
  static List<CategoryModel> filterByType(
    String type,
    List<CategoryModel> transactions,
  ) {
    if (type.isEmpty) {
      return transactions;
    }

    return transactions.where((transaction) {
      return transaction.categoryType.toLowerCase() == type.toLowerCase();
    }).toList();
  }

  /// Applies multiple filters to transactions.
  /// 
  /// Uses SearchFilter model to apply all active filters in sequence.
  /// Filters are applied in the following order:
  /// 1. Query filter (text search)
  /// 2. Date range filter
  /// 3. Amount range filter
  /// 4. Category type filter
  /// 
  /// Parameters:
  /// - [filter]: The SearchFilter object containing all filter criteria
  /// - [transactions]: The list of transactions to filter
  /// 
  /// Returns a filtered list of transactions matching all active filters.
  static List<CategoryModel> applyFilters(
    SearchFilter filter,
    List<CategoryModel> transactions,
  ) {
    List<CategoryModel> result = transactions;

    // Apply query filter
    if (filter.query != null && filter.query!.isNotEmpty) {
      result = searchTransactions(filter.query!, result);
    }

    // Apply date range filter
    if (filter.startDate != null && filter.endDate != null) {
      result = filterByDateRange(filter.startDate!, filter.endDate!, result);
    }

    // Apply amount range filter
    if (filter.minAmount != null && filter.maxAmount != null) {
      result = filterByAmountRange(filter.minAmount!, filter.maxAmount!, result);
    }

    // Apply category type filter
    if (filter.categoryType != null && filter.categoryType!.isNotEmpty) {
      result = filterByType(filter.categoryType!, result);
    }

    return result;
  }

  /// Searches transactions by amount (exact or partial match).
  /// 
  /// Useful for finding transactions with specific amounts.
  /// Converts amount to string and performs substring matching.
  /// 
  /// Parameters:
  /// - [amountQuery]: The amount text to search for
  /// - [transactions]: The list of transactions to search through
  /// 
  /// Returns a filtered list of transactions with matching amounts.
  static List<CategoryModel> searchByAmount(
    String amountQuery,
    List<CategoryModel> transactions,
  ) {
    if (amountQuery.isEmpty) {
      return transactions;
    }

    return transactions.where((transaction) {
      return transaction.amount.toString().contains(amountQuery);
    }).toList();
  }

  /// Combines search query with filters.
  /// 
  /// Searches in both purpose and amount fields, then applies additional filters.
  /// This is the recommended method for comprehensive search functionality.
  /// 
  /// Parameters:
  /// - [query]: The search text to match against purpose and amount
  /// - [filter]: The SearchFilter object containing additional filter criteria
  /// - [transactions]: The list of transactions to search and filter
  /// 
  /// Returns a filtered list of transactions matching the query and all filters.
  static List<CategoryModel> searchWithFilters(
    String query,
    SearchFilter filter,
    List<CategoryModel> transactions,
  ) {
    List<CategoryModel> result = transactions;

    // First apply the search query
    if (query.isNotEmpty) {
      result = transactions.where((transaction) {
        final lowerQuery = query.toLowerCase();
        final matchesPurpose = transaction.purpose.toLowerCase().contains(lowerQuery);
        final matchesAmount = transaction.amount.toString().contains(query);
        return matchesPurpose || matchesAmount;
      }).toList();
    }

    // Then apply additional filters
    result = applyFilters(filter, result);

    return result;
  }
}
