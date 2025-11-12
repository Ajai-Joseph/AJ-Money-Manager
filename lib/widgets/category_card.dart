import 'package:flutter/material.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';
import 'modern_card.dart';

/// A card widget for grid-style category display
class CategoryCard extends StatelessWidget {
  final String categoryName;
  final double totalAmount;
  final String categoryType;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int transactionCount;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.totalAmount,
    required this.categoryType,
    this.icon = Icons.category,
    this.onTap,
    this.onLongPress,
    this.transactionCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = categoryType.toLowerCase() == 'income';
    final color = isIncome ? AppColors.incomeColor : AppColors.expenseColor;
    final gradient = LinearGradient(
      colors: isIncome ? AppColors.incomeGradient : AppColors.expenseGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onLongPress: onLongPress,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            // Category name
            Text(
              categoryName,
              style: AppTextStyles.categoryName.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Total amount
            Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.categoryAmount.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            if (transactionCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$transactionCount transaction${transactionCount > 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A list-style category card for linear layouts
class CategoryListCard extends StatelessWidget {
  final String categoryName;
  final double totalAmount;
  final String categoryType;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int transactionCount;
  final double? budgetLimit;

  const CategoryListCard({
    super.key,
    required this.categoryName,
    required this.totalAmount,
    required this.categoryType,
    this.icon = Icons.category,
    this.onTap,
    this.onLongPress,
    this.transactionCount = 0,
    this.budgetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = categoryType.toLowerCase() == 'income';
    final color = isIncome ? AppColors.incomeColor : AppColors.expenseColor;
    final percentage = budgetLimit != null && budgetLimit! > 0
        ? (totalAmount / budgetLimit!) * 100
        : 0.0;

    return ModernCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: InkWell(
        onLongPress: onLongPress,
        child: Column(
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Category details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: color,
                      ),
                    ),
                    if (budgetLimit != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(0)}% of ₹${budgetLimit!.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            // Progress indicator for budget
            if (budgetLimit != null && budgetLimit! > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: (totalAmount / budgetLimit!).clamp(0.0, 1.0),
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 100 ? AppColors.errorLight : color,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
