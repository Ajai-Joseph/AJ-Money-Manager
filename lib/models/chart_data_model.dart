import 'package:flutter/material.dart';

/// Model for monthly income vs expense comparison data.
/// 
/// Used primarily for bar chart visualizations showing income and expense
/// trends over multiple months.
/// 
/// Example:
/// ```dart
/// final data = MonthlyData(
///   month: 'Jan',
///   income: 50000.0,
///   expense: 35000.0,
///   date: DateTime(2024, 1, 1),
/// );
/// print(data.balance); // 15000.0
/// ```
class MonthlyData {
  /// The abbreviated month name (e.g., 'Jan', 'Feb')
  final String month;
  
  /// Total income for the month
  final double income;
  
  /// Total expense for the month
  final double expense;
  
  /// The date representing this month (typically first day of month)
  final DateTime date;

  /// Creates a MonthlyData instance.
  MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
    required this.date,
  });

  /// Calculates the net balance for the month (income - expense).
  double get balance => income - expense;

  /// Checks if the month has a positive balance (income >= expense).
  bool get isPositive => balance >= 0;
}

/// Model for category-wise spending data.
/// 
/// Used for pie chart visualizations and category analysis.
/// Includes the category name, amount, percentage of total, and display color.
/// 
/// Example:
/// ```dart
/// final data = CategoryData(
///   category: 'Groceries',
///   amount: 5000.0,
///   percentage: 25.0,
///   color: Colors.blue,
/// );
/// print(data.formattedAmount); // '₹5000.00'
/// ```
class CategoryData {
  /// The category name (e.g., 'Groceries', 'Transport')
  final String category;
  
  /// Total amount spent in this category
  final double amount;
  
  /// Percentage of total expenses (0-100)
  final double percentage;
  
  /// Color to use for this category in charts
  final Color color;

  /// Creates a CategoryData instance.
  CategoryData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  /// Formats the amount as a currency string with rupee symbol.
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';

  /// Formats the percentage as a string with one decimal place.
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

/// Model for spending trend over time.
/// 
/// Used for line chart visualizations showing spending patterns
/// across days or weeks.
/// 
/// Example:
/// ```dart
/// final data = TrendData(
///   date: DateTime(2024, 1, 15),
///   amount: 1500.0,
/// );
/// print(data.monthName); // 'Jan'
/// ```
class TrendData {
  /// The date for this data point
  final DateTime date;
  
  /// The spending amount for this date
  final double amount;

  /// Creates a TrendData instance.
  TrendData({
    required this.date,
    required this.amount,
  });

  /// Gets a formatted date string in DD/MM format.
  String get formattedDate => '${date.day}/${date.month}';

  /// Gets the abbreviated month name (e.g., 'Jan', 'Feb').
  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }
}
