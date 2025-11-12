import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/db/category/category_db.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/widgets/transaction_card.dart';
import 'package:aj_money_manager/widgets/empty_state.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/utils/responsive_utils.dart';

class ExpenseCategoryList extends StatefulWidget {
  final String searchQuery;

  const ExpenseCategoryList({
    super.key,
    this.searchQuery = '',
  });

  @override
  State<ExpenseCategoryList> createState() => _ExpenseCategoryListState();
}

class _ExpenseCategoryListState extends State<ExpenseCategoryList>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<CategoryModel> _filterTransactions(List<CategoryModel> transactions) {
    if (widget.searchQuery.isEmpty) {
      return transactions;
    }

    final query = widget.searchQuery.toLowerCase();
    return transactions.where((transaction) {
      return transaction.purpose.toLowerCase().contains(query) ||
          transaction.amount.toString().contains(query);
    }).toList();
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorLight,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      deleteTransaction(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    getCategory("expense");

    return ValueListenableBuilder(
      valueListenable: expenseCategoryListNotifier,
      builder: (context, List<CategoryModel> expenseList, Widget? child) {
        final filteredList = _filterTransactions(expenseList);

        if (filteredList.isEmpty) {
          return EmptyState(
            icon: widget.searchQuery.isEmpty ? Icons.inbox : Icons.search_off,
            title: widget.searchQuery.isEmpty
                ? 'No Expense Transactions'
                : 'No Results Found',
            message: widget.searchQuery.isEmpty
                ? 'Start adding your expense transactions to see them here.'
                : 'Try adjusting your search query.',
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.maxCardWidth,
            ),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: context.isMobile ? 0 : 16.0,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
            final data = filteredList[index];
            final showYearHeader = index == 0 ||
                DateFormat.y().format(data.dateTime) !=
                    DateFormat.y().format(filteredList[index - 1].dateTime);

            return Column(
              children: [
                if (showYearHeader) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat.y().format(data.dateTime),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                ],
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index * 0.05).clamp(0.0, 1.0),
                        ((index + 1) * 0.05 + 0.5).clamp(0.0, 1.0),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          (index * 0.05).clamp(0.0, 1.0),
                          ((index + 1) * 0.05 + 0.5).clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Slidable(
                        key: Key(data.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) => _confirmDelete(context, data.id),
                              backgroundColor: AppColors.errorLight,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                        child: TransactionCard(
                          transaction: data,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              );
            },
          ),
        ),
      );
      },
    );
  }
}
