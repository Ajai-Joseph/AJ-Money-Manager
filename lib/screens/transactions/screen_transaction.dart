import 'package:flutter/material.dart';
import 'package:aj_money_manager/db/category/category_db.dart';
import 'package:aj_money_manager/models/transaction_model.dart';
import 'package:aj_money_manager/widgets/modern_card.dart';
import 'package:aj_money_manager/widgets/modern_search_bar.dart';
import 'package:aj_money_manager/widgets/empty_state.dart';
import 'package:aj_money_manager/widgets/loading_shimmer.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';
import 'package:aj_money_manager/utils/responsive_utils.dart';

class ScreenTransaction extends StatefulWidget {
  const ScreenTransaction({super.key});

  @override
  State<ScreenTransaction> createState() => _ScreenTransactionState();
}

class _ScreenTransactionState extends State<ScreenTransaction>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();

    // FAB animation controller
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start FAB animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(
      List<TransactionModel> transactions) {
    if (_searchQuery.isEmpty) {
      return transactions;
    }

    return transactions.where((transaction) {
      final monthYear = transaction.id.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return monthYear.contains(query);
    }).toList();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    getMonthlyTransaction();
    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToAddTransaction() {
    Navigator.pushNamed(context, '/add-category');
  }

  @override
  Widget build(BuildContext context) {
    getMonthlyTransaction();

    return Scaffold(
      body: Column(
        children: [
          // Search bar at the top - responsive padding
          Padding(
            padding: context.responsivePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.maxCardWidth,
                ),
                child: ModernSearchBar(
                  hintText: 'Search by month or year...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ),
          // Transaction list
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: monthlyTransactionListNotifier,
              builder: (context, List<TransactionModel> transactionList,
                  Widget? child) {
                final filteredList = _filterTransactions(transactionList);

                if (_isLoading) {
                  return const ListItemShimmer(itemCount: 8);
                }

                if (transactionList.isEmpty) {
                  return EmptyTransactionsState(
                    onAddTransaction: _navigateToAddTransaction,
                  );
                }

                if (filteredList.isEmpty) {
                  return EmptySearchState(searchQuery: _searchQuery);
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.maxCardWidth,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          left: context.isMobile ? 8.0 : 16.0,
                          right: context.isMobile ? 8.0 : 16.0,
                          bottom: 16.0,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                      final data = filteredList[index];
                      final balance = data.totalIncome - data.totalExpense;
                      final isPositive = balance >= 0;

                      return FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              (index / filteredList.length).clamp(0.0, 1.0),
                              ((index + 1) / filteredList.length)
                                  .clamp(0.0, 1.0),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.3, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (index / filteredList.length).clamp(0.0, 1.0),
                                ((index + 1) / filteredList.length)
                                    .clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: Hero(
                            tag: 'transaction_${data.id}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: ModernCard(
                            margin: context.responsiveCardMargin,
                            padding: context.responsivePadding,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/monthly-transactions',
                                arguments: data.id,
                              );
                            },
                            child: Row(
                              children: [
                                // Month/Year display
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.8),
                                        Theme.of(context).colorScheme.primary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data.id.substring(0, 3).toUpperCase(),
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        data.id.substring(4, 8),
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Transaction details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Income row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_downward,
                                            size: 16,
                                            color: AppColors.incomeColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Income: ',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Text(
                                            '₹${data.totalIncome.toStringAsFixed(2)}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.incomeColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Expense row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_upward,
                                            size: 16,
                                            color: AppColors.expenseColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Expense: ',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Text(
                                            '₹${data.totalExpense.toStringAsFixed(2)}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.expenseColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Balance
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Balance',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 6.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (isPositive
                                                ? AppColors.incomeColor
                                                : AppColors.expenseColor)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        '${isPositive ? '+' : '-'}₹${balance.abs().toStringAsFixed(2)}',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: isPositive
                                              ? AppColors.incomeColor
                                              : AppColors.expenseColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Floating action button for quick add with animation
      // floatingActionButton: Semantics(
      //   label: 'Add new transaction',
      //   button: true,
      //   child: ScaleTransition(
      //     scale: _fabScaleAnimation,
      //     child: RotationTransition(
      //       turns: _fabRotationAnimation,
      //       child: FloatingActionButton.extended(
      //         onPressed: _navigateToAddTransaction,
      //         icon: const Icon(Icons.add),
      //         label: const Text('Add Transaction'),
      //         elevation: 4,
      //         heroTag: 'add_transaction_fab',
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
