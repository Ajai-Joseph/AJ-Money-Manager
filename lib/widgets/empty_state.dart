import 'package:flutter/material.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';

/// A widget for displaying empty states with illustrations and call-to-action buttons
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            // Icon illustration
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }
}

/// Predefined empty state for transactions
class EmptyTransactionsState extends StatelessWidget {
  final VoidCallback? onAddTransaction;

  const EmptyTransactionsState({
    super.key,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No Transactions Yet',
      message:
          'Start tracking your finances by adding your first transaction.',
      actionLabel: 'Add Transaction',
      onAction: onAddTransaction,
    );
  }
}

/// Predefined empty state for categories
class EmptyCategoriesState extends StatelessWidget {
  final VoidCallback? onAddCategory;

  const EmptyCategoriesState({
    super.key,
    this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.category_outlined,
      title: 'No Categories',
      message: 'Create categories to organize your transactions better.',
      actionLabel: 'Add Category',
      onAction: onAddCategory,
    );
  }
}

/// Predefined empty state for search results
class EmptySearchState extends StatelessWidget {
  final String? searchQuery;

  const EmptySearchState({
    super.key,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: searchQuery != null
          ? 'No transactions found for "$searchQuery".\nTry a different search term.'
          : 'No transactions found matching your search.',
      iconColor: Theme.of(context).colorScheme.secondary,
    );
  }
}

/// Predefined empty state for chart data
class EmptyChartState extends StatelessWidget {
  const EmptyChartState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.bar_chart_outlined,
      title: 'No Data Available',
      message:
          'Add some transactions to see your spending patterns and insights.',
      iconColor: Theme.of(context).colorScheme.tertiary,
    );
  }
}

/// Predefined empty state for monthly view
class EmptyMonthlyState extends StatelessWidget {
  final String month;
  final VoidCallback? onAddTransaction;

  const EmptyMonthlyState({
    super.key,
    required this.month,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No Transactions in $month',
      message: 'You haven\'t recorded any transactions for this month yet.',
      actionLabel: 'Add Transaction',
      onAction: onAddTransaction,
    );
  }
}
