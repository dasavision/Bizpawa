import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/features/analytics/expense_detail_page.dart';
import 'package:bizpawa/features/analytics/debt_detail_page.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

String _fmtCurrency(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ===== REMINDER FUNCTION =====
Future<void> _sendDebtReminder(BuildContext context, SaleEntry sale) async {
  final customerName = sale.customerName ?? 'Mteja';
  final phone = sale.customerPhone;
  final remaining = sale.remainingAmount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  final orderNumber = sale.orderNumber;
  final date = '${sale.date.day}/${sale.date.month}/${sale.date.year}';

  final message =
      'Habari $customerName,\n\n'
      'Tunakukumbusha kuhusu deni lako:\n\n'
      '🧾 Order: $orderNumber\n'
      '📅 Tarehe: $date\n'
      '💰 Kiasi Kilichobaki: TZS $remaining\n\n'
      'Tafadhali lipa ili kuendelea kupata huduma zetu.\n\n'
      'Asante sana! 🙏';

  final encodedMsg = Uri.encodeComponent(message);

  String? whatsappPhone;
  if (phone != null && phone.isNotEmpty) {
    String p = phone.replaceAll(' ', '').replaceAll('-', '');
    if (p.startsWith('0')) p = '255${p.substring(1)}';
    if (!p.startsWith('255')) p = '255$p';
    whatsappPhone = p;
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Tuma Ukumbusho',
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold, color: kNavyBlue)),
          const SizedBox(height: 4),
          Text('Kwa: $customerName${phone != null ? ' ($phone)' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 16),

          if (whatsappPhone != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.chat_outlined,
                    color: Color(0xFF25D366), size: 20)),
              title: const Text('WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Fungua mazungumzo ya WhatsApp'),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(
                    'whatsapp://send?phone=$whatsappPhone&text=$encodedMsg');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(
                  color: kNavyBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.sms_outlined,
                  color: kNavyBlue, size: 20)),
            title: const Text('SMS',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Tuma ujumbe wa SMS'),
            onTap: () async {
  Navigator.pop(ctx);
  final smsUri = Uri.parse(
    'sms:${phone ?? ''}?body=${Uri.encodeComponent(message)}');
  if (await canLaunchUrl(smsUri)) {
    await launchUrl(smsUri);
  } else {
    await launchUrl(smsUri, mode: LaunchMode.externalApplication);
  }
},
          ),

          if (phone == null || phone.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber_outlined,
                    color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text(
                  'Mteja hana namba ya simu. Ongeza namba kwanza.',
                  style: TextStyle(fontSize: 12),
                )),
              ]),
            ),

          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isAdmin = auth.isAdmin;
    final perms = auth.permissions;

    final canSeeExpenses = isAdmin || perms.canRecordExpenses ||
        perms.canViewExpenseReport;
    final canSeeDebts = isAdmin || perms.canViewAllDebts ||
        perms.canViewDebtReport;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Madeni & Matumizi',
            style: TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kNavyBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: kNavyBlue,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.money_off_outlined, size: 20),
                text: 'Matumizi'),
            Tab(icon: Icon(Icons.schedule_outlined, size: 20),
                text: 'Madeni'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          canSeeExpenses
              ? _MatumiziTab(isAdmin: isAdmin, perms: perms)
              : _LockedTab(
                  icon: Icons.money_off_outlined,
                  message: 'Huna ruhusa ya kuona matumizi.\nOmba Admin akupe ruhusa.'),
          canSeeDebts
              ? _MadeniTab(isAdmin: isAdmin, perms: perms)
              : _LockedTab(
                  icon: Icons.schedule_outlined,
                  message: 'Huna ruhusa ya kuona madeni.\nOmba Admin akupe ruhusa.'),
        ],
      ),
    );
  }
}

class _LockedTab extends StatelessWidget {
  final IconData icon;
  final String message;
  const _LockedTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 72, height: 72,
            decoration: BoxDecoration(color: Colors.grey.shade100,
                shape: BoxShape.circle),
            child: Icon(Icons.lock_outline,
                color: Colors.grey.shade400, size: 32)),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600,
                fontSize: 14, height: 1.5)),
      ]),
    );
  }
}

class _MatumiziTab extends StatefulWidget {
  final bool isAdmin;
  final SellerPermissions perms;
  const _MatumiziTab({required this.isAdmin, required this.perms});

  @override
  State<_MatumiziTab> createState() => _MatumiziTabState();
}

