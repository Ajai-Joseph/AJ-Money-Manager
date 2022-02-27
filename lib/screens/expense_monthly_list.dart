import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/db/category/category_db.dart';
import 'package:money_manager/models/category_model.dart';

class ExpenseMonthlyList extends StatelessWidget {
  String date;
  ExpenseMonthlyList({required this.date});

  @override
  Widget build(BuildContext context) {
    getCategory("expense");
    return ValueListenableBuilder(
      valueListenable: expenseCategoryListNotifier,
      builder: (context, List<CategoryModel> expenseList, Widget? child) {
        return ListView.builder(
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = expenseList[index];

              if (DateFormat.yMMM().format(data.dateTime) == date) {
                print("date:$date");
                return Card(
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
                );
              } else {
                return SizedBox(
                  height: 0,
                );
              }
            },
            itemCount: expenseList.length);
      },
    );
  }
}
