import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/order_item.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);
const _kGreen = Color(0xFF22C55E);

enum _PayType { cash, mobile, bank, credit }

class ScannerCheckoutPage extends StatefulWidget {
  final List<OrderItem> items;

  const ScannerCheckoutPage({super.key, required this.items});

  @override
  State<ScannerCheckoutPage> createState() => _ScannerCheckoutPageState();
}

class _ScannerCheckoutPageState extends State<ScannerCheckoutPage> {
  _PayType? _payType;
  final _discountCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _customerPhone;

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  int get _subtotal =>
      widget.items.fold(0, (sum, item) => sum + item.total);

  int get _discount => int.tryParse(_discountCtrl.text.replaceAll(',', '')) ?? 0;

  int get _total => (_subtotal - _discount).clamp(0, _subtotal);

  void _saveOrder() {
    if (_payType == null) {
      NotificationService.show(
        context: context,
        message: 'Chagua njia ya malipo',
        type: NotificationType.error,
      );
      return;
    }

    if (_payType == _PayType.credit && _customerCtrl.text.trim().isEmpty) {
      NotificationService.show(
        context: context,
        message: 'Weka jina la mteja kwa mkopo',
        type: NotificationType.error,
      );
      return;
    }

    final business = context.read<BusinessState>();
    final auth = context.read<AuthState>();
    final sellerName = auth.currentUser?.name ?? 'Admin';
    final isPaid = _payType != _PayType.credit;

    String? paymentMethod;
    switch (_payType) {
      case _PayType.cash:
        paymentMethod = 'cash';
        break;
      case _PayType.mobile:
        paymentMethod = 'mobile';
        break;
      case _PayType.bank:
        paymentMethod = 'bank';
        break;
      default:
        paymentMethod = null;
    }

    business.recordOrder(
      items: widget.items,
      discount: _discount,
      date: DateTime.now(),
      paid: isPaid,
      sellerName: sellerName,
      customerName: _customerCtrl.text.trim().isEmpty
          ? null
          : _customerCtrl.text.trim(),
      customerPhone: _customerPhone,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      paymentMethod: paymentMethod,
    );

    HapticFeedback.heavyImpact();
    NotificationService.playScanner();

    // Rudi kwenye scanner page na signal ya kukamilika
    Navigator.pop(context, true);
    Navigator.pop(context, true);

    NotificationService.show(
      context: context,
      message: isPaid
          ? 'Mauzo yamehifadhiwa — ${_formatCurrency(_total)} TZS ✓'
          : 'Deni limehifadhiwa kwa ${_customerCtrl.text.trim()}',
      type: NotificationType.success,
    );
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _customerCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Maliza Mauzo',
          style: TextStyle(
              color: _kNavy, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== MUHTASARI WA BIDHAA =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_outlined,
                          color: _kNavy, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Bidhaa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _kNavy,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.items.length} aina',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} × ${_formatCurrency(item.product.sellingPrice)} /=',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_formatCurrency(item.total)} TZS',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _kNavy,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== PUNGUZO =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Punguzo (hiari)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _kNavy,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: 'TZS',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kNavy),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== NJIA YA MALIPO =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Njia ya Malipo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _kNavy,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _payChip('Taslimu', Icons.payments_outlined,
                          _PayType.cash),
                      const SizedBox(width: 8),
                      _payChip('Simu', Icons.phone_android_outlined,
                          _PayType.mobile),
                      const SizedBox(width: 8),
                      _payChip('Benki', Icons.account_balance_outlined,
                          _PayType.bank),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _payChipFull('Mkopo (Deni)', Icons.schedule_outlined,
                      _PayType.credit),

                  // Customer field kwa mkopo
                  if (_payType == _PayType.credit) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerCtrl,
                      decoration: InputDecoration(
                        hintText: 'Jina la mteja...',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: _kNavy, size: 18),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kNavy),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== JUMLA =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kNavy.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _kNavy.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _totalRow('Jumla Ndogo', _subtotal),
                  if (_discount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Punguzo',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13)),
                        Text(
                          '- ${_formatCurrency(_discount)} TZS',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                  ] else
                    const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'JUMLA KUBWA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _kNavy,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(_total)} TZS',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _kNavy,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== HIFADHI BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _payType != null ? _kNavy : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: Text(
                  _payType == null
                      ? 'Chagua Njia ya Malipo'
                      : 'Hifadhi — ${_formatCurrency(_total)} TZS',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _payType != null ? _saveOrder : null,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _payChip(String label, IconData icon, _PayType type) {
    final selected = _payType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _payType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _kNavy : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _kNavy : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : Colors.grey,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payChipFull(String label, IconData icon, _PayType type) {
    final selected = _payType == type;
    return GestureDetector(
      onTap: () => setState(() => _payType = type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? _kOrange.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _kOrange : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? _kOrange : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? _kOrange : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle,
                  color: _kOrange, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 13)),
        Text(
          '${_formatCurrency(amount)} TZS',
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _kNavy),
        ),
      ],
    );
  }
}