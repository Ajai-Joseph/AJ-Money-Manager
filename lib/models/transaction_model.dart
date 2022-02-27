import 'package:hive_flutter/adapters.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class TransactionModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double totalIncome;
  @HiveField(2)
  final double totalExpense;

  TransactionModel({
    required this.id,
    required this.totalIncome,
    required this.totalExpense,
  });
}
