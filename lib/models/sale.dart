import 'order_item.dart';

class Sale {
  final String? customer;
  final List<OrderItem> items;
  final DateTime date;
  final bool paid;
  final int discount;
  final String note;

  Sale({
    this.customer,
    required this.items,
    required this.date,
    required this.paid,
    required this.discount,
    required this.note,
  });

  int get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get total {
    final value = subtotal - discount;
    return value < 0 ? 0 : value;
  }
}