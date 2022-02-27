import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/db/category/category_db.dart';

import 'package:money_manager/models/category_model.dart';

class IncomeCategoryList extends StatelessWidget {
  IncomeCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getCategory("income");

    return ValueListenableBuilder(
      valueListenable: incomeCategoryListNotifier,
      builder: (context, List<CategoryModel> incomeList, Widget? child) {
        return SingleChildScrollView(
          child: ListView.builder(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = incomeList[index];

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
                        DateFormat.y().format(incomeList[index - 1].dateTime))
                      Container(
                        width: 70,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade200),
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
                    Slidable(
                      key: Key(data.id),
                      startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              deleteTransaction(data.id);
                            },
                            icon: Icons.delete,
                            label: "Delete",
                          )
                        ],
                      ),
                      child: Card(
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
                      ),
                    ),
                  ],
                );
              },
              itemCount: incomeList.length),
        );
      },
    );
  }
}
