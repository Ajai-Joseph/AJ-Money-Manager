import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/db/category/category_db.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/widgets/transaction_card.dart';
import 'package:aj_money_manager/widgets/empty_state.dart';
import 'package:aj_money_manager/widgets/loading_shimmer.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';

class IncomeMonthlyList extends StatefulWidget {
  final String date;
  
  const IncomeMonthlyList({
    super.key,
    required this.date,
  });

  @override
  State<IncomeMonthlyList> createState() => _IncomeMonthlyListState();
}

class _IncomeMonthlyListState extends State<IncomeMonthlyList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate initial loading
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    getCategory("income");

    if (_isLoading) {
      return const ListItemShimmer(itemCount: 5);
    }
    
    return ValueListenableBuilder(
      valueListenable: incomeCategoryListNotifier,
      builder: (context, List<CategoryModel> incomeList, Widget? child) {
        // Filter transactions for the selected month
        final filteredList = incomeList
            .where((data) => DateFormat.yMMM().format(data.dateTime) == widget.date)
            .toList();
        
        // Sort by date in descending order (most recent first)
        filteredList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        
        if (filteredList.isEmpty) {
          return const EmptyState(
            icon: Icons.arrow_downward,
            title: 'No Income Transactions',
            message: 'No income transactions found for this month.',
          );
        }
        
        // Calculate running balance
        double runningBalance = 0.0;
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final data = filteredList[index];
            runningBalance += data.amount;
            
            // Group by date
            final showDateHeader = index == 0 ||
                !_isSameDay(
                  filteredList[index - 1].dateTime,
                  data.dateTime,
                );
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader) _buildDateHeader(context, data.dateTime),
                _buildAnimatedTransactionCard(
                  context,
                  data,
                  index,
                  runningBalance,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.incomeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              DateFormat('EEEE, MMM dd').format(date),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.incomeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTransactionCard(
    BuildContext context,
    CategoryModel transaction,
    int index,
    double runningBalance,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              children: [
                TransactionCard(
                  transaction: transaction,
                  onTap: () {
                    // Handle transaction tap if needed
                  },
                ),
                // Running balance indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Running Total: ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '₹${runningBalance.toStringAsFixed(2)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.incomeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
