import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_manager/db/category/category_db.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/screens/category/screen_category.dart';
import 'package:money_manager/screens/home/screen_home.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  DateTime? selectedDate;
  String? selectedCategoryType;
  @override
  void initState() {
    selectedCategoryType = "income";
    super.initState();
  }

  TextEditingController purposeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextFormField(
                    controller: purposeController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      hintText: "Purpose",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      hintText: "Amount",
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final selectedDateTemp = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          Duration(days: 900),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDateTemp == null) {
                        return;
                      } else {
                        setState(() {
                          selectedDate = selectedDateTemp;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text(selectedDate == null
                        ? "Select date"
                        : selectedDate.toString()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: "income",
                            groupValue: selectedCategoryType,
                            onChanged: (newValue) {
                              setState(() {
                                selectedCategoryType = "income";
                              });
                            },
                          ),
                          Text("Income"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: "expense",
                            groupValue: selectedCategoryType,
                            onChanged: (newValue) {
                              setState(() {
                                selectedCategoryType = "expense";
                              });
                            },
                          ),
                          Text("Expense"),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      submit();
                    },
                    child: Text("submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    final purpose = purposeController.text;
    final amount = amountController.text;

    if (purpose == "") {
      Fluttertoast.showToast(msg: "Please enter purpose");
    } else if (amount == "") {
      Fluttertoast.showToast(msg: "Please enter amount");
    } else if (selectedDate == null) {
      Fluttertoast.showToast(msg: "Please select a date");
    } else {
      final category = CategoryModel(
          id: DateTime.now().toString(),
          purpose: purpose,
          amount: double.parse(amount),
          categoryType: selectedCategoryType!,
          dateTime: selectedDate!);
      addCategory(category);
      Navigator.of(context).pop();
    }
  }
}
