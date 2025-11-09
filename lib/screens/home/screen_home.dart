import 'package:flutter/material.dart';
import 'package:aj_money_manager/screens/category/screen_category.dart';

import 'package:aj_money_manager/screens/transactions/screen_transaction.dart';
import 'package:aj_money_manager/widgets/bottom_navigation.dart';

class ScreenHome extends StatelessWidget {
  ScreenHome({Key? key}) : super(key: key);
  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);
  final pages = [
    ScreenTransaction(),
    ScreenCategory(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: drawer(context),
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: Text("AJ Money Manager"),
        ),
        bottomNavigationBar: MoneyManagerBottomNavigation(),
        body: ValueListenableBuilder(
          valueListenable: selectedIndexNotifier,
          builder: (BuildContext context, int updatedIndex, _) {
            return pages[updatedIndex];
          },
        ),
      ),
    );
  }
}

Widget drawer(BuildContext context) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.6,
    child: Drawer(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: 80,
            color: Colors.blue,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Developer Contact",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(Icons.email),
                  title: Text("ajaijoseph363@gmail.com"),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(Icons.phone),
                  title: Text("+91 9497308477"),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
