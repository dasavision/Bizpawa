import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 4)
class SupplierPayment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final String method;

  @HiveField(3)
  final DateTime date;

  SupplierPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
  });
}

@HiveType(typeId: 5)
class Supplier {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String businessName;

  @HiveField(4)
  final int totalDebt;

  @HiveField(5)
  final int paidAmount;

  @HiveField(6)
  final List<SupplierPayment> payments;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.businessName,
    required this.totalDebt,
    required this.paidAmount,
    this.payments = const [],
  });

  int get remainingDebt => totalDebt - paidAmount;
}