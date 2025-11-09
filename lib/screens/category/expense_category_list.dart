import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/db/category/category_db.dart';

import 'package:aj_money_manager/models/category_model.dart';

class ExpenseCategoryList extends StatelessWidget {
  ExpenseCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getCategory("expense");

    return ValueListenableBuilder(
      valueListenable: expenseCategoryListNotifier,
      builder: (context, List<CategoryModel> expenseList, Widget? child) {
        return SingleChildScrollView(
          child: ListView.builder(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = expenseList[index];

                return Column(
                  children: [
                    if (index == 0) ...[
                      Container(
                        width: 70,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            DateFormat.y().format(data.dateTime),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else if (DateFormat.y().format(data.dateTime) !=
                        DateFormat.y().format(expenseList[index - 1].dateTime))
                      Container(
                        width: 70,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Text(
                            DateFormat.y().format(data.dateTime),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Card(
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${DateFormat.d().format(data.dateTime)}",
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${DateFormat.MMM().format(data.dateTime).toString().toUpperCase()}",
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        title: Text(
                          "₹ ${data.amount.toString()}",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: Text(
                          data.purpose,
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              itemCount: expenseList.length),
        );
      },
    );
  }
}
