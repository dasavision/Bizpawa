import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/core/state/business_state.dart';

class ConfirmSalePage extends StatefulWidget {
  final Product item;
  final int quantity;
  final DateTime saleDate;

  const ConfirmSalePage({
    super.key,
    required this.item,
    required this.quantity,
    required this.saleDate,
  });

  @override
  State<ConfirmSalePage> createState() => _ConfirmSalePageState();
}

class _ConfirmSalePageState extends State<ConfirmSalePage> {
  final _discountController = TextEditingController();
  bool _isPaid = true;

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.item.sellingPrice * widget.quantity;
    final discount = int.tryParse(_discountController.text) ?? 0;
    final total = subtotal - discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakiki Mauzo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Idadi: ${widget.quantity}'),
            Text('Bei: ${widget.item.sellingPrice} TZS'),

            const Divider(height: 32),

            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Punguzo (hiari)',
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isPaid ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _isPaid = true);
                    },
                    child: const Text('IMELIPWA'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isPaid ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _isPaid = false);
                    },
                    child: const Text('HAIJALIPWA'),
                  ),
                ),
              ],
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumla ndogo: $subtotal TZS'),
                  Text('Punguzo: $discount TZS'),
                  const SizedBox(height: 4),
                  Text(
                    'JUMLA: $total TZS',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<BusinessState>().recordSale(
                        product: widget.item,
                        quantity: widget.quantity,
                        discount: discount,
                        date: widget.saleDate,
                        paid: _isPaid,
                      );

                  Navigator.popUntil(context, (r) => r.isFirst);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Mauzo Yamefanyika'),
                    ),
                  );
                },
                child: const Text('HIFADHI MAUZO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
