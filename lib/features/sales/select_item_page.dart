import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/features/sales/confirm_sale_page.dart';

class SelectItemPage extends StatelessWidget {
  final DateTime saleDate;

  const SelectItemPage({
    super.key,
    required this.saleDate,
  });

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chagua Bidhaa / Huduma'),
      ),
      body: ListView.builder(
        itemCount: business.inventory.length,
        itemBuilder: (context, index) {
          final Product item = business.inventory[index];

          return ListTile(
            leading: Icon(
              item.unit == 'SERVICE'
                  ? Icons.handshake
                  : Icons.inventory_2,
            ),
            title: Text(item.name),
            subtitle: Text(
              item.unit == 'SERVICE'
                  ? 'Huduma'
                  : 'Stock: ${item.stock}',
            ),
            trailing: Text('${item.sellingPrice} TZS'),
            onTap: () => _handleTap(context, item),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, Product item) async {
    final qty = await _askQuantity(context, item);
    if (qty == null) return;

    /// ✅ mounted check - fixes BuildContext async warning
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmSalePage(
          item: item,
          quantity: qty,
          saleDate: saleDate,
        ),
      ),
    );
  }
}

Future<int?> _askQuantity(BuildContext context, Product item) async {
  final controller = TextEditingController(text: '1');

  return showDialog<int>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Idadi ya ${item.name}'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Idadi'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ghairi'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(controller.text) ?? 0;
            Navigator.pop(context, qty > 0 ? qty : null);
          },
          child: const Text('Endelea'),
        ),
      ],
    ),
  );
}