class _MatumiziTabState extends State<_MatumiziTab> {
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Leo';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Jana';
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chakula': return Icons.restaurant_outlined;
      case 'umeme': return Icons.bolt_outlined;
      case 'bando': return Icons.wifi_outlined;
      case 'usafiri': return Icons.directions_car_outlined;
      case 'usafi': return Icons.cleaning_services_outlined;
      case 'kodi ya pango': return Icons.home_outlined;
      case 'mishahara': return Icons.people_outline;
      case 'matengenezo': return Icons.build_outlined;
      default: return Icons.receipt_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chakula': return const Color(0xFFEF4444);
      case 'umeme': return const Color(0xFFF59E0B);
      case 'bando': return const Color(0xFF3B82F6);
      case 'usafiri': return const Color(0xFF8B5CF6);
      case 'usafi': return const Color(0xFF06B6D4);
      case 'kodi ya pango': return const Color(0xFF10B981);
      case 'mishahara': return const Color(0xFFF97316);
      case 'matengenezo': return const Color(0xFF6366F1);
      default: return kNavyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final auth = context.watch<AuthState>();
    final myName = auth.currentUser?.name ?? 'Admin';

    final expenses = widget.isAdmin || widget.perms.canViewOtherExpenses
        ? business.expensesList
        : business.expensesList
            .where((e) => e.recordedBy == myName)
            .toList();

    final grouped = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = '${e.date.year}-${e.date.month}-${e.date.day}';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final cats = <String, int>{};
    for (final e in expenses) {
      cats[e.category] = (cats[e.category] ?? 0) + e.amount;
    }
    final maxVal = cats.values.isEmpty ? 1
        : cats.values.reduce((a, b) => a > b ? a : b);

