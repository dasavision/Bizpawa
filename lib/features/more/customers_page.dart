import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const _kNavy = Color(0xFF1B2E6B);
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _searchCtrl = TextEditingController();
  bool _showDebtorsOnly = false;
  String _query = '';

  String _fmt(int amount) => amount
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    // Hesabu deni la kila mteja
    Map<String, int> customerDebts = {};
    for (final sale in business.salesHistory) {
      if (!sale.paid && sale.customerName != null) {
        customerDebts[sale.customerName!] =
            (customerDebts[sale.customerName!] ?? 0) +
                sale.remainingAmount;
      }
    }

    var customers = business.customers.where((c) {
      final matchSearch = _query.isEmpty ||
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.phone.contains(_query);
      final matchDebtor =
          !_showDebtorsOnly || customerDebts.containsKey(c.name);
      return matchSearch && matchDebtor;
    }).toList();

    customers.sort((a, b) {
      final aDebt = customerDebts[a.name] ?? 0;
      final bDebt = customerDebts[b.name] ?? 0;
      return bDebt.compareTo(aDebt);
    });

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
          'Wateja',
          style: TextStyle(
              color: _kNavy, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: _kNavy),
            onPressed: () => _showAddCustomerSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Tafuta mteja...',
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.grey),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.grey),
                            onPressed: () => setState(() {
                              _query = '';
                              _searchCtrl.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Wote',
                      selected: !_showDebtorsOnly,
                      onTap: () => setState(
                          () => _showDebtorsOnly = false),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Wanaodaiwa',
                      selected: _showDebtorsOnly,
                      color: const Color(0xFFEF4444),
                      onTap: () => setState(
                          () => _showDebtorsOnly = true),
                    ),
                    const Spacer(),
                    Text(
                      '${customers.length} wateja',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: customers.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customers.length,
                    itemBuilder: (context, i) {
                      final c = customers[i];
                      final debt = customerDebts[c.name] ?? 0;
                      final hasDebt = debt > 0;

                      return GestureDetector(
                        onTap: () => _showCustomerDetail(
                            context, c, debt, business),
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
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.3),
                                    width: 1,
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
                              // Avatar
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: hasDebt
                                      ? const Color(0xFFEF4444)
                                          .withValues(alpha: 0.1)
                                      : _kNavy
                                          .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    c.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: hasDebt
                                          ? const Color(0xFFEF4444)
                                          : _kNavy,
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
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: hasDebt
                                            ? const Color(0xFFEF4444)
                                            : _kNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.phone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    if (c.address != null &&
                                        c.address!.isNotEmpty)
                                      Text(
                                        c.address!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Colors.grey.shade400,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (hasDebt)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${_fmt(debt)} TZS',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Ana deni',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey),
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
        heroTag: 'add_customer',
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined, size: 20),
        label: const Text('Ongeza Mteja',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _showAddCustomerSheet(context),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _showDebtorsOnly
                  ? 'Hakuna wanaodaiwa 🎉'
                  : 'Hakuna wateja bado',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showDebtorsOnly
                  ? 'Wateja wote wameshalipa'
                  : 'Bonyeza + kuongeza mteja wa kwanza',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );

  void _showCustomerDetail(BuildContext context, Customer c,
      int totalDebt, BusinessState business) {
    final customerSales = business.salesHistory
        .where((s) => s.customerName == c.name)
        .toList();
    final totalPurchases =
        customerSales.fold<int>(0, (sum, s) => sum + s.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            // Handle
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: totalDebt > 0
                          ? const Color(0xFFEF4444)
                              .withValues(alpha: 0.1)
                          : _kNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        c.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: totalDebt > 0
                              ? const Color(0xFFEF4444)
                              : _kNavy,
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
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _kNavy,
                          ),
                        ),
                        Text(c.phone,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  // Edit + Delete
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: _kNavy, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditCustomerSheet(
                          context, c, business);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () =>
                        _confirmDelete(context, c, business),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Jumla ya Ununuzi',
                    value: '${_fmt(totalPurchases)} TZS',
                    color: _kNavy,
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    label: 'Deni Linalobaki',
                    value: totalDebt > 0
                        ? '${_fmt(totalDebt)} TZS'
                        : 'Hana deni',
                    color: totalDebt > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100),

            // Sales history
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Historia ya Mauzo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kNavy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${customerSales.length} orders',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            Expanded(
              child: customerSales.isEmpty
                  ? Center(
                      child: Text(
                        'Hajawahi kununua bado',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      itemCount: customerSales.length,
                      itemBuilder: (_, i) {
                        final sale = customerSales[i];
                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sale.orderNumber,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors.grey.shade500,
                                      ),
                                    ),
                                    Text(
                                      sale.productName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: _kNavy,
                                      ),
                                    ),
                                    Text(
                                      '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_fmt(sale.amount)} TZS',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _kNavy,
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.only(
                                            top: 4),
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2),
                                    decoration: BoxDecoration(
                                      color: sale.paid
                                          ? const Color(0xFF22C55E)
                                              .withValues(
                                                  alpha: 0.1)
                                          : const Color(0xFFEF4444)
                                              .withValues(
                                                  alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      sale.paid
                                          ? 'Imelipwa'
                                          : 'Deni',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: sale.paid
                                            ? const Color(
                                                0xFF22C55E)
                                            : const Color(
                                                0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerSheet(BuildContext context) {
    final business = context.read<BusinessState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool showExtra = false;

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
                const Text(
                  'Mteja Mpya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Jina la Mteja *',
                    prefixIcon:
                        const Icon(Icons.person_outline),
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
                    prefixIcon:
                        const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      setModal(() => showExtra = !showExtra),
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
                        Icon(
                          showExtra
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Taarifa za ziada (hiari)',
                          style: TextStyle(
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showExtra) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Barua pepe',
                      prefixIcon:
                          const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Anwani / Mtaa',
                      prefixIcon:
                          const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Jaza jina na simu kwanza'),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }
                      business.addCustomer(Customer(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty
                            ? null
                            : emailCtrl.text.trim(),
                        address:
                            addressCtrl.text.trim().isEmpty
                                ? null
                                : addressCtrl.text.trim(),
                      ));
                      Navigator.pop(ctx);
                      NotificationService.show(
                        context: context,
                        message:
                            '${nameCtrl.text.trim()} amesajiliwa!',
                        type: NotificationType.success,
                      );
                    },
                    child: const Text(
                      'Hifadhi Mteja',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
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

  void _showEditCustomerSheet(BuildContext context,
      Customer c, BusinessState business) {
    final nameCtrl = TextEditingController(text: c.name);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl =
        TextEditingController(text: c.email ?? '');
    final addressCtrl =
        TextEditingController(text: c.address ?? '');

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
              const Text(
                'Hariri Mteja',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Jina la Mteja',
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
                  labelText: 'Simu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Barua pepe (hiari)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Anwani (hiari)',
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
                    backgroundColor: _kNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    business.updateCustomer(Customer(
                      id: c.id,
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim().isEmpty
                          ? null
                          : emailCtrl.text.trim(),
                      address:
                          addressCtrl.text.trim().isEmpty
                              ? null
                              : addressCtrl.text.trim(),
                    ));
                    Navigator.pop(context);
                    NotificationService.show(
                      context: context,
                      message: 'Taarifa zimesasishwa!',
                      type: NotificationType.success,
                    );
                  },
                  child: const Text('Hifadhi Mabadiliko',
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

  void _confirmDelete(BuildContext context, Customer c,
      BusinessState business) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Futa Mteja?',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
        content: Text(
            'Je, una uhakika wa kufuta ${c.name}?'),
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
              business.deleteCustomer(c.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? _kNavy;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? activeColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}