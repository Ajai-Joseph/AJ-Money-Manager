import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/screens/expense_monthly_list.dart';
import 'package:aj_money_manager/screens/income_monthly_list.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';
import 'package:aj_money_manager/widgets/summary_card.dart';
import 'package:aj_money_manager/db/category/category_db.dart';

class MonthlyWiseTransacton extends StatefulWidget {
  final String? date;
  
  const MonthlyWiseTransacton({
    super.key,
    this.date,
  });

  @override
  State<MonthlyWiseTransacton> createState() => _MonthlyWiseTransactonState();
}

// Wrapper widget to handle route arguments
class MonthlyWiseTransaction extends StatelessWidget {
  const MonthlyWiseTransaction({super.key});

  @override
  Widget build(BuildContext context) {
    final String? date = ModalRoute.of(context)?.settings.arguments as String?;
    return MonthlyWiseTransacton(date: date ?? '');
  }
}

class _MonthlyWiseTransactonState extends State<MonthlyWiseTransacton>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateMonthlyTotals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateMonthlyTotals() {
    // Calculate totals for the selected month
    getCategory("income");
    getCategory("expense");
    
    final dateStr = widget.date ?? '';
    
    // Listen to income changes
    incomeCategoryListNotifier.addListener(() {
      double income = 0.0;
      for (var transaction in incomeCategoryListNotifier.value) {
        if (DateFormat.yMMM().format(transaction.dateTime) == dateStr) {
          income += transaction.amount;
        }
      }
      if (mounted) {
        setState(() {
          _totalIncome = income;
        });
      }
    });
    
    // Listen to expense changes
    expenseCategoryListNotifier.addListener(() {
      double expense = 0.0;
      for (var transaction in expenseCategoryListNotifier.value) {
        if (DateFormat.yMMM().format(transaction.dateTime) == dateStr) {
          expense += transaction.amount;
        }
      }
      if (mounted) {
        setState(() {
          _totalExpense = expense;
        });
      }
    });
    
    // Initial calculation
    double income = 0.0;
    for (var transaction in incomeCategoryListNotifier.value) {
      if (DateFormat.yMMM().format(transaction.dateTime) == dateStr) {
        income += transaction.amount;
      }
    }
    
    double expense = 0.0;
    for (var transaction in expenseCategoryListNotifier.value) {
      if (DateFormat.yMMM().format(transaction.dateTime) == dateStr) {
        expense += transaction.amount;
      }
    }
    
    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = _totalIncome - _totalExpense;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern app bar with gradient and hero animation
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'transaction_${widget.date}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    widget.date ?? '',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          // Summary cards section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: IncomeSummaryCard(
                          amount: _totalIncome,
                          isAnimated: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ExpenseSummaryCard(
                          amount: _totalExpense,
                          isAnimated: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BalanceSummaryCard(
                    amount: balance,
                    isAnimated: true,
                  ),
                ],
              ),
            ),
          ),
          
          // Modern tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                labelStyle: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.titleMedium,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3.0,
                    ),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: "INCOME"),
                  Tab(text: "EXPENSE"),
                ],
              ),
            ),
          ),
          
          // Tab view content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                IncomeMonthlyList(date: widget.date ?? ''),
                ExpenseMonthlyList(date: widget.date ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
