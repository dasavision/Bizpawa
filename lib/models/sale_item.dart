import 'product.dart';

class SaleItem {
  final Product product;
  int quantity;
  int sellingPrice;

  SaleItem({
    required this.product,
    required this.quantity,
    required this.sellingPrice,
  });

  int get subtotal => quantity * sellingPrice;
}
