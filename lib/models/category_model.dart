import 'package:hive_flutter/adapters.dart';
part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String purpose;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String categoryType;
  @HiveField(4)
  final DateTime dateTime;
  CategoryModel(
      {required this.id,
      required this.purpose,
      required this.amount,
      required this.categoryType,
      required this.dateTime});
}
