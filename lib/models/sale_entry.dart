import 'package:hive/hive.dart';

part 'sale_entry.g.dart';

@HiveType(typeId: 6)
class DebtPayment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final String paymentMethod;

  @HiveField(3)
  final DateTime date;

  DebtPayment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.date,
  });
}

@HiveType(typeId: 7)
class SaleItemEntry {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final int sellingPrice;

  @HiveField(5)
  final int buyingPrice;

  SaleItemEntry({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.sellingPrice,
    this.buyingPrice = 0,
  });

  int get subtotal => quantity * sellingPrice;
  int get cogs => quantity * buyingPrice;
  int get grossProfit => subtotal - cogs;
}

@HiveType(typeId: 8)
class RefundItem {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final int sellingPrice;

  @HiveField(5)
  final int buyingPrice;

  RefundItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.sellingPrice,
    this.buyingPrice = 0,
  });

  int get subtotal => quantity * sellingPrice;
  int get cogs => quantity * buyingPrice;
}

@HiveType(typeId: 9)
class RefundEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String originalOrderNumber;

  @HiveField(2)
  final List<RefundItem> items;

  @HiveField(3)
  final int refundAmount;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String reason;

  RefundEntry({
    required this.id,
    required this.originalOrderNumber,
    required this.items,
    required this.refundAmount,
    required this.date,
    required this.reason,
  });
}

@HiveType(typeId: 10)
class SaleEntry {
  @HiveField(0)
  final String orderNumber;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool paid;

  @HiveField(5)
  final int paidAmount;

  @HiveField(6)
  final String? customerName;

  @HiveField(7)
  final String? customerPhone;

  @HiveField(8)
  final String sellerName;

  @HiveField(9)
  final int discount;

  @HiveField(10)
  final String? note;

  @HiveField(11)
  final String? paymentMethod;

  @HiveField(12)
  final List<SaleItemEntry> items;

  @HiveField(13)
  final List<DebtPayment> payments;

  @HiveField(14)
  final bool isRefunded;

  @HiveField(15)
  final int refundAmount;

  @HiveField(16)
  final int totalCogs;

  SaleEntry({
    required this.orderNumber,
    required this.productName,
    required this.amount,
    required this.date,
    required this.paid,
    this.paidAmount = 0,
    this.customerName,
    this.customerPhone,
    this.sellerName = 'Admin',
    this.discount = 0,
    this.note,
    this.paymentMethod,
    this.items = const [],
    this.payments = const [],
    this.isRefunded = false,
    this.refundAmount = 0,
    this.totalCogs = 0,
  });

  int get remainingAmount => amount - paidAmount;
  double get paymentProgress =>
      amount == 0 ? 1.0 : (paidAmount / amount).clamp(0.0, 1.0);
  bool get hasPartialRefund => refundAmount > 0 && !isRefunded;
  int get grossProfit => amount - totalCogs;
}