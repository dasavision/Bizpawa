import 'package:flutter/material.dart';
import 'package:bizpawa/models/product.dart';

class EnterQuantityPage extends StatefulWidget {
  final Product item;
  final DateTime saleDate;

  const EnterQuantityPage({
    super.key,
    required this.item,
    required this.saleDate,
  });

  @override
  State<EnterQuantityPage> createState() => _EnterQuantityPageState();
}

class _EnterQuantityPageState extends State<EnterQuantityPage> {
  final TextEditingController _qtyController =
      TextEditingController(text: '1');

  String? _error;

  bool get isService => widget.item.unit == 'SERVICE';

  int get quantity => int.tryParse(_qtyController.text) ?? 1;

  int get subtotal => widget.item.sellingPrice * quantity;

  void _validate() {
    setState(() {
      _error = null;

      if (quantity <= 0) {
        _error = 'Idadi lazima iwe zaidi ya 0';
        return;
      }

      if (!isService && quantity > widget.item.stock) {
        _error = 'Stock haitoshi (${widget.item.stock})';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Idadi ya Mauzo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(widget.item.name),
                subtitle: Text(
                  isService
                      ? 'Huduma'
                      : 'Stock: ${widget.item.stock} ${widget.item.unit}',
                ),
                trailing: Text(
                  '${widget.item.sellingPrice} TZS',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Idadi',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _validate(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jumla ndogo:', style: TextStyle(fontSize: 16)),
                Text(
                  '$subtotal TZS',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _error != null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('STEP 4: Summary inakuja'),
                          ),
                        );
                      },
                child: const Text('Endelea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
