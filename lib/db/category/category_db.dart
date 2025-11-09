import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/models/transaction_model.dart';

const CATEGORY_DB_NAME = "category-database";
const TRANSACTION_DB_NAME = "transaction-database";

// abstract class CategoryDbFunctons {
//   Future<List<CategoryModel>> getCategoryModel();
//   Future<void> insertCategory(CategoryModel value);
// }

// class CategoryDB implements CategoryDbFunctons {
//   @override
//   Future<void> insertCategory(CategoryModel value) async {
//     final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
//     await categoryDB.add(value);
//   }

//   @override
//   Future<List<CategoryModel>> getCategoryModel() async {
//     final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
//     return categoryDB.values.toList();
//   }
// }
ValueNotifier<List<CategoryModel>> incomeCategoryListNotifier =
    ValueNotifier([]);
ValueNotifier<List<CategoryModel>> expenseCategoryListNotifier =
    ValueNotifier([]);
ValueNotifier<List<TransactionModel>> monthlyTransactionListNotifier =
    ValueNotifier([]);

Future<void> addCategory(CategoryModel value) async {
  final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
  categoryDB.put(value.id, value);
  if (value.categoryType == "income") {
    incomeCategoryListNotifier.value.add(value);

    incomeCategoryListNotifier.notifyListeners();
  } else {
    expenseCategoryListNotifier.value.add(value);

    expenseCategoryListNotifier.notifyListeners();
  }
}

Future<void> getCategory(String type) async {
  final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
  if (type == "income") {
    incomeCategoryListNotifier.value.clear();
    List incomeList = categoryDB.values.toList();
    for (int i = 0; i < incomeList.length; i++) {
      if (incomeList[i].categoryType == "income") {
        incomeCategoryListNotifier.value.add(incomeList[i]);
      }
    }
    incomeCategoryListNotifier.value.sort((a, b) {
      return b.dateTime.compareTo(a.dateTime);
    });
    incomeCategoryListNotifier.notifyListeners();
  } else {
    expenseCategoryListNotifier.value.clear();
    List expenseList = categoryDB.values.toList();
    for (int i = 0; i < expenseList.length; i++) {
      if (expenseList[i].categoryType == "expense") {
        expenseCategoryListNotifier.value.add(expenseList[i]);
      }
    }
    expenseCategoryListNotifier.value.sort((a, b) {
      return b.dateTime.compareTo(a.dateTime);
    });

    expenseCategoryListNotifier.notifyListeners();
  }
  print("income: ${incomeCategoryListNotifier.value}");
  print("expense: ${expenseCategoryListNotifier.value}");
}

Future<void> deleteTransaction(String id) async {
  final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
  categoryDB.delete(id);
  final transactonDB =
      await Hive.openBox<TransactionModel>(TRANSACTION_DB_NAME);
  transactonDB.deleteFromDisk();
  getCategory("income");
  getMonthlyTransaction();
}

Future<void> getMonthlyTransaction() async {
  late int i, j, k, flag;
  double totalIncome, totalExpense;
  late String month;

  Set<String> checkedMonth = {};

  Set<CategoryModel> set = {};
  Map<String, Set<CategoryModel>> map = {};
  final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);

  List categoryList = categoryDB.values.toList();
  categoryList.sort((a, b) {
    return b.dateTime.compareTo(a.dateTime);
  });

  monthlyTransactionListNotifier.value.clear();
  for (i = 0; i < categoryList.length; i++) {
    flag = 0;
    for (k = 0; k < checkedMonth.length; k++) {
      if (DateFormat.yMMM().format(categoryList[i].dateTime) ==
          checkedMonth.elementAt(k)) {
        flag = 1;
      }
    }
    if (flag == 0) {
      month = DateFormat.yMMM().format(categoryList[i].dateTime);
      set.add(categoryList[i]);
      for (j = i + 1; j < categoryList.length; j++) {
        if (month == (DateFormat.yMMM().format(categoryList[j].dateTime))) {
          set.add(categoryList[j]);
        }
      }
      map[month] = set;
      checkedMonth.add(month);
    }
    set = {};
  }

  for (i = 0; i < checkedMonth.length; i++) {
    totalIncome = 0;
    totalExpense = 0;
    for (j = 0; j < map[checkedMonth.elementAt(i)]!.length; j++) {
      if (map[checkedMonth.elementAt(i)]!.elementAt(j).categoryType ==
          "income") {
        totalIncome =
            totalIncome + map[checkedMonth.elementAt(i)]!.elementAt(j).amount;
      } else {
        totalExpense =
            totalExpense + map[checkedMonth.elementAt(i)]!.elementAt(j).amount;
      }
    }

    final transaction = TransactionModel(
        id: checkedMonth.elementAt(i),
        totalIncome: totalIncome,
        totalExpense: totalExpense);
    final transactionDB =
        await Hive.openBox<TransactionModel>(TRANSACTION_DB_NAME);
    transactionDB.put(transaction.id, transaction);

    monthlyTransactionListNotifier.value.add(transaction);

    monthlyTransactionListNotifier.notifyListeners();
  }
  final transactionDB =
      await Hive.openBox<TransactionModel>(TRANSACTION_DB_NAME);
  monthlyTransactionListNotifier.value.clear();

  List sortTransacion = transactionDB.values.toList();
  print("monthy: ${sortTransacion.length}");
  sortTransacion.sort((a, b) {
    return DateFormat.yMMM()
        .parse(b.id)
        .compareTo(DateFormat.yMMM().parse(a.id));
  });

  for (i = 0; i < sortTransacion.length; i++) {
    monthlyTransactionListNotifier.value.add(sortTransacion[i]);
  }
  monthlyTransactionListNotifier.notifyListeners();
}
