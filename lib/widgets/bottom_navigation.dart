import 'package:flutter/material.dart';
import 'package:aj_money_manager/screens/home/screen_home.dart';

class MoneyManagerBottomNavigation extends StatelessWidget {
  const MoneyManagerBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ScreenHome.selectedIndexNotifier,
      builder: (BuildContext context, int updatedIndex, Widget? _) {
        return NavigationBar(
          selectedIndex: updatedIndex,
          onDestinationSelected: (newIndex) {
            ScreenHome.selectedIndexNotifier.value = newIndex;
          },
          animationDuration: const Duration(milliseconds: 400),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 8,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
              tooltip: 'View Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Categories',
              tooltip: 'Manage Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
              tooltip: 'View Analytics',
            ),
          ],
        );
      },
    );
  }
}
