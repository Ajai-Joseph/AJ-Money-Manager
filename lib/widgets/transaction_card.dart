import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/utils/accessibility_utils.dart';
import 'modern_card.dart';

/// A card widget for displaying individual transactions
class TransactionCard extends StatelessWidget {
  final CategoryModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.categoryType.toLowerCase() == 'income';
    final color = isIncome ? AppColors.incomeColor : AppColors.expenseColor;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    
    // Create semantic label for screen readers
    final semanticLabel = '${AccessibilityUtils.transactionTypeSemanticLabel(transaction.categoryType)}, '
        '${transaction.purpose}, '
        '${AccessibilityUtils.currencySemanticLabel(isIncome ? transaction.amount : -transaction.amount)}, '
        '${AccessibilityUtils.dateSemanticLabel(transaction.dateTime)}';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: ModernCard(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        onTap: onTap,
        child: InkWell(
          onLongPress: onLongPress,
          child: Row(
          children: [
            // Icon container - exclude from semantics as it's decorative
            ExcludeSemantics(
              child: Container(
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
            ),
            const SizedBox(width: 16),
            // Transaction details - exclude from semantics as parent has label
            ExcludeSemantics(
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.purpose,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(transaction.dateTime),
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
            ),
            // Amount - exclude from semantics as parent has label
            ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                    style: AppTextStyles.amountSmall.copyWith(
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      transaction.categoryType,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact version of transaction card for lists
class CompactTransactionCard extends StatelessWidget {
  final CategoryModel transaction;
  final VoidCallback? onTap;

  const CompactTransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.categoryType.toLowerCase() == 'income';
    final color = isIncome ? AppColors.incomeColor : AppColors.expenseColor;
    
    // Create semantic label for screen readers
    final semanticLabel = '${AccessibilityUtils.transactionTypeSemanticLabel(transaction.categoryType)}, '
        '${transaction.purpose}, '
        '${AccessibilityUtils.currencySemanticLabel(isIncome ? transaction.amount : -transaction.amount)}, '
        '${AccessibilityUtils.dateSemanticLabel(transaction.dateTime)}';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              ExcludeSemantics(
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.purpose,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('MMM dd').format(transaction.dateTime),
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
              ),
              ExcludeSemantics(
                child: Text(
                  '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
