import '../models/category_model.dart';
import '../models/chart_data_model.dart';
import '../config/theme/app_colors.dart';

/// Service for processing and aggregating transaction data for chart visualization.
/// 
/// This service provides methods to transform raw transaction data into
/// chart-ready formats for various visualizations including pie charts,
/// bar charts, and trend analysis.
/// 
/// Features:
/// - Automatic caching for improved performance
/// - Category-wise expense aggregation
/// - Monthly income vs expense comparison
/// - Spending trend analysis
/// - Top categories identification
/// 
/// Example usage:
/// ```dart
/// final categoryData = ChartService.getCategoryExpenseData(transactions);
/// final monthlyData = ChartService.getMonthlyComparisonData(transactions, 6);
/// ```
class ChartService {
  // Cache for chart data to avoid recalculation
  static final Map<String, dynamic> _cache = {};
  static List<CategoryModel>? _lastTransactions;
  
  /// Clears the cache when transactions are updated.
  /// 
  /// Call this method after adding, updating, or deleting transactions
  /// to ensure chart data reflects the latest changes.
  static void clearCache() {
    _cache.clear();
    _lastTransactions = null;
  }
  
  /// Checks if cache is valid for current transactions.
  /// 
  /// Returns `true` if the cached data can be reused, `false` otherwise.
  static bool _isCacheValid(List<CategoryModel> transactions) {
    if (_lastTransactions == null) return false;
    if (_lastTransactions!.length != transactions.length) return false;
    // Simple check - could be enhanced with more sophisticated comparison
    return true;
  }
  
  /// Gets cached data or computes and caches it.
  /// 
  /// This internal method handles the caching logic for all chart data methods.
  static T _getCachedOrCompute<T>(
    String key,
    List<CategoryModel> transactions,
    T Function() compute,
  ) {
    if (_isCacheValid(transactions) && _cache.containsKey(key)) {
      return _cache[key] as T;
    }
    _lastTransactions = transactions;
    final result = compute();
    _cache[key] = result;
    return result;
  }
  /// Gets category-wise expense data for pie chart visualization.
  /// 
  /// Aggregates all expense transactions by category (purpose) and returns
  /// a map of category names to total amounts. Results are cached for performance.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// 
  /// Returns a map where keys are category names and values are total amounts.
  static Map<String, double> getCategoryExpenseData(
    List<CategoryModel> transactions,
  ) {
    return _getCachedOrCompute(
      'categoryExpenseData',
      transactions,
      () {
        final Map<String, double> categoryData = {};

        // Filter only expense transactions
        final expenses = transactions.where(
          (t) => t.categoryType.toLowerCase() == 'expense',
        );

        // Aggregate amounts by category (purpose)
        for (var transaction in expenses) {
          final category = transaction.purpose;
          categoryData[category] = (categoryData[category] ?? 0) + transaction.amount;
        }

        return categoryData;
      },
    );
  }

  /// Gets monthly income vs expense comparison data for bar chart visualization.
  /// 
  /// Generates data for the specified number of months, calculating total
  /// income and expense for each month. Results are cached for performance.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// - [months]: The number of months to include (counting backwards from current month)
  /// 
  /// Returns a list of MonthlyData objects, one for each month.
  static List<MonthlyData> getMonthlyComparisonData(
    List<CategoryModel> transactions,
    int months,
  ) {
    return _getCachedOrCompute(
      'monthlyComparisonData_$months',
      transactions,
      () {
        final List<MonthlyData> monthlyData = [];
        final now = DateTime.now();

        // Generate data for each month
        for (int i = months - 1; i >= 0; i--) {
          final targetDate = DateTime(now.year, now.month - i, 1);
          
          // Filter transactions for this month
          final monthTransactions = transactions.where((t) {
            return t.dateTime.year == targetDate.year &&
                   t.dateTime.month == targetDate.month;
          });

          // Calculate totals
          double income = 0;
          double expense = 0;

          for (var transaction in monthTransactions) {
            if (transaction.categoryType.toLowerCase() == 'income') {
              income += transaction.amount;
            } else if (transaction.categoryType.toLowerCase() == 'expense') {
              expense += transaction.amount;
            }
          }

          // Get month name
          const monthNames = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          final monthName = monthNames[targetDate.month - 1];

          monthlyData.add(MonthlyData(
            month: monthName,
            income: income,
            expense: expense,
            date: targetDate,
          ));
        }

        return monthlyData;
      },
    );
  }

