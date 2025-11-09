import 'package:flutter/material.dart';
import 'package:aj_money_manager/screens/add_category.dart';
import 'package:aj_money_manager/screens/expense_monthly_list.dart';
import 'package:aj_money_manager/screens/home/screen_home.dart';
import 'package:aj_money_manager/screens/income_monthly_list.dart';

class MonthlyWiseTransacton extends StatefulWidget {
  String date;
  MonthlyWiseTransacton({required this.date});

  @override
  State<MonthlyWiseTransacton> createState() => _MonthlyWiseTransactonState();
}

class _MonthlyWiseTransactonState extends State<MonthlyWiseTransacton>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: drawer(context),
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: Text(widget.date),
        ),
        body: Column(
          children: [
            TabBar(
              controller: tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  text: "INCOME",
                ),
                Tab(
                  text: "EXPENSE",
                )
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  IncomeMonthlyList(date: widget.date),
                  ExpenseMonthlyList(date: widget.date),
                ],
              ),
            ),
          ],
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
            height: 120,
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
                  leading: Icon(Icons.phone),
                  title: Text("+91 9497308477"),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(Icons.email),
                  title: Text("ajaijoseph363@gmail.com"),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
