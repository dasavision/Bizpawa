import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 2)
class Customer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? address;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });
}