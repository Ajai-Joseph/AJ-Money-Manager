import 'package:flutter/material.dart';
import 'package:aj_money_manager/db/category/category_db.dart';

import 'package:aj_money_manager/models/transaction_model.dart';
import 'package:aj_money_manager/screens/monthly_wise_transaction.dart';

class ScreenTransaction extends StatelessWidget {
  const ScreenTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getMonthlyTransaction();
    return ValueListenableBuilder(
      valueListenable: monthlyTransactionListNotifier,
      builder:
          (context, List<TransactionModel> transactionList, Widget? child) {
        return ListView.builder(
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final data = transactionList[index];
              return Card(
                child: ListTile(
                  horizontalTitleGap: 0,
                  onTap: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MonthlyWiseTransacton(
                              date: data.id,
                            ))),
                  },
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${data.id.substring(0, 3)}",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${data.id.substring(4, 8)}",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  title: Row(
                    children: [
                      Text(
                        "Total Income: ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "₹${data.totalIncome}",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        "Total Expense: ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "₹${data.totalExpense}",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    "₹${(data.totalIncome - data.totalExpense).abs()}",
                    style: data.totalIncome - data.totalExpense < 0
                        ? TextStyle(color: Colors.red, fontSize: 13)
                        : TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ),
              );
            },
            itemCount: transactionList.length);
      },
    );
  }
}
