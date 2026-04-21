import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/models/order_item.dart';
import 'select_product_page.dart';
import 'select_customer_page.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

enum PaymentType { paid, unpaid }
enum PaymentMethod { cash, mobile, bank }

class OrderPage extends StatefulWidget {
  final bool openScanner;
  const OrderPage({super.key, this.openScanner = false});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCustomerPhone;
  DateTime _date = DateTime.now();
  PaymentType? _paymentType;
  PaymentMethod? _paymentMethod;
  bool _showNote = false;
  bool _showDiscount = false;

  final List<OrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.openScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openScanner());
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  int get _discount =>
      int.tryParse(_discountController.text.replaceAll(',', '')) ?? 0;

  int get subtotal =>
      _items.fold<int>(0, (sum, item) => sum + item.total);

  int get total {
    final v = subtotal - _discount;
    return v < 0 ? 0 : v;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _selectCustomer() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(builder: (_) => const SelectCustomerPage()),
    );
    if (customer != null && mounted) {
      setState(() {
        _customerController.text = customer.name;
        _selectedCustomerPhone = customer.phone;
      });
    }
  }

  void _openScanner() {
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white30,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('Scan Barcode ya Bidhaa',
                style: TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Elekeza kamera kwenye barcode',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          final raw = capture.barcodes.firstOrNull?.rawValue;
                          if (raw != null) {
                            controller.dispose();
                            Navigator.pop(context);
                            NotificationService.playScanner();
                            final business = context.read<BusinessState>();
                            final found = business.inventory
                                .where((p) => p.barcodeId == raw || p.id == raw)
                                .firstOrNull;
                            if (found != null) {
                              _showQuantityDialog(found);
                            } else {
                              NotificationService.show(
                                context: context,
                                message: 'Bidhaa haikupatikana kwa barcode hii',
                                type: NotificationType.error,
                              );
                            }
                          }
                        },
                      ),
                      Container(color: Colors.black45),
                      Center(
                        child: Container(
                          width: 280, height: 120,
                          decoration: BoxDecoration(
                              border: Border.all(color: kOrange, width: 2.5),
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Container(
                              height: 2, width: 260,
                              color: kOrange.withValues(alpha: 0.6))),
                        ),
                      ),
                      Positioned(
                        bottom: 16, right: 16,
                        child: GestureDetector(
                          onTap: () => controller.toggleTorch(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white24,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.flashlight_on,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () { controller.dispose(); Navigator.pop(context); },
              child: const Text('Ghairi', style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProduct() async {
    final product = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => const SelectProductPage()),
    );
    if (product != null && mounted) _showQuantityDialog(product);
  }

  void _showQuantityDialog(Product product) {
    final qtyController = TextEditingController();
    final isService = product.unit == 'SERVICE';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kNavyBlue.withValues(alpha: 0.08),
                    image: product.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(product.imagePath!)),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: product.imagePath == null
                      ? Icon(isService ? Icons.handyman : Icons.inventory_2,
                          color: kNavyBlue, size: 22)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16,
                        color: kNavyBlue)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('${_formatCurrency(product.sellingPrice)} TZS',
                          style: const TextStyle(fontWeight: FontWeight.w600,
                              color: kNavyBlue)),
                      if (!isService) ...[
                        Text(' • ${product.stock} ${product.unit}',
                            style: TextStyle(fontSize: 12,
                                color: product.stock <= 5
                                    ? kOrange : Colors.grey.shade500)),
                      ],
                    ]),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Idadi Uliyouza', style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w600, color: kNavyBlue)),
            const SizedBox(height: 6),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '0',
                suffixText: isService ? '' : product.unit,
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kNavyBlue)),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: qtyController,
              builder: (context, value, _) {
                final qty = int.tryParse(qtyController.text) ?? 0;
                final canSave = qty > 0 && (isService || qty <= product.stock);
                return Column(children: [
                  if (!isService && qty > product.stock && qty > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.warning, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text('Stock haitoshi! Iliyobaki: ${product.stock}',
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ]),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: canSave ? kNavyBlue : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: canSave ? () {
                        Navigator.pop(context);
                        setState(() {
                          final existing = _items.indexWhere(
                              (i) => i.product.id == product.id);
                          if (existing != -1) {
                            _items[existing].quantity += qty;
                          } else {
                            _items.add(OrderItem(product: product, quantity: qty));
                          }
                        });
                      } : null,
                      child: const Text('Ongeza kwenye Oda',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ]);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet() {
    if (_items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Hali ya Malipo', style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold, color: kNavyBlue)),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => setModal(() => _paymentType = PaymentType.paid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _paymentType == PaymentType.paid
                          ? const Color(0xFF22C55E) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _paymentType == PaymentType.paid
                          ? const Color(0xFF22C55E) : Colors.grey.shade200),
                    ),
                    child: Column(children: [
                      Icon(Icons.check_circle_outline,
                          color: _paymentType == PaymentType.paid
                              ? Colors.white : Colors.grey, size: 24),
                      const SizedBox(height: 4),
                      Text('Imelipiwa', style: TextStyle(fontWeight: FontWeight.bold,
                          color: _paymentType == PaymentType.paid
                              ? Colors.white : Colors.grey.shade600)),
                    ]),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
                  onTap: () => setModal(() => _paymentType = PaymentType.unpaid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _paymentType == PaymentType.unpaid
                          ? kOrange : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _paymentType == PaymentType.unpaid
                          ? kOrange : Colors.grey.shade200),
                    ),
                    child: Column(children: [
                      Icon(Icons.schedule,
                          color: _paymentType == PaymentType.unpaid
                              ? Colors.white : Colors.grey, size: 24),
                      const SizedBox(height: 4),
                      Text('Haijalipiwa', style: TextStyle(fontWeight: FontWeight.bold,
                          color: _paymentType == PaymentType.unpaid
                              ? Colors.white : Colors.grey.shade600)),
                    ]),
                  ),
                )),
              ]),

              const SizedBox(height: 16),

              if (_paymentType == PaymentType.paid) ...[
                const Text('Njia ya Malipo', style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: kNavyBlue)),
                const SizedBox(height: 10),
                Row(children: [
                  _payMethodChip('Cash', Icons.payments_outlined,
                      PaymentMethod.cash, setModal),
                  const SizedBox(width: 8),
                  _payMethodChip('Simu', Icons.phone_android,
                      PaymentMethod.mobile, setModal),
                  const SizedBox(width: 8),
                  _payMethodChip('Benki', Icons.account_balance_outlined,
                      PaymentMethod.bank, setModal),
                ]),
                const SizedBox(height: 16),
              ],

              if (_paymentType == PaymentType.unpaid) ...[
                const Text('Jina la Mteja (lazima)', style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: kNavyBlue)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _selectCustomer();
                    if (mounted) _showPaymentSheet();
                  },
                  child: Container(
                    width: double.infinity, padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _customerController.text.isNotEmpty
                          ? kNavyBlue : Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Icon(Icons.person_outline,
                          color: _customerController.text.isNotEmpty
                              ? kNavyBlue : Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                          _customerController.text.isNotEmpty
                              ? _customerController.text : 'Chagua Mteja...',
                          style: TextStyle(
                              color: _customerController.text.isNotEmpty
                                  ? kNavyBlue : Colors.grey.shade400,
                              fontWeight: _customerController.text.isNotEmpty
                                  ? FontWeight.w600 : FontWeight.normal))),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_paymentType != null) ...[
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kNavyBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    _summaryRow('Jumla ndogo', '${_formatCurrency(subtotal)} TZS'),
                    if (_discount > 0) ...[
                      const SizedBox(height: 4),
                      _summaryRow('Punguzo',
                          '- ${_formatCurrency(_discount)} TZS', color: Colors.red),
                    ],
                    const Divider(height: 16),
                    _summaryRow('JUMLA', '${_formatCurrency(total)} TZS',
                        bold: true, color: kNavyBlue),
                  ]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: kNavyBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Hifadhi Mauzo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    onPressed: () => _saveOrder(context),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payMethodChip(String label, IconData icon,
      PaymentMethod method, StateSetter setModal) {
    final selected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModal(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kNavyBlue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? kNavyBlue : Colors.grey.shade200),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade600)),
          ]),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value, style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color ?? kNavyBlue)),
      ],
    );
  }

  // ✅ FIX: sellerName inatoka AuthState — jina la mtumiaji aliyeingia
  void _saveOrder(BuildContext context) {
    if (_paymentType == null) return;

    if (_paymentType == PaymentType.paid && _paymentMethod == null) {
      NotificationService.show(context: context,
          message: 'Chagua njia ya malipo', type: NotificationType.error);
      return;
    }

    if (_paymentType == PaymentType.unpaid &&
        _customerController.text.trim().isEmpty) {
      NotificationService.show(context: context,
          message: 'Chagua mteja kwa mauzo ya mkopo', type: NotificationType.error);
      return;
    }

    final business = context.read<BusinessState>();
    final auth = context.read<AuthState>();
    final isPaid = _paymentType == PaymentType.paid;

    // ✅ Pata jina la mtumiaji aliyeingia (Admin au Muuzaji)
    final currentSellerName = auth.currentUser?.name ?? 'Admin';

    business.recordOrder(
      items: _items,
      discount: _discount,
      date: _date,
      paid: isPaid,
      sellerName: currentSellerName, // ✅ jina halisi badala ya 'Admin'
      customerName: _customerController.text.trim().isEmpty
          ? null : _customerController.text.trim(),
      customerPhone: _selectedCustomerPhone,
      note: _noteController.text.trim().isEmpty
          ? null : _noteController.text.trim(),
      paymentMethod: _paymentMethod?.name,
    );

    Navigator.pop(context);
    Navigator.pop(context);

    NotificationService.show(
      context: context,
      message: isPaid
          ? 'Mauzo yamehifadhiwa — ${_formatCurrency(total)} TZS'
          : 'Deni limehifadhiwa kwa ${_customerController.text.trim()}',
      type: NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Oda Mpya',
            style: TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: kNavyBlue),
            onPressed: _openScanner,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(children: [
                GestureDetector(
                  onTap: _selectCustomer,
                  child: Row(children: [
                    Icon(Icons.person_outline, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                        _customerController.text.isEmpty
                            ? 'Chagua Mteja (hiari)' : _customerController.text,
                        style: TextStyle(
                            color: _customerController.text.isEmpty
                                ? Colors.grey.shade400 : Colors.grey.shade700,
                            fontWeight: _customerController.text.isEmpty
                                ? FontWeight.normal : FontWeight.w600))),
                    if (_customerController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _customerController.clear();
                          _selectedCustomerPhone = null;
                        }),
                        child: Icon(Icons.close, size: 16, color: Colors.grey.shade400))
                    else
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                  ]),
                ),
                Divider(color: Colors.grey.shade100),
                GestureDetector(
                  onTap: _pickDate,
                  child: Row(children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 12),
                    Text('Tarehe: ${_date.day}/${_date.month}/${_date.year}',
                        style: TextStyle(color: Colors.grey.shade500)),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 20),

            if (_items.isNotEmpty) ...[
              const Text('Bidhaa za Oda', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: kNavyBlue)),
              const SizedBox(height: 10),
              ..._items.map((item) => _orderItemCard(item)),
              const SizedBox(height: 16),
            ],

            GestureDetector(
              onTap: _selectProduct,
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kNavyBlue,
                    borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text('Chagua Bidhaa au Huduma Uliyouza',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),

            if (_items.isNotEmpty) ...[
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => setState(() => _showDiscount = !_showDiscount),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _showDiscount
                          ? kNavyBlue : Colors.grey.shade200)),
                  child: Row(children: [
                    Icon(Icons.discount_outlined,
                        color: _showDiscount ? kNavyBlue : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Text(_discount > 0
                        ? 'Punguzo: ${_formatCurrency(_discount)} TZS'
                        : 'Ongeza Punguzo (hiari)',
                        style: TextStyle(color: _showDiscount
                            ? kNavyBlue : Colors.grey.shade600)),
                    const Spacer(),
                    Icon(_showDiscount ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down, color: Colors.grey),
                  ]),
                ),
              ),

              if (_showDiscount) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0', suffixText: 'TZS',
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kNavyBlue)),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => setState(() => _showNote = !_showNote),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _showNote
                          ? kNavyBlue : Colors.grey.shade200)),
                  child: Row(children: [
                    Icon(_showNote ? Icons.notes : Icons.add_circle_outline,
                        color: _showNote ? kNavyBlue : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Text('Maelezo ya Ziada (hiari)',
                        style: TextStyle(color: _showNote
                            ? kNavyBlue : Colors.grey.shade600)),
                    const Spacer(),
                    Icon(_showNote ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down, color: Colors.grey),
                  ]),
                ),
              ),

              if (_showNote) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController, maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Andika maelezo...',
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kNavyBlue)),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(children: [
                  _summaryRow('Jumla ndogo', '${_formatCurrency(subtotal)} TZS'),
                  if (_discount > 0) ...[
                    const SizedBox(height: 6),
                    _summaryRow('Punguzo',
                        '- ${_formatCurrency(_discount)} TZS', color: Colors.red),
                  ],
                  const Divider(height: 16),
                  _summaryRow('JUMLA', '${_formatCurrency(total)} TZS',
                      bold: true, color: kNavyBlue),
                ]),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: kNavyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Hifadhi Mauzo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  onPressed: _showPaymentSheet,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _orderItemCard(OrderItem item) {
    final isService = item.product.unit == 'SERVICE';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: kNavyBlue.withValues(alpha: 0.08),
            image: item.product.imagePath != null
                ? DecorationImage(image: FileImage(File(item.product.imagePath!)),
                    fit: BoxFit.cover)
                : null,
          ),
          child: item.product.imagePath == null
              ? Icon(isService ? Icons.handyman : Icons.inventory_2,
                  color: kNavyBlue, size: 18)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.product.name, style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13, color: kNavyBlue)),
            Text(isService
                ? '${_formatCurrency(item.product.sellingPrice)} TZS × ${item.quantity}'
                : '${_formatCurrency(item.product.sellingPrice)} TZS × ${item.quantity} ${item.product.unit}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        )),
        Row(children: [
          if (item.quantity > 1)
            GestureDetector(
              onTap: () => setState(() => item.quantity--),
              child: Container(width: 28, height: 28,
                  decoration: BoxDecoration(color: Colors.grey.shade100,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.remove, size: 14))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(item.quantity.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          GestureDetector(
            onTap: () {
              if (isService || item.quantity < item.product.stock) {
                setState(() => item.quantity++);
              }
            },
            child: Container(width: 28, height: 28,
                decoration: BoxDecoration(color: kNavyBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.add, size: 14, color: kNavyBlue))),
        ]),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${_formatCurrency(item.total)} TZS',
              style: const TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 12, color: kNavyBlue)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _items.remove(item)),
            child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 18)),
        ]),
      ]),
    );
  }
}