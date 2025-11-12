import 'package:flutter/material.dart';
import 'package:aj_money_manager/screens/category/screen_category.dart';
import 'package:aj_money_manager/screens/transactions/screen_transaction.dart';
import 'package:aj_money_manager/screens/charts/chart_screen.dart';
import 'package:aj_money_manager/widgets/bottom_navigation.dart';
import 'package:aj_money_manager/widgets/summary_card.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/db/category/category_db.dart';
import 'package:aj_money_manager/models/transaction_model.dart';
import 'package:aj_money_manager/utils/responsive_utils.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);
  static ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final pages = [
    const ScreenTransaction(),
    const ScreenCategory(),
    const ChartScreen(),
  ];

  @override
  void initState() {
    super.initState();
    getMonthlyTransaction();
  }

  double _calculateTotalIncome() {
    double total = 0;
    for (var transaction in monthlyTransactionListNotifier.value) {
      total += transaction.totalIncome;
    }
    return total;
  }

  double _calculateTotalExpense() {
    double total = 0;
    for (var transaction in monthlyTransactionListNotifier.value) {
      total += transaction.totalExpense;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildModernAppBar(context),
      bottomNavigationBar: const MoneyManagerBottomNavigation(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary cards section
            ValueListenableBuilder<List<TransactionModel>>(
              valueListenable: monthlyTransactionListNotifier,
              builder: (context, transactions, _) {
                final totalIncome = _calculateTotalIncome();
                final totalExpense = _calculateTotalExpense();
                final balance = totalIncome - totalExpense;

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsivePadding.horizontal / 2,
                      vertical: 8,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.maxCardWidth,
                        ),
                        child: Column(
                          children: [
                            // Balance card
                            BalanceSummaryCard(
                              amount: balance,
                              isAnimated: true,
                            ),
                            const SizedBox(height: 8),
                            // Income and Expense cards - responsive layout
                            context.isMobile
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: IncomeSummaryCard(
                                          amount: totalIncome,
                                          isAnimated: true,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ExpenseSummaryCard(
                                          amount: totalExpense,
                                          isAnimated: true,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: IncomeSummaryCard(
                                          amount: totalIncome,
                                          isAnimated: true,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ExpenseSummaryCard(
                                          amount: totalExpense,
                                          isAnimated: true,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Page content with animated transitions
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: ValueListenableBuilder(
                valueListenable: ScreenHome.selectedIndexNotifier,
                builder: (BuildContext context, int updatedIndex, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(updatedIndex),
                      child: pages[updatedIndex],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      title: const Text(
        'AJ Money Manager',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        // Search icon - IconButton already ensures 48x48 minimum touch target
        Semantics(
          label: 'Search transactions',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            tooltip: 'Search',
          ),
        ),
        // Theme toggle
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ScreenHome.themeModeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark ||
                (themeMode == ThemeMode.system &&
                    MediaQuery.of(context).platformBrightness == Brightness.dark);
            return Semantics(
              label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              button: true,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    ScreenHome.themeModeNotifier.value = isDark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                  });
                },
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              ),
            );
          },
        ),
        // Settings/Info icon (replaces drawer)
        Semantics(
          label: 'Developer information',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showDeveloperInfo(context);
            },
            tooltip: 'Developer Info',
          ),
        ),
      ],
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email),
              title: const Text('ajaijoseph363@gmail.com'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone),
              title: const Text('+91 9497308477'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
