import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'invoice_page.dart';
import 'refund_page.dart'; // MPYA

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class OrderDetailPage extends StatelessWidget {
  final SaleEntry order;

  const OrderDetailPage({super.key, required this.order});

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    // Pata order ya sasa (updated) kutoka state
    final current = business.salesHistory.firstWhere(
      (s) => s.orderNumber == order.orderNumber,
      orElse: () => order,
    );

    final subtotal = current.items.fold<int>(
        0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          current.orderNumber,
          style: const TextStyle(
            color: kNavyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          // Futa order
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 18),
            ),
            onPressed: () => _confirmCancel(context, business, current),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // REFUND BADGE — inaonyesha kama imefanyiwa refund
            if (current.isRefunded || current.hasPartialRefund)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: current.isRefunded
                      ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                      : kOrange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: current.isRefunded
                        ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                        : kOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_return_outlined,
                      color: current.isRefunded
                          ? const Color(0xFFEF4444)
                          : kOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      current.isRefunded
                          ? 'Full Refund — ${_formatCurrency(current.refundAmount)} TZS'
                          : 'Partial Refund — ${_formatCurrency(current.refundAmount)} TZS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: current.isRefunded
                            ? const Color(0xFFEF4444)
                            : kOrange,
                      ),
                    ),
                  ],
                ),
              ),

            // ORDER INFO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  _infoRow(
                    'Namba ya Order',
                    current.orderNumber,
                    valueColor: kNavyBlue,
                    bold: true,
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    'Hali ya Malipo',
                    current.paid ? 'Imelipwa ✅' : 'Haijalipiwa ⏳',
                    valueColor: current.paid
                        ? const Color(0xFF22C55E)
                        : kOrange,
                  ),
                  if (current.paymentMethod != null) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      'Njia ya Malipo',
                      _paymentMethodName(current.paymentMethod!),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _infoRow('Muuzaji', current.sellerName),
                  if (current.customerName != null &&
                      current.customerName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow('Mteja', current.customerName!),
                  ],
                  const SizedBox(height: 8),
                  _infoRow(
                    'Tarehe',
                    '${current.date.day}/${current.date.month}/${current.date.year}',
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Muda',
                    '${current.date.hour.toString().padLeft(2, '0')}:${current.date.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BIDHAA ZA ODA
            const Text(
              'Bidhaa za Oda',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kNavyBlue,
              ),
            ),

            const SizedBox(height: 10),

            ...current.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kNavyBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: kNavyBlue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: kNavyBlue,
                          ),
                        ),
                        Text(
                          '${item.quantity} × ${_formatCurrency(item.sellingPrice)} TZS',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_formatCurrency(item.subtotal)} TZS',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kNavyBlue,
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 20),

            // SUMMARY
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  _infoRow(
                    'Jumla Ndogo',
                    '${_formatCurrency(subtotal)} TZS',
                  ),
                  if (current.discount > 0) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      'Punguzo',
                      '- ${_formatCurrency(current.discount)} TZS',
                      valueColor: Colors.red,
                    ),
                  ],
                  const Divider(height: 20),
                  _infoRow(
                    'JUMLA',
                    '${_formatCurrency(current.amount)} TZS',
                    bold: true,
                    valueColor: kNavyBlue,
                  ),
                  if (current.refundAmount > 0) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      'Refund',
                      '- ${_formatCurrency(current.refundAmount)} TZS',
                      valueColor: const Color(0xFFEF4444),
                    ),
                  ],
                ],
              ),
            ),

            if (current.note != null && current.note!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maelezo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.note!,
                      style: const TextStyle(color: kNavyBlue),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // REFUND BUTTON — inaonekana tu kama haijafanyiwa full refund
            if (!current.isRefunded)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(
                          color: Color(0xFFEF4444), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                        Icons.assignment_return_outlined,
                        size: 20),
                    label: Text(
                      current.hasPartialRefund
                          ? 'Refund Zaidi'
                          : 'Refund',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RefundPage(order: current),
                      ),
                    ),
                  ),
                ),
              ),

            // INVOICE BUTTON
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
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text(
                  'Toa Risiti (Invoice)',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoicePage(
                      order: current,
                      businessName:
                          context.read<BusinessState>().businessName,
                      businessPhone:
                          context.read<BusinessState>().businessPhone,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _paymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Cash 💵';
      case 'mobile':
        return 'Simu 📱';
      case 'bank':
        return 'Benki 🏦';
      default:
        return method;
    }
  }

  void _confirmCancel(BuildContext context, BusinessState business,
      SaleEntry current) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Futa Order',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Una uhakika unataka kufuta order ${current.orderNumber}?\n\nStock itarudishwa automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              business.cancelOrder(current.orderNumber);
              Navigator.pop(context);
              Navigator.pop(context);
              NotificationService.show(
                context: context,
                message:
                    'Order ${current.orderNumber} imefutwa — stock imerudishwa',
                type: NotificationType.error,
              );
            },
            child: const Text('Futa Order'),
          ),
        ],
      ),
    );
  }
}