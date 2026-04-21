import 'sale_item.dart';

enum PaymentStatus {
  paid,
  unpaid,
}

enum PaymentMethod {
  cash,
  mobile,
  bank,
}

class SaleOrder {
  final String id;
  final DateTime date;
  String? customerName;
  String sellerName;

  PaymentStatus status;
  PaymentMethod? paymentMethod;

  int discount;
  String? notes;

  final List<SaleItem> items;

  SaleOrder({
    required this.id,
    required this.date,
    required this.sellerName,
    this.customerName,
    this.status = PaymentStatus.paid,
    this.paymentMethod,
    this.discount = 0,
    this.notes,
    List<SaleItem>? items,
  }) : items = items ?? [];

  int get subtotal =>
      items.fold(0, (sum, i) => sum + i.subtotal);

  int get total => subtotal - discount;

  int get totalItems =>
      items.fold(0, (sum, i) => sum + i.quantity);
}
