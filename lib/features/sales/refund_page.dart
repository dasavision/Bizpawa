import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class RefundPage extends StatefulWidget {
  final SaleEntry order;

  const RefundPage({super.key, required this.order});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  // Map ya productId → quantity ya kurudisha
  final Map<String, int> _refundQuantities = {};
  String _reason = 'Bidhaa ilirudishwa';
  final _reasonCtrl = TextEditingController(
      text: 'Bidhaa ilirudishwa');

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  void initState() {
    super.initState();
    // Default: bidhaa zote zimerudishwa (full refund)
    for (final item in widget.order.items) {
      _refundQuantities[item.productId] = item.quantity;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  int get _totalRefundAmount {
    int total = 0;
    for (final item in widget.order.items) {
      final qty = _refundQuantities[item.productId] ?? 0;
      total += qty * item.sellingPrice;
    }
    return total;
  }

  bool get _isFullRefund =>
      _totalRefundAmount >= widget.order.amount;

  bool get _hasAnything =>
      _refundQuantities.values.any((q) => q > 0);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Refund',
              style: TextStyle(
                color: _kNavy,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.order.orderNumber,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== TYPE BADGE =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isFullRefund
                    ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                    : _kOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isFullRefund
                      ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                      : _kOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isFullRefund
                        ? Icons.assignment_return_outlined
                        : Icons.remove_shopping_cart_outlined,
                    color: _isFullRefund
                        ? const Color(0xFFEF4444)
                        : _kOrange,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFullRefund
                              ? 'Full Refund'
                              : 'Partial Refund',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _isFullRefund
                                ? const Color(0xFFEF4444)
                                : _kOrange,
                          ),
                        ),
                        Text(
                          _isFullRefund
                              ? 'Bidhaa zote zinarudishwa'
                              : 'Sehemu ya bidhaa inarudishwa',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_fmt(_totalRefundAmount)} TZS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _isFullRefund
                          ? const Color(0xFFEF4444)
                          : _kOrange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== BIDHAA ZA KURUDISHA =====
            const Text(
              'Chagua Bidhaa za Kurudisha',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Punguza idadi kwa partial refund, acha 0 kama haijarudishwa',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 12),

            ...widget.order.items.map((item) {
              final currentQty =
                  _refundQuantities[item.productId] ?? 0;
              final isService = item.unit == 'SERVICE';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: currentQty > 0
                      ? Border.all(
                          color: const Color(0xFFEF4444)
                              .withValues(alpha: 0.3))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: currentQty > 0
                                ? const Color(0xFFEF4444)
                                    .withValues(alpha: 0.1)
                                : _kNavy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            isService
                                ? Icons.design_services_outlined
                                : Icons.inventory_2_outlined,
                            color: currentQty > 0
                                ? const Color(0xFFEF4444)
                                : _kNavy,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _kNavy,
                                ),
                              ),
                              Text(
                                '${item.quantity} ${item.unit} × ${_fmt(item.sellingPrice)} TZS',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_fmt(currentQty * item.sellingPrice)} TZS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: currentQty > 0
                                ? const Color(0xFFEF4444)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Quantity controls
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Idadi ya kurudisha:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Row(
                          children: [
                            // Minus button
                            GestureDetector(
                              onTap: currentQty > 0
                                  ? () => setState(() {
                                        _refundQuantities[
                                            item.productId] =
                                            currentQty - 1;
                                      })
                                  : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: currentQty > 0
                                      ? const Color(0xFFEF4444)
                                          .withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: currentQty > 0
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),

                            // Quantity display
                            Container(
                              width: 44,
                              alignment: Alignment.center,
                              child: Text(
                                '$currentQty',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: currentQty > 0
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),

                            // Plus button
                            GestureDetector(
                              onTap: currentQty < item.quantity
                                  ? () => setState(() {
                                        _refundQuantities[
                                            item.productId] =
                                            currentQty + 1;
                                      })
                                  : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: currentQty < item.quantity
                                      ? _kNavy.withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: currentQty < item.quantity
                                      ? _kNavy
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Max indicator
                    if (currentQty == item.quantity)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.check_circle,
                                size: 12,
                                color: const Color(0xFFEF4444)),
                            const SizedBox(width: 4),
                            Text(
                              'Yote inarudishwa',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // ===== SABABU =====
            const Text(
              'Sababu ya Kurudisha',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 10),

            // Quick reason chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Bidhaa ilirudishwa',
                'Bidhaa iliharibika',
                'Mteja alibadilika mawazo',
                'Bidhaa si sahihi',
              ].map((r) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _reason = r;
                        _reasonCtrl.text = r;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _reason == r
                            ? _kNavy
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _reason == r
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )).toList(),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _reasonCtrl,
              onChanged: (v) => setState(() => _reason = v),
              decoration: InputDecoration(
                hintText: 'Au andika sababu nyingine...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kNavy),
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM BUTTON =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isFullRefund ? 'Full Refund:' : 'Partial Refund:',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_fmt(_totalRefundAmount)} TZS',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasAnything
                      ? const Color(0xFFEF4444)
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                    Icons.assignment_return_outlined,
                    size: 20),
                label: Text(
                  _isFullRefund
                      ? 'Thibitisha Full Refund'
                      : 'Thibitisha Partial Refund',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed:
                    _hasAnything ? () => _confirm(context) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          _isFullRefund ? 'Thibitisha Full Refund' : 'Thibitisha Partial Refund',
          style: const TextStyle(
              color: _kNavy, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kiasi cha kurudisha: ${_fmt(_totalRefundAmount)} TZS',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock itarudishwa automatically kwa bidhaa zote zilizochaguliwa.',
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final business = context.read<BusinessState>();

              // FIX: Ongeza buyingPrice kutoka item — muhimu kwa COGS correction
              final refundItems = widget.order.items
                  .where((item) =>
                      (_refundQuantities[item.productId] ?? 0) > 0)
                  .map((item) => RefundItem(
                        productId: item.productId,
                        productName: item.productName,
                        unit: item.unit,
                        quantity: _refundQuantities[item.productId]!,
                        sellingPrice: item.sellingPrice,
                        buyingPrice: item.buyingPrice, // ← FIX HAPA
                      ))
                  .toList();

              business.processRefund(
                orderNumber: widget.order.orderNumber,
                items: refundItems,
                reason: _reason.trim().isEmpty
                    ? 'Hakuna sababu'
                    : _reason.trim(),
              );

              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close refund page

              NotificationService.show(
                context: context,
                message:
                    'Refund ya ${_fmt(_totalRefundAmount)} TZS imefanyika — stock imerudishwa',
                type: NotificationType.warning,
              );
            },
            child: const Text('Thibitisha'),
          ),
        ],
      ),
    );
  }
}