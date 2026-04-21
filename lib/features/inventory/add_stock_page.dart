import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/models/stock_batch.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class AddStockPage extends StatefulWidget {
  final Product product;

  const AddStockPage({super.key, required this.product});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  // Batch barcode — auto-generated, inaonyeshwa kwa user
  late String _batchBarcodePreview;

  @override
  void initState() {
    super.initState();
    _buyingPriceController.text =
        _formatCurrency(widget.product.buyingPrice.toString());
    _sellingPriceController.text =
        _formatCurrency(widget.product.sellingPrice.toString());

    // Preview ya barcode itakayotengenezwa kwa batch hii
    // Format: BIZB + batchNumber (2 digits) + digits 8
    final nextBatchNumber = widget.product.batches.length + 1;
    final batchStr = nextBatchNumber.toString().padLeft(2, '0');
    // Tengeneza preview tu — StockBatch itatengeneza yake mwenyewe
    _batchBarcodePreview = 'BIZB$batchStr••••••••';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    final clean = value.replaceAll(',', '');
    final number = int.tryParse(clean);
    if (number == null) return value;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  int get _buyingPrice =>
      int.tryParse(_buyingPriceController.text.replaceAll(',', '')) ?? 0;

  int get _sellingPrice =>
      int.tryParse(_sellingPriceController.text.replaceAll(',', '')) ?? 0;

  int get _quantity => int.tryParse(_quantityController.text) ?? 0;

  bool get _priceIncreased => _buyingPrice > widget.product.buyingPrice;

  double get _priceChangePercent => widget.product.buyingPrice > 0
      ? ((_buyingPrice - widget.product.buyingPrice) /
          widget.product.buyingPrice *
          100)
      : 0;

  @override
  Widget build(BuildContext context) {
    final business = context.read<BusinessState>();
    final nextBatchNumber = widget.product.batches.length + 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ongeza Stock',
          style:
              TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ===== BIDHAA INFO (locked) =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kNavyBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: kNavyBlue.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: kNavyBlue, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bidhaa',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kNavyBlue,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Awamu ya $nextBatchNumber',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== BATCH BARCODE PREVIEW =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.barcode_reader,
                          color: Color(0xFF22C55E), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Barcode ya Batch Hii',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _batchBarcodePreview,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Itatengenezwa auto baada ya kuhifadhi',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== BEI KUNUNUA =====
              _label('Bei ya Kununua'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _buyingPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    _inputDecoration('Bei ya bidhaa moja').copyWith(
                  suffixText: 'TZS',
                ),
                onChanged: (v) {
                  final f = _formatCurrency(v);
                  if (f != v) {
                    _buyingPriceController.value = TextEditingValue(
                      text: f,
                      selection:
                          TextSelection.collapsed(offset: f.length),
                    );
                  }
                  setState(() {});
                },
                validator: (v) {
                  if (v == null || v.replaceAll(',', '').isEmpty) {
                    return 'Bei inahitajika';
                  }
                  return null;
                },
              ),

              // Onyo la bei ikipanda
              if (_priceIncreased && _buyingPrice > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: kOrange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: kOrange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ Bei imeongezeka kwa ${_priceChangePercent.toStringAsFixed(0)}% kuliko awamu ya kwanza',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ===== BEI KUUZA =====
              _label('Bei ya Kuuza'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    _inputDecoration('Bei ya bidhaa moja').copyWith(
                  suffixText: 'TZS',
                ),
                onChanged: (v) {
                  final f = _formatCurrency(v);
                  if (f != v) {
                    _sellingPriceController.value = TextEditingValue(
                      text: f,
                      selection:
                          TextSelection.collapsed(offset: f.length),
                    );
                  }
                  setState(() {});
                },
                validator: (v) {
                  if (v == null || v.replaceAll(',', '').isEmpty) {
                    return 'Bei inahitajika';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ===== IDADI =====
              _label('Idadi ya Stock Mpya'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('0'),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Idadi inahitajika';
                  if ((int.tryParse(v) ?? 0) <= 0) {
                    return 'Idadi lazima iwe zaidi ya 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ===== SUMMARY =====
              if (_quantity > 0 && _buyingPrice > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kNavyBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: kNavyBlue.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Muhtasari wa Awamu Mpya',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kNavyBlue,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _summaryRow(
                        'Jumla ya manunuzi',
                        '${_formatCurrency((_quantity * _buyingPrice).toString())} TZS',
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Faida inayotarajiwa',
                        '${_formatCurrency(((_sellingPrice - _buyingPrice) * _quantity).toString())} TZS',
                        color: const Color(0xFF22C55E),
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Barcode ya batch',
                        'Itatengenezwa auto ✓',
                        color: const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ===== HIFADHI =====
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNavyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'Hifadhi Stock',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _save(business),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BusinessState business) {
    if (!_formKey.currentState!.validate()) return;

    // StockBatch itatengeneza batchBarcodeId yake mwenyewe (auto)
    final batch = StockBatch(
      batchNumber: widget.product.batches.length + 1,
      quantity: _quantity,
      buyingPrice: _buyingPrice,
      sellingPrice: _sellingPrice,
      date: DateTime.now(),
      remainingStock: _quantity,
      // batchBarcodeId inagenerate auto ndani ya StockBatch constructor
    );

    business.addStockBatch(widget.product, batch);

    NotificationService.show(
      context: context,
      message:
          'Stock imeongezwa — ${batch.batchName} ya ${widget.product.name} (Barcode: ${batch.batchBarcodeId})',
      type: NotificationType.success,
    );

    Navigator.pop(context);
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kNavyBlue,
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? kNavyBlue,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNavyBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}