import 'order_item.dart';

enum PaymentMethod { cash, mobile, bank }
enum OrderStatus { paid, unpaid, reconciled }

class Order {
  final String id;
  final DateTime date;
  final String? customer;
  final List<OrderItem> items;
  final int discount;
  final String note;
  final OrderStatus status;
  final PaymentMethod? paymentMethod;

  Order({
    required this.id,
    required this.date,
    required this.items,
    this.customer,
    this.discount = 0,
    this.note = '',
    required this.status,
    this.paymentMethod,
  });

  int get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get total => subtotal - discount;
}