    return Stack(
      children: [
        RefreshIndicator(
          color: kNavyBlue, strokeWidth: 2.5, onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (!widget.isAdmin && !widget.perms.canViewOtherExpenses)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 6),
                      const Text('Unaona matumizi uliyorekodi wewe tu',
                          style: TextStyle(fontSize: 12,
                              color: Color(0xFF7C3AED))),
                    ]),
                  ),

                Row(children: [
                  _SummaryCard(title: 'Leo',
                      value: '${_fmtCurrency(business.todayExpenses)} TZS',
                      icon: Icons.today_outlined, color: const Color(0xFFEF4444)),
                  const SizedBox(width: 10),
                  _SummaryCard(title: 'Wiki Hii',
                      value: '${_fmtCurrency(business.weeklyExpenses)} TZS',
                      icon: Icons.date_range_outlined, color: kOrange),
                  const SizedBox(width: 10),
                  _SummaryCard(title: 'Mwezi Huu',
                      value: '${_fmtCurrency(business.monthlyExpenses)} TZS',
                      icon: Icons.calendar_month_outlined, color: kNavyBlue),
                ]),

                const SizedBox(height: 20),

                if (widget.isAdmin || widget.perms.canViewProfitAnalytics)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: business.todayNetProfit >= 0
                            ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                            : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(business.todayNetProfit >= 0
                            ? Icons.trending_up : Icons.trending_down,
                            color: Colors.white, size: 24)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Faida Halisi ya Leo',
                              style: TextStyle(color: Colors.white70,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${_fmtCurrency(business.todayNetProfit.abs())} TZS',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      )),
                      Column(crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                        Text('Mauzo: ${_fmtCurrency(business.todaySales)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('Matumizi: ${_fmtCurrency(business.todayExpenses)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ]),
                    ]),
                  ),

                if (widget.isAdmin || widget.perms.canViewProfitAnalytics)
                  const SizedBox(height: 20),

                if (cats.isNotEmpty) ...[
                  const Text('Matumizi kwa Aina', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: kNavyBlue)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8, offset: const Offset(0, 2))]),
                    child: Column(
                      children: (cats.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .map((entry) {
                        final color = _categoryColor(entry.key);
                        final ratio = maxVal == 0 ? 0.0 : entry.value / maxVal;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(_categoryIcon(entry.key),
                                    color: color, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(entry.key,
                                    style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                                Text('${_fmtCurrency(entry.value)} TZS',
                                    style: TextStyle(fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: color)),
                              ]),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation(color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text('Historia ya Matumizi', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: kNavyBlue)),
                const SizedBox(height: 12),

                if (expenses.isEmpty)
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Icon(Icons.money_off_outlined, size: 48,
                          color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Hakuna matumizi bado',
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text('Bonyeza kitufe cha + kurekodi',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ]),
                  )
                else
                  ...sortedKeys.map((key) {
                    final dayExpenses = grouped[key]!;
                    final dayTotal = dayExpenses.fold<int>(0, (sum, e) => sum + e.amount);
                    final date = dayExpenses.first.date;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(date), style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600)),
                              Text('${_fmtCurrency(dayTotal)} TZS',
                                  style: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444))),
                            ],
                          ),
                        ),
                        ...dayExpenses.map((expense) => GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ExpenseDetailPage(expense: expense))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8, offset: const Offset(0, 2))]),
                            child: Row(children: [
                              Container(width: 42, height: 42,
                                decoration: BoxDecoration(
                                    color: _categoryColor(expense.category)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Icon(_categoryIcon(expense.category),
                                    color: _categoryColor(expense.category),
                                    size: 20)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense.category, style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13,
                                      color: kNavyBlue)),
                                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(expense.note!, style: TextStyle(
                                        fontSize: 11, color: Colors.grey.shade500),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    '${expense.date.hour.toString().padLeft(2, '0')}:${expense.date.minute.toString().padLeft(2, '0')} • ${expense.recordedBy}',
                                    style: TextStyle(fontSize: 11,
                                        color: Colors.grey.shade400)),
                                ],
                              )),
                              Text('${_fmtCurrency(expense.amount)} TZS',
                                  style: const TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: 13, color: Color(0xFFEF4444))),
                            ]),
                          ),
                        )),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
              ],
            ),
          ),
        ),

        if (widget.isAdmin || widget.perms.canRecordExpenses)
          Positioned(
            bottom: 24, right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'add_expense',
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Rekodi Matumizi',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () => _showAddExpenseSheet(context),
            ),
          ),
      ],
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    final business = context.read<BusinessState>();
    final auth = context.read<AuthState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? selectedCategory;
    DateTime selectedDate = DateTime.now();
    bool showNote = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('Rekodi Matumizi', style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: kNavyBlue)),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, initialDate: selectedDate,
                      firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (picked != null) setModal(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Row(children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
                      const SizedBox(width: 10),
                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      const Spacer(),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => _showCategorySheet(context, business, setModal,
                      (cat) => selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selectedCategory != null
                          ? kNavyBlue.withValues(alpha: 0.05) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedCategory != null
                            ? kNavyBlue.withValues(alpha: 0.3) : Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      Icon(selectedCategory != null
                          ? _categoryIcon(selectedCategory!) : Icons.category_outlined,
                          color: selectedCategory != null
                              ? kNavyBlue : Colors.grey.shade400, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                          selectedCategory ?? 'Chagua Aina ya Matumizi',
                          style: TextStyle(fontSize: 15,
                              color: selectedCategory != null
                                  ? kNavyBlue : Colors.grey.shade400,
                              fontWeight: selectedCategory != null
                                  ? FontWeight.w600 : FontWeight.normal))),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Kiasi', style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: kNavyBlue)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '0', suffixText: 'TZS',
                    filled: true, fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kNavyBlue)),
                  ),
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => setModal(() => showNote = !showNote),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: showNote ? kNavyBlue : Colors.grey.shade200)),
                    child: Row(children: [
                      Icon(showNote ? Icons.notes : Icons.add_circle_outline,
                          color: showNote ? kNavyBlue : Colors.grey.shade400,
                          size: 18),
                      const SizedBox(width: 10),
                      Text('+ Maelezo ya Ziada (hiari)',
                          style: TextStyle(
                              color: showNote ? kNavyBlue : Colors.grey.shade400,
                              fontSize: 14)),
                      const Spacer(),
                      Icon(showNote ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400),
                    ]),
                  ),
                ),

                if (showNote) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController, maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Andika maelezo ya ziada...',
                      filled: true, fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kNavyBlue)),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text('Hifadhi Matumizi', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      final amount = int.tryParse(amountController.text) ?? 0;
                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Chagua aina ya matumizi'),
                            backgroundColor: Colors.red));
                        return;
                      }
                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Weka kiasi sahihi'),
                            backgroundColor: Colors.red));
                        return;
                      }
                      business.addExpense(Expense(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: selectedCategory!,
                        amount: amount,
                        date: selectedDate,
                        recordedBy: auth.currentUser?.name ?? 'Admin',
                        note: noteController.text.trim().isEmpty
                            ? null : noteController.text.trim(),
                      ));
                      Navigator.pop(context);
                      NotificationService.show(
                        context: context,
                        message: 'Matumizi ya ${selectedCategory!} yamehifadhiwa',
                        type: NotificationType.success,
                      );
                      setState(() {});
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

  void _showCategorySheet(BuildContext context, BusinessState business,
      StateSetter setModal, Function(String) onSelected) {
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
          const Text('Aina ya Matumizi', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: kNavyBlue)),
          const SizedBox(height: 12),
          Flexible(child: ListView(shrinkWrap: true, children: [
            ...business.expenseCategories.map((cat) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: _categoryColor(cat).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(_categoryIcon(cat),
                    color: _categoryColor(cat), size: 18)),
              title: Text(cat),
              onTap: () { setModal(() => onSelected(cat)); Navigator.pop(context); },
            )),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: kNavyBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, color: kNavyBlue, size: 18)),
              title: const Text('Ongeza Aina Mpya', style: TextStyle(
                  color: kNavyBlue, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _showAddCategoryDialog(
                    context, business, setModal, onSelected);
              },
            ),
          ])),
        ]),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, BusinessState business,
      StateSetter setModal, Function(String) onSelected) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Aina Mpya ya Matumizi',
            style: TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller, autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Mf. Dawa, Matangazo...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Ghairi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kNavyBlue, foregroundColor: Colors.white),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                business.addExpenseCategory(value);
                setModal(() => onSelected(value));
              }
              Navigator.pop(context);
            },
            child: const Text('Hifadhi'),
          ),
        ],
      ),
    );
  }
}

