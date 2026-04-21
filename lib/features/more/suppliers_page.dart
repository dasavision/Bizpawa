import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final suppliers = business.suppliers;
    final totalDebt = suppliers.fold<int>(
        0, (sum, s) => sum + s.remainingDebt);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wasambazaji',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          if (suppliers.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEA580C), _kOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text('Jumla ya Madeni ya Wasambazaji',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${_fmt(totalDebt)} TZS',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: suppliers.isEmpty
                ? _emptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    itemCount: suppliers.length,
                    itemBuilder: (_, i) {
                      final s = suppliers[i];
                      final hasDebt = s.remainingDebt > 0;

                      return GestureDetector(
                        onTap: () => _showSupplierDetail(
                            context, s, business),
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(14),
                            border: hasDebt
                                ? Border.all(
                                    color: _kOrange
                                        .withValues(alpha: 0.4),
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: hasDebt
                                      ? _kOrange.withValues(
                                          alpha: 0.1)
                                      : const Color(0xFF22C55E)
                                          .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    s.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: hasDebt
                                          ? _kOrange
                                          : const Color(
                                              0xFF22C55E),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name,
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 14,
                                          color: _kNavy,
                                        )),
                                    Text(s.phone,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors
                                                .grey.shade500)),
                                    Text(s.businessName,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors
                                                .grey.shade400)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  if (hasDebt)
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _kOrange
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                8),
                                      ),
                                      child: Text(
                                        '${_fmt(s.remainingDebt)} TZS',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.bold,
                                          color: _kOrange,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                                0xFF22C55E)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(
                                                8),
                                      ),
                                      child: const Text(
                                        'Amelipwa',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight.bold,
                                          color:
                                              Color(0xFF22C55E),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  if (hasDebt)
                                    Text('Ana deni',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _kOrange)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_supplier',
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Ongeza Msambazaji',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _showAddSupplierSheet(context),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Hakuna wasambazaji bado',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kNavy)),
            const SizedBox(height: 8),
            Text('Ongeza wasambazaji wanaokupa mzigo kwa mkopo',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500),
                textAlign: TextAlign.center),
          ],
        ),
      );

  void _showSupplierDetail(BuildContext context,
      Supplier supplier, BusinessState business) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) =>
            Consumer<BusinessState>(
          builder: (ctx, biz, _) {
            final current = biz.suppliers.firstWhere(
              (s) => s.id == supplier.id,
              orElse: () => supplier,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _kOrange.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            current.name
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _kOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(current.name,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: _kNavy)),
                            Text(current.businessName,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey.shade500)),
                            Text(current.phone,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _confirmDeleteSupplier(
                            context, current, biz),
                      ),
                    ],
                  ),
                ),

                // Deni summary
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          label: 'Jumla ya Mkopo',
                          value:
                              '${_fmt(current.totalDebt)} TZS',
                          color: _kNavy,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          label: 'Kimelipwa',
                          value:
                              '${_fmt(current.paidAmount)} TZS',
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoTile(
                          label: 'Kinabaki',
                          value: '${_fmt(current.remainingDebt)} TZS',
                          color: current.remainingDebt > 0
                              ? _kOrange
                              : const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Malipo ya historia
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Historia ya Malipo',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _kNavy)),
                    ],
                  ),
                ),

                Expanded(
                  child: current.payments.isEmpty
                      ? Center(
                          child: Text(
                            'Hakuna malipo bado',
                            style: TextStyle(
                                color: Colors.grey.shade400),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          itemCount: current.payments.length,
                          itemBuilder: (_, i) {
                            final p = current.payments[i];
                            return Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons
                                          .check_circle_outline,
                                      color: Color(0xFF22C55E),
                                      size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                            '${p.date.day}/${p.date.month}/${p.date.year}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors
                                                    .grey
                                                    .shade500)),
                                        Text(
                                            _paymentLabel(
                                                p.method),
                                            style:
                                                const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        _kNavy)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                      '+${_fmt(p.amount)} TZS',
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(
                                              0xFF22C55E))),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                if (current.remainingDebt > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                            Icons.payment_outlined,
                            size: 20),
                        label: Text(
                          'Lipia Msambazaji (${_fmt(current.remainingDebt)} TZS)',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () =>
                            _showPaySupplierSheet(
                                context, current, biz),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPaySupplierSheet(BuildContext context,
      Supplier supplier, BusinessState business) {
    final amountCtrl = TextEditingController();
    String? selectedMethod;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    const Text('Lipia Msambazaji',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _kNavy)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _kOrange.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Kinabaki: ${_fmt(supplier.remainingDebt)} TZS',
                        style: const TextStyle(
                            fontSize: 11,
                            color: _kOrange,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

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
                      borderRadius: BorderRadius.circular(12),
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
                          'Leo — ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                              color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                const Text('Kiasi Kinacholipwa',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kNavy)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountCtrl,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _kNavy),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                const Text('Njia ya Malipo',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kNavy)),
                const SizedBox(height: 8),

                ...[
                  ('cash', Icons.payments_outlined,
                      'Pesa Taslimu'),
                  ('mobile', Icons.phone_android_outlined,
                      'Simu (M-Pesa/Tigo)'),
                  ('bank', Icons.account_balance_outlined,
                      'Benki'),
                ].map((m) => GestureDetector(
                      onTap: () =>
                          setModal(() => selectedMethod = m.$1),
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedMethod == m.$1
                              ? _kNavy.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedMethod == m.$1
                                ? _kNavy
                                : Colors.grey.shade200,
                            width:
                                selectedMethod == m.$1 ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(m.$2,
                                color: selectedMethod == m.$1
                                    ? _kNavy
                                    : Colors.grey.shade500,
                                size: 20),
                            const SizedBox(width: 10),
                            Text(m.$3,
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        selectedMethod == m.$1
                                            ? _kNavy
                                            : Colors.grey
                                                .shade700)),
                            const Spacer(),
                            if (selectedMethod == m.$1)
                              const Icon(Icons.check_circle,
                                  color: _kNavy, size: 18),
                          ],
                        ),
                      ),
                    )),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (int.tryParse(amountCtrl.text) ??
                                      0) >
                                  0 &&
                              selectedMethod != null
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
                    label: const Text('Hifadhi Malipo',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    onPressed: selectedMethod == null ||
                            (int.tryParse(amountCtrl.text) ??
                                    0) <=
                                0
                        ? null
                        : () {
                            final amount = int.parse(
                                amountCtrl.text);
                            business.paySupplier(
                              supplierId: supplier.id,
                              amount: amount,
                              method: selectedMethod!,
                              date: selectedDate,
                            );
                            Navigator.pop(ctx);
                            NotificationService.show(
                              context: context,
                              message:
                                  'Malipo ya ${_fmt(amount)} TZS yamehifadhiwa!',
                              type: NotificationType.success,
                            );
                          },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSupplierSheet(BuildContext context) {
    final business = context.read<BusinessState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final bizNameCtrl = TextEditingController();
    final debtCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text('Msambazaji Mpya',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kNavy)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Jina la Msambazaji *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Namba ya Simu *',
                  prefixText: '+255 ',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bizNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Jina la Biashara yake',
                  prefixIcon:
                      const Icon(Icons.store_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: debtCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: 'Deni la Sasa (kama ana)',
                  hintText: '0',
                  suffixText: 'TZS',
                  prefixIcon:
                      const Icon(Icons.money_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        phoneCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content:
                            Text('Jaza jina na simu'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }
                    final initialDebt =
                        int.tryParse(debtCtrl.text) ?? 0;
                    business.addSupplier(Supplier(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      businessName:
                          bizNameCtrl.text.trim().isEmpty
                              ? nameCtrl.text.trim()
                              : bizNameCtrl.text.trim(),
                      totalDebt: initialDebt,
                      paidAmount: 0,
                    ));
                    Navigator.pop(context);
                    NotificationService.show(
                      context: context,
                      message:
                          '${nameCtrl.text.trim()} amesajiliwa!',
                      type: NotificationType.success,
                    );
                  },
                  child: const Text('Hifadhi Msambazaji',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSupplier(BuildContext context,
      Supplier s, BusinessState business) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Futa Msambazaji?',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
        content: Text('Futa ${s.name} kutoka orodha?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () {
              business.deleteSupplier(s.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String method) {
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
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}