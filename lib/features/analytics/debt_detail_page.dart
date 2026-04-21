import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const _kNavy = Color(0xFF1B2E6B);

class DebtDetailPage extends StatelessWidget {
  final SaleEntry sale;

  const DebtDetailPage({super.key, required this.sale});

  String _fmt(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // Tumia Consumer ili tuone updates za real-time
    return Consumer<BusinessState>(
      builder: (context, business, _) {
        // Pata sale ya sasa (updated) kutoka state
        final current = business.salesHistory.firstWhere(
          (s) => s.orderNumber == sale.orderNumber,
          orElse: () => sale,
        );

        final isFullyPaid = current.paid;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: _kNavy),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              current.orderNumber,
              style: const TextStyle(
                color: _kNavy,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red),
                onPressed: () =>
                    _confirmDelete(context, business, current),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ===== STATUS CARD =====
                _statusCard(current, isFullyPaid),

                const SizedBox(height: 16),

                // ===== TAARIFA ZA DENI =====
                _sectionTitle('Taarifa za Deni'),
                const SizedBox(height: 10),
                _infoCard(current),

                const SizedBox(height: 16),

                // ===== HISTORIA YA MALIPO =====
                _sectionTitle('Historia ya Malipo'),
                const SizedBox(height: 10),
                _paymentsHistory(current),

                const SizedBox(height: 16),

                // ===== BIDHAA ZILIZOAGIZWA =====
                _sectionTitle('Bidhaa Zilizoagizwa'),
                const SizedBox(height: 10),
                _itemsList(current),
              ],
            ),
          ),

          // ===== BOTTOM BUTTON =====
          bottomNavigationBar: isFullyPaid
              ? null
              : _bottomButton(context, business, current),
        );
      },
    );
  }

  // ===== STATUS CARD =====
  Widget _statusCard(SaleEntry current, bool isFullyPaid) {
    final remaining = current.remainingAmount;
    final progress = current.paymentProgress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFullyPaid
              ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isFullyPaid
                      ? Icons.check_circle_outline
                      : Icons.schedule_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isFullyPaid ? 'Deni Limeisha' : 'Inadaiwa',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kimelipwa',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmt(current.paidAmount)} TZS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kinachobaki',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fmt(remaining)} TZS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Jumla',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_fmt(current.amount)} TZS',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== INFO CARD =====
  Widget _infoCard(SaleEntry current) {
    return Container(
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
          _infoRow(Icons.tag, 'Namba ya Order',
              current.orderNumber, _kNavy),
          _divider(),
          _infoRow(Icons.person_outline, 'Muuzaji',
              current.sellerName, Colors.grey.shade700),
          _divider(),
          _infoRow(
            Icons.account_circle_outlined,
            'Mteja',
            current.customerName ?? 'Asiyejulikana',
            _kNavy,
          ),
          if (current.customerPhone != null) ...[
            _divider(),
            _infoRow(
              Icons.phone_outlined,
              'Simu ya Mteja',
              current.customerPhone!,
              Colors.grey.shade700,
            ),
          ],
          _divider(),
          _infoRow(
            Icons.calendar_today_outlined,
            'Tarehe ya Agizo',
            _fmtDate(current.date),
            Colors.grey.shade700,
          ),
          _divider(),
          _infoRow(
            Icons.access_time_outlined,
            'Muda',
            _fmtTime(current.date),
            Colors.grey.shade700,
          ),
          if (current.note != null &&
              current.note!.isNotEmpty) ...[
            _divider(),
            _infoRow(
              Icons.notes_outlined,
              'Maelezo',
              current.note!,
              Colors.grey.shade700,
            ),
          ],
        ],
      ),
    );
  }

  // ===== HISTORIA YA MALIPO =====
  Widget _paymentsHistory(SaleEntry current) {
    if (current.payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.payment_outlined,
                size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Hakuna malipo yaliyofanywa bado',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
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
        children: current.payments.asMap().entries.map((entry) {
          final i = entry.key;
          final payment = entry.value;
          final isLast = i == current.payments.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF22C55E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Malipo ${i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _kNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_fmtDate(payment.date)} • ${_paymentMethodLabel(payment.paymentMethod)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${_fmt(payment.amount)} TZS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ===== BIDHAA LIST =====
  Widget _itemsList(SaleEntry current) {
    return Container(
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
          ...current.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == current.items.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kNavy.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: _kNavy,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                        '${_fmt(item.subtotal)} TZS',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _kNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 16,
                      endIndent: 16),
              ],
            );
          }),

          // Summary footer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                if (current.discount > 0) ...[
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumla ndogo',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600)),
                      Text(
                          '${_fmt(current.amount + current.discount)} TZS',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Punguzo',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600)),
                      Text('-${_fmt(current.discount)} TZS',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF22C55E))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                ],
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'JUMLA KUBWA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      '${_fmt(current.amount)} TZS',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== BOTTOM BUTTON =====
  Widget _bottomButton(
      BuildContext context, BusinessState business, SaleEntry current) {
    return Container(
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
          // Deni lililobaki msisitizo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deni Lililobaki:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_fmt(current.remainingAmount)} TZS',
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
                backgroundColor: _kNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.payment_outlined, size: 20),
              label: const Text(
                'Lipia Deni',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () =>
                  _showPaymentSheet(context, business, current),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PAYMENT BOTTOM SHEET =====
  void _showPaymentSheet(
      BuildContext context, BusinessState business, SaleEntry current) {
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedMethod;
    bool step2 = false; // false = kiasi, true = njia ya malipo

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          final enteredAmount =
              int.tryParse(amountController.text) ?? 0;
          final isAmountValid = enteredAmount > 0 &&
              enteredAmount <= current.remainingAmount;

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Row(
                    children: [
                      const Text(
                        'Lipia Deni',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _kNavy,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Kinachobaki: ${_fmt(current.remainingAmount)} TZS',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!step2) ...[
                    // ===== STEP 1: TAREHE + KIASI =====

                    // Tarehe
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModal(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey.shade400,
                                size: 18),
                            const SizedBox(width: 10),
                            Text(
                              selectedDate.day ==
                                          DateTime.now().day &&
                                      selectedDate.month ==
                                          DateTime.now().month
                                  ? 'Leo — ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                                  : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Kiasi
                    const Text(
                      'Kiasi Kinacholipwa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (_) => setModal(() {}),
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: 'TZS',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: _kNavy),
                        ),
                        errorText: enteredAmount > 0 &&
                                enteredAmount >
                                    current.remainingAmount
                            ? 'Kiasi ni kikubwa zaidi ya deni (${_fmt(current.remainingAmount)} TZS)'
                            : null,
                      ),
                    ),

                    // Quick amount buttons
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _quickAmountChip(
                            'Lipa Yote',
                            current.remainingAmount,
                            amountController,
                            setModal),
                        _quickAmountChip(
                            '½ ya Deni',
                            (current.remainingAmount / 2)
                                .ceil(),
                            amountController,
                            setModal),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Next button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAmountValid
                              ? _kNavy
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isAmountValid
                            ? () => setModal(() => step2 = true)
                            : null,
                        child: const Text(
                          'Endelea → Chagua Njia ya Malipo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // ===== STEP 2: NJIA YA MALIPO =====

                    // Back button
                    GestureDetector(
                      onTap: () => setModal(() => step2 = false),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios,
                              size: 14, color: _kNavy),
                          const SizedBox(width: 4),
                          Text(
                            'Rudi — Kiasi: ${_fmt(enteredAmount)} TZS',
                            style: const TextStyle(
                              color: _kNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Njia ya Malipo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...[
                      ('cash', Icons.payments_outlined, 'Pesa Taslimu'),
                      ('mobile', Icons.phone_android_outlined, 'Simu (M-Pesa/Tigo)'),
                      ('bank', Icons.account_balance_outlined, 'Benki'),
                    ].map((method) => GestureDetector(
                          onTap: () => setModal(
                              () => selectedMethod = method.$1),
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedMethod == method.$1
                                  ? _kNavy.withValues(alpha: 0.05)
                                  : Colors.grey.shade50,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedMethod == method.$1
                                    ? _kNavy
                                    : Colors.grey.shade200,
                                width: selectedMethod == method.$1
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method.$2,
                                  color:
                                      selectedMethod == method.$1
                                          ? _kNavy
                                          : Colors.grey.shade500,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  method.$3,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        selectedMethod == method.$1
                                            ? _kNavy
                                            : Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                if (selectedMethod == method.$1)
                                  const Icon(
                                    Icons.check_circle,
                                    color: _kNavy,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        )),

                    const SizedBox(height: 16),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedMethod != null
                              ? const Color(0xFF22C55E)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                            Icons.check_circle_outline,
                            size: 20),
                        label: Text(
                          'Hifadhi Malipo ya ${_fmt(enteredAmount)} TZS',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: selectedMethod == null
                            ? null
                            : () {
                                business.makePartialPayment(
                                  orderNumber:
                                      current.orderNumber,
                                  amount: enteredAmount,
                                  paymentMethod:
                                      selectedMethod!,
                                  date: selectedDate,
                                );
                                Navigator.pop(ctx);
                                NotificationService.show(
                                  context: context,
                                  message:
                                      'Malipo ya ${_fmt(enteredAmount)} TZS yamehifadhiwa!',
                                  type: NotificationType.success,
                                );
                              },
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== DELETE CONFIRM =====
  void _confirmDelete(
      BuildContext context, BusinessState business, SaleEntry current) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Futa Deni?',
          style: TextStyle(
              color: _kNavy, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Order ${current.orderNumber} itafutwa kabisa. Hii haiwezi kutenduliwa.',
          style: TextStyle(color: Colors.grey.shade600),
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
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close detail page
              NotificationService.show(
                context: context,
                message: 'Order imefutwa',
                type: NotificationType.error,
              );
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  // ===== HELPERS =====
  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: _kNavy,
        ),
      );

  Widget _infoRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, color: Colors.grey.shade100);

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Pesa Taslimu';
      case 'mobile':
        return 'Simu (M-Pesa/Tigo)';
      case 'bank':
        return 'Benki';
      default:
        return method;
    }
  }

  Widget _quickAmountChip(
    String label,
    int amount,
    TextEditingController controller,
    StateSetter setModal,
  ) {
    return GestureDetector(
      onTap: () {
        controller.text = amount.toString();
        setModal(() {});
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _kNavy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label (${_fmt(amount)} TZS)',
          style: const TextStyle(
            fontSize: 12,
            color: _kNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}