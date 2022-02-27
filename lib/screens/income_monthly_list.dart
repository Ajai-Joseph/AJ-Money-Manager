import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/db/category/category_db.dart';
import 'package:money_manager/models/category_model.dart';

class IncomeMonthlyList extends StatelessWidget {
  String date;
  IncomeMonthlyList({required this.date});

  @override
  Widget build(BuildContext context) {
    getCategory("income");
    return ValueListenableBuilder(
      valueListenable: incomeCategoryListNotifier,
      builder: (context, List<CategoryModel> incomeList, Widget? child) {
        return ListView.builder(
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = incomeList[index];

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
                        color: Colors.green,
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
            itemCount: incomeList.length);
      },
    );
  }
}