  /// Gets spending trend data over time.
  /// 
  /// Aggregates expense transactions by date to show daily spending patterns.
  /// Useful for line chart visualizations of spending trends.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// 
  /// Returns a list of TrendData objects sorted by date.
  static List<TrendData> getSpendingTrend(
    List<CategoryModel> transactions,
  ) {
    final Map<DateTime, double> dailyExpenses = {};

    // Filter only expense transactions
    final expenses = transactions.where(
      (t) => t.categoryType.toLowerCase() == 'expense',
    );

    // Aggregate expenses by date
    for (var transaction in expenses) {
      final date = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      dailyExpenses[date] = (dailyExpenses[date] ?? 0) + transaction.amount;
    }

    // Convert to TrendData list and sort by date
    final trendData = dailyExpenses.entries
        .map((e) => TrendData(date: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return trendData;
  }

  /// Calculates category percentages for pie chart visualization.
  /// 
  /// Computes the percentage of total expenses for each category.
  /// Returns an empty map if total expenses are zero.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// 
  /// Returns a map where keys are category names and values are percentages (0-100).
  static Map<String, double> getCategoryPercentages(
    List<CategoryModel> transactions,
  ) {
    final categoryData = getCategoryExpenseData(transactions);
    final total = categoryData.values.fold<double>(0, (sum, amount) => sum + amount);

    if (total == 0) return {};

    final Map<String, double> percentages = {};
    categoryData.forEach((category, amount) {
      percentages[category] = (amount / total) * 100;
    });

    return percentages;
  }

  /// Gets category data with colors for visualization.
  /// 
  /// Combines category amounts, percentages, and colors into CategoryData objects
  /// ready for chart rendering. Results are cached for performance and sorted
  /// by amount in descending order.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// 
  /// Returns a list of CategoryData objects sorted by amount (highest first).
  static List<CategoryData> getCategoryDataWithColors(
    List<CategoryModel> transactions,
  ) {
    return _getCachedOrCompute(
      'categoryDataWithColors',
      transactions,
      () {
        final categoryAmounts = getCategoryExpenseData(transactions);
        final percentages = getCategoryPercentages(transactions);
        
        final List<CategoryData> categoryDataList = [];
        int colorIndex = 0;

        categoryAmounts.forEach((category, amount) {
          categoryDataList.add(CategoryData(
            category: category,
            amount: amount,
            percentage: percentages[category] ?? 0,
            color: AppColors.chartColors[colorIndex % AppColors.chartColors.length],
          ));
          colorIndex++;
        });

        // Sort by amount descending
        categoryDataList.sort((a, b) => b.amount.compareTo(a.amount));

        return categoryDataList;
      },
    );
  }

  /// Gets total income for a specific month.
  /// 
  /// Calculates the sum of all income transactions for the given month.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// - [month]: The target month (only year and month are considered)
  /// 
  /// Returns the total income amount for the specified month.
  static double getMonthlyIncome(
    List<CategoryModel> transactions,
    DateTime month,
  ) {
    return transactions
        .where((t) =>
            t.categoryType.toLowerCase() == 'income' &&
            t.dateTime.year == month.year &&
            t.dateTime.month == month.month)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Gets total expense for a specific month.
  /// 
  /// Calculates the sum of all expense transactions for the given month.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// - [month]: The target month (only year and month are considered)
  /// 
  /// Returns the total expense amount for the specified month.
  static double getMonthlyExpense(
    List<CategoryModel> transactions,
    DateTime month,
  ) {
    return transactions
        .where((t) =>
            t.categoryType.toLowerCase() == 'expense' &&
            t.dateTime.year == month.year &&
            t.dateTime.month == month.month)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// Gets top spending categories.
  /// 
  /// Returns the top N categories by spending amount, useful for
  /// highlighting the biggest expense categories.
  /// 
  /// Parameters:
  /// - [transactions]: The list of all transactions to process
  /// - [limit]: The maximum number of categories to return
  /// 
  /// Returns a list of CategoryData objects for the top categories.
  static List<CategoryData> getTopCategories(
    List<CategoryModel> transactions,
    int limit,
  ) {
    final categoryDataList = getCategoryDataWithColors(transactions);
    return categoryDataList.take(limit).toList();
  }
}