// ===== MADENI TAB =====
class _MadeniTab extends StatelessWidget {
  final bool isAdmin;
  final SellerPermissions perms;
  const _MadeniTab({required this.isAdmin, required this.perms});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final auth = context.watch<AuthState>();
    final myName = auth.currentUser?.name ?? 'Admin';

    final debts = business.salesHistory.where((s) {
      if (s.paid) return false;
      if (isAdmin || perms.canViewAllDebts) return true;
      return s.sellerName == myName;
    }).toList();

    final totalMadeni = debts.fold<int>(0, (sum, s) => sum + s.remainingAmount);

    return RefreshIndicator(
      color: kNavyBlue,
      strokeWidth: 2.5,
      onRefresh: () async => await Future.delayed(
          const Duration(milliseconds: 600)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (!isAdmin && !perms.canViewAllDebts)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  const Text('Unaona madeni ya mauzo yako tu',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7C3AED))),
                ]),
              ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kOrange, Color(0xFFEA580C)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Jumla ya Madeni Yaliyobaki',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text('${_fmtCurrency(totalMadeni)} TZS',
                    style: const TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${debts.length} order ${debts.length == 1 ? 'haijalipiwa' : 'hazijalipwa'} kikamilifu',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),

            const SizedBox(height: 20),

            const Text('Orodha ya Madeni', style: TextStyle(fontSize: 15,
                fontWeight: FontWeight.bold, color: kNavyBlue)),
            const SizedBox(height: 12),

            if (debts.isEmpty)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Icon(Icons.check_circle_outline, size: 48,
                      color: const Color(0xFF22C55E).withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('Hakuna madeni! 🎉', style: TextStyle(
                      fontWeight: FontWeight.bold, color: kNavyBlue, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Mauzo yote yameshalipwa',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ]),
              )
            else
              ...debts.map((sale) => _DebtCard(sale: sale)),
          ],
        ),
      ),
    );
  }
}

// ===== DEBT CARD =====
class _DebtCard extends StatelessWidget {
  final SaleEntry sale;
  const _DebtCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final progress = sale.paymentProgress;
    final hasPartialPayment = sale.paidAmount > 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => DebtDetailPage(sale: sale))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10, offset: const Offset(0, 2))]),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: kOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.schedule, color: kOrange, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sale.orderNumber, style: TextStyle(fontSize: 11,
                        color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(sale.customerName ?? 'Mteja Asiyejulikana',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 14, color: kNavyBlue)),
                    Text('Muuzaji: ${sale.sellerName}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('${_fmtCurrency(sale.remainingAmount)} TZS',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 14, color: Color(0xFFEF4444)))),
                  const SizedBox(height: 4),
                  Text('Kinachobaki', style: TextStyle(fontSize: 10,
                      color: Colors.grey.shade400)),
                ]),
              ]),
              const SizedBox(height: 12),
              if (hasPartialPayment) ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Kimelipwa: ${_fmtCurrency(sale.paidAmount)} TZS',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600)),
                  Text('Jumla: ${_fmtCurrency(sale.amount)} TZS',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ]),
                const SizedBox(height: 6),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
                  minHeight: 5,
                ),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16))),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined, size: 13,
                  color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('${sale.date.day}/${sale.date.month}/${sale.date.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const Spacer(),
              GestureDetector(
                onTap: () => _sendDebtReminder(context, sale),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: kNavyBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.notifications_outlined, size: 13, color: kNavyBlue),
                    SizedBox(width: 4),
                    Text('Mkumbushe', style: TextStyle(fontSize: 11,
                        color: kNavyBlue, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ===== SUMMARY CARD =====
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
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 12, color: color)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11,
              color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}