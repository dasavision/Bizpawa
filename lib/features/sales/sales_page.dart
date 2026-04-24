import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'order_page.dart';
import 'order_detail_page.dart';
import 'scanner_sale_page.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

enum SalesViewFilter { all, paid, credit }

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  SalesViewFilter _filter = SalesViewFilter.all;
  String _search = '';
  DateTime _selectedDate = DateTime.now();

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Leo';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Jana';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Chagua Kipindi', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: kNavyBlue)),
          const SizedBox(height: 16),
          _periodOption('Leo', Icons.today_outlined,
              () { setState(() => _selectedDate = DateTime.now()); Navigator.pop(context); }),
          _periodOption('Jana', Icons.calendar_today_outlined,
              () { setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 1))); Navigator.pop(context); }),
          _periodOption('Wiki Hii', Icons.date_range_outlined,
              () { setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 7))); Navigator.pop(context); }),
          _periodOption('Mwezi Huu', Icons.calendar_month_outlined,
              () { setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 30))); Navigator.pop(context); }),
          _periodOption('Mwaka Huu', Icons.calendar_today_outlined,
              () { setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 365))); Navigator.pop(context); }),
          _periodOption('Jipangie', Icons.tune_outlined, () async {
            Navigator.pop(context);
            final picked = await showDatePicker(
              context: context, initialDate: _selectedDate,
              firstDate: DateTime(2020), lastDate: DateTime.now());
            if (picked != null) setState(() => _selectedDate = picked);
          }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _scanOrder(BuildContext context, BusinessState business) {
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Scan QR ya Risiti',
                style: TextStyle(color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Elekeza kamera kwenye QR code ya risiti',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final raw = capture.barcodes.firstOrNull?.rawValue;
                      if (raw == null) return;
                      controller.dispose();
                      Navigator.pop(context);
                      final order = business.salesHistory
                          .where((s) => s.orderNumber == raw)
                          .firstOrNull;
                      if (order != null) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => OrderDetailPage(order: order)));
                      } else {
                        NotificationService.show(
                          context: context,
                          message: 'Order haikupatikana: $raw',
                          type: NotificationType.warning,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(context);
              },
              child: const Text('Ghairi',
                  style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _periodOption(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: kNavyBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: kNavyBlue, size: 18)),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final auth = context.watch<AuthState>();
    final isAdmin = auth.isAdmin;
    final perms = auth.permissions;

    if (!isAdmin && !perms.canRecordSales && !perms.canViewOtherSales) {
      return _LockedPage(
        title: 'Mauzo',
        message: 'Huna ruhusa ya kuona au kufanya mauzo.\nOmba Admin akupe ruhusa.',
      );
    }

    final allSales = business.salesHistory;
    final myName = auth.currentUser?.name ?? 'Admin';

    final dateSales = allSales.where((sale) {
      final matchesDate = _isSameDay(sale.date, _selectedDate);
      final matchesSeller = isAdmin || perms.canViewOtherSales
          ? true
          : sale.sellerName == myName;
      return matchesDate && matchesSeller;
    }).toList();

    final filteredSales = dateSales.where((sale) {
      final matchesSearch = sale.productName.toLowerCase()
          .contains(_search.toLowerCase()) ||
          sale.orderNumber.toLowerCase().contains(_search.toLowerCase());
      bool matchesFilter = true;
      switch (_filter) {
        case SalesViewFilter.paid: matchesFilter = sale.paid; break;
        case SalesViewFilter.credit: matchesFilter = !sale.paid; break;
        case SalesViewFilter.all: matchesFilter = true; break;
      }
      return matchesSearch && matchesFilter;
    }).toList();

    final totalSiku = dateSales.where((s) => s.paid)
        .fold<int>(0, (sum, s) => sum + s.amount);
    final totalMadeni = dateSales.where((s) => !s.paid)
        .fold<int>(0, (sum, s) => sum + s.amount);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Mauzo', style: TextStyle(
            color: kNavyBlue, fontWeight: FontWeight.bold)),
        actions: [
          if (!isAdmin && !perms.canViewOtherSales)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Mauzo yangu tu',
                  style: TextStyle(fontSize: 11,
                      color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
            ),
        ],
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tafuta mauzo ya ${_formatDate(_selectedDate)}...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: GestureDetector(
                        onTap: () => _scanOrder(context, business),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kNavyBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code_scanner,
                              color: kNavyBlue, size: 18),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isSameDay(_selectedDate, DateTime.now())
                          ? Colors.grey.shade100 : kNavyBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.calendar_today, size: 14,
                          color: _isSameDay(_selectedDate, DateTime.now())
                              ? Colors.grey.shade600 : Colors.white),
                      const SizedBox(width: 6),
                      Text('Chagua', style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isSameDay(_selectedDate, DateTime.now())
                              ? Colors.grey.shade600 : Colors.white)),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              _filterChip('Zote', SalesViewFilter.all),
              const SizedBox(width: 8),
              _filterChip('Imelipiwa', SalesViewFilter.paid),
              const SizedBox(width: 8),
              _filterChip('Madeni', SalesViewFilter.credit),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _SummaryCard(title: 'Mauzo Yaliyolipwa',
                  value: '${_formatCurrency(totalSiku)} TZS',
                  icon: Icons.check_circle_outline, color: const Color(0xFF22C55E)),
              const SizedBox(width: 10),
              _SummaryCard(title: 'Madeni',
                  value: '${_formatCurrency(totalMadeni)} TZS',
                  icon: Icons.schedule, color: kOrange),
            ]),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: RefreshIndicator(
              color: kNavyBlue, strokeWidth: 2.5, displacement: 20,
              onRefresh: _onRefresh,
              child: filteredSales.isEmpty
                  ? ListView(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 60,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(_search.isNotEmpty
                                ? 'Hakuna mauzo yanayolingana'
                                : 'Hakuna mauzo ${_formatDate(_selectedDate)}',
                                style: TextStyle(color: Colors.grey.shade500)),
                            if (_isSameDay(_selectedDate, DateTime.now()) &&
                                (isAdmin || perms.canRecordSales)) ...[
                              const SizedBox(height: 8),
                              Text('Bonyeza kitufe cha Uza kuanza',
                                  style: TextStyle(color: Colors.grey.shade400,
                                      fontSize: 12)),
                            ],
                          ],
                        )),
                      ),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filteredSales.length,
                      itemBuilder: (context, index) {
                        final sale = filteredSales[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => OrderDetailPage(order: sale))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: sale.paid
                                        ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                        : kOrange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    sale.paid ? Icons.check_circle_outline
                                        : Icons.schedule,
                                    color: sale.paid
                                        ? const Color(0xFF22C55E) : kOrange,
                                    size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sale.orderNumber,
                                          style: TextStyle(fontSize: 11,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 2),
                                      Text(sale.productName, style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13, color: kNavyBlue)),
                                      const SizedBox(height: 2),
                                      Row(children: [
                                        if (sale.customerName != null &&
                                            sale.customerName!.isNotEmpty) ...[
                                          Icon(Icons.person_outline, size: 11,
                                              color: Colors.grey.shade400),
                                          const SizedBox(width: 2),
                                          Text(sale.customerName!,
                                              style: TextStyle(fontSize: 11,
                                                  color: Colors.grey.shade500)),
                                          const SizedBox(width: 8),
                                        ],
                                        Icon(Icons.person, size: 11,
                                            color: Colors.grey.shade400),
                                        const SizedBox(width: 2),
                                        Text(sale.sellerName,
                                            style: TextStyle(fontSize: 11,
                                                color: Colors.grey.shade500)),
                                        const SizedBox(width: 8),
                                        Icon(Icons.access_time, size: 11,
                                            color: Colors.grey.shade400),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${sale.date.hour.toString().padLeft(2, '0')}:${sale.date.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(fontSize: 11,
                                              color: Colors.grey.shade500)),
                                      ]),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${_formatCurrency(sale.amount)} TZS',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13, color: kNavyBlue)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: sale.paid
                                            ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                                            : kOrange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(sale.paid ? 'Imelipwa' : 'Deni',
                                          style: TextStyle(fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: sale.paid
                                                  ? const Color(0xFF22C55E) : kOrange)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),

      // ✅ FAB — Scan inaenda ScannerSalePage (auto-add)
      floatingActionButton: (isAdmin || perms.canRecordSales)
          ? Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'scan',
                  backgroundColor: Colors.white,
                  foregroundColor: kNavyBlue,
                  elevation: 2,
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text('Scan',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ScannerSalePage())),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'uza',
                  backgroundColor: kNavyBlue,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text('Uza',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const OrderPage())),
                ),
              ])
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _filterChip(String label, SalesViewFilter value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kNavyBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? kNavyBlue : Colors.grey.shade200),
        ),
        child: Text(label, style: TextStyle(fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : Colors.black87)),
      ),
    );
  }
}

class _LockedPage extends StatelessWidget {
  final String title;
  final String message;
  const _LockedPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          title: Text(title, style: const TextStyle(
              color: kNavyBlue, fontWeight: FontWeight.bold))),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.grey.shade100,
                  shape: BoxShape.circle),
              child: Icon(Icons.lock_outline,
                  color: Colors.grey.shade400, size: 36)),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600,
                  fontSize: 14, height: 1.5)),
        ],
      )),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11,
              color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}