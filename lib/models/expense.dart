import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 3)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String recordedBy;

  @HiveField(5)
  final String? note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.recordedBy = 'Admin',
    this.note,
  });
}