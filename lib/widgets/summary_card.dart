import 'package:flutter/material.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';
import 'package:aj_money_manager/utils/accessibility_utils.dart';
import 'modern_card.dart';

/// A card widget for displaying financial summaries with animations
class SummaryCard extends StatefulWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Gradient gradient;
  final bool isAnimated;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
    this.isAnimated = true,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isAnimated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create semantic label for screen readers
    final semanticLabel = '${widget.title}, ${AccessibilityUtils.currencySemanticLabel(widget.amount)}';
    
    return Semantics(
      label: semanticLabel,
      readOnly: true,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ModernCard(
            gradient: widget.gradient,
            padding: const EdgeInsets.all(12.0),
            child: ExcludeSemantics(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: widget.amount),
                builder: (context, value, child) {
                  return Text(
                    '₹${value.toStringAsFixed(2)}',
                    style: AppTextStyles.amountLarge.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  );
                },
              ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

/// Predefined summary card types
class IncomeSummaryCard extends StatelessWidget {
  final double amount;
  final bool isAnimated;

  const IncomeSummaryCard({
    super.key,
    required this.amount,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'Total Income',
      amount: amount,
      icon: Icons.arrow_downward,
      gradient: const LinearGradient(
        colors: AppColors.incomeGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isAnimated: isAnimated,
    );
  }
}

class ExpenseSummaryCard extends StatelessWidget {
  final double amount;
  final bool isAnimated;

  const ExpenseSummaryCard({
    super.key,
    required this.amount,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'Total Expense',
      amount: amount,
      icon: Icons.arrow_upward,
      gradient: const LinearGradient(
        colors: AppColors.expenseGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isAnimated: isAnimated,
    );
  }
}

class BalanceSummaryCard extends StatelessWidget {
  final double amount;
  final bool isAnimated;

  const BalanceSummaryCard({
    super.key,
    required this.amount,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    return SummaryCard(
      title: 'Balance',
      amount: amount.abs(),
      icon: isPositive ? Icons.trending_up : Icons.trending_down,
      gradient: LinearGradient(
        colors: isPositive
            ? [AppColors.balancePositive, AppColors.incomeColorDark]
            : [AppColors.balanceNegative, AppColors.expenseColorDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      isAnimated: isAnimated,
    );
  }
}
