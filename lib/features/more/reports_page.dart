import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
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
        title: const Text('Ripoti',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          labelColor: _kNavy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kNavy,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Muhtasari'),
            Tab(text: 'Stock'),
            Tab(text: 'Mauzo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _MuhtasariTab(),
          _StockTab(),
          _MauzoTab(),
        ],
      ),
    );
  }
}

// ===== TAB 1: MUHTASARI WA SIKU =====
class _MuhtasariTab extends StatefulWidget {
  const _MuhtasariTab();

  @override
  State<_MuhtasariTab> createState() => _MuhtasariTabState();
}

class _MuhtasariTabState extends State<_MuhtasariTab> {
  DateTime _selectedDate = DateTime.now();

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessState>();

    final daySales = biz.salesHistory
        .where((s) => _isSameDay(s.date, _selectedDate) && s.paid)
        .fold<int>(0, (sum, s) => sum + s.amount);

    final dayExpenses = biz.expensesList
        .where((e) => _isSameDay(e.date, _selectedDate))
        .fold<int>(0, (sum, e) => sum + e.amount);

    final dayProfit = daySales - dayExpenses;

    final newDebts = biz.salesHistory
        .where((s) =>
            _isSameDay(s.date, _selectedDate) && !s.paid)
        .fold<int>(0, (sum, s) => sum + s.amount);

    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kNavy.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: _kNavy, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    isToday
                        ? 'Leo — ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
                        : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                        color: _kNavy, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down,
                      color: _kNavy),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Closing report card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.summarize_outlined,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    const Text('Ripoti ya Kufunga Siku',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                _ReportRow(
                    label: 'Mauzo ya Siku',
                    value: '${_fmt(daySales)} TZS',
                    valueColor: Colors.white),
                const Divider(color: Colors.white24, height: 20),
                _ReportRow(
                    label: 'Matumizi',
                    value: '- ${_fmt(dayExpenses)} TZS',
                    valueColor: const Color(0xFFFF6B6B)),
                const Divider(color: Colors.white24, height: 20),
                _ReportRow(
                    label: 'Faida Halisi',
                    value: '${dayProfit >= 0 ? '' : '-'} ${_fmt(dayProfit.abs())} TZS',
                    valueColor: dayProfit >= 0
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFF6B6B),
                    isBold: true),
                const Divider(color: Colors.white24, height: 20),
                _ReportRow(
                    label: 'Madeni Mapya',
                    value: '${_fmt(newDebts)} TZS',
                    valueColor: _kOrange),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Matumizi breakdown
          const Text('Matumizi kwa Aina',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy)),
          const SizedBox(height: 12),

          ...(() {
            final dayExpensesList = biz.expensesList
                .where((e) => _isSameDay(e.date, _selectedDate))
                .toList();

            if (dayExpensesList.isEmpty) {
              return [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('Hakuna matumizi siku hii',
                        style: TextStyle(
                            color: Colors.grey.shade400)),
                  ),
                )
              ];
            }

            final Map<String, int> byCategory = {};
            for (final e in dayExpensesList) {
              byCategory[e.category] =
                  (byCategory[e.category] ?? 0) + e.amount;
            }

            return byCategory.entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(entry.key,
                          style: const TextStyle(
                              fontSize: 13,
                              color: _kNavy,
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('${_fmt(entry.value)} TZS',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444))),
                    ],
                  ),
                ));
          })(),
        ],
      ),
    );
  }
}

// ===== TAB 2: STOCK =====
class _StockTab extends StatelessWidget {
  const _StockTab();

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessState>();
    final products =
        biz.inventory.where((p) => p.unit != 'SERVICE').toList();
    final services =
        biz.inventory.where((p) => p.unit == 'SERVICE').toList();

    final totalBuying = biz.totalBuyingStockValue;
    final totalSelling = biz.totalSellingStockValue;
    final potentialProfit = totalSelling - totalBuying;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                  label: 'Thamani ya Kununua',
                  value: '${_fmt(totalBuying)} TZS',
                  color: _kNavy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniCard(
                  label: 'Thamani ya Kuuza',
                  value: '${_fmt(totalSelling)} TZS',
                  color: const Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MiniCard(
            label: 'Faida Inayotarajiwa (Stock yote)',
            value: '${_fmt(potentialProfit)} TZS',
            color: _kOrange,
            fullWidth: true,
          ),

          const SizedBox(height: 20),

          // Low stock warning
          if (biz.lowStockCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFEF4444)
                        .withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined,
                      color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${biz.lowStockCount} bidhaa zina stock chini ya 5',
                    style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Text('Hali ya Stock',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy)),
          const SizedBox(height: 12),

          if (products.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Hakuna bidhaa bado',
                    style:
                        TextStyle(color: Colors.grey.shade400)),
              ),
            )
          else
            ...products.map((p) {
              final isLow = p.stock <= 5;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isLow
                      ? Border.all(
                          color: const Color(0xFFEF4444)
                              .withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _kNavy)),
                          Text(p.category,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text('${p.stock} ${p.unit}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isLow
                                    ? const Color(0xFFEF4444)
                                    : _kNavy)),
                        Text(
                            'Kuuza: ${_fmt(p.sellingPrice)} TZS',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              );
            }),

          if (services.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Huduma',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kNavy)),
            const SizedBox(height: 12),
            ...services.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.design_services_outlined,
                          color: _kNavy, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _kNavy)),
                      ),
                      Text('${_fmt(s.sellingPrice)} TZS',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _kNavy)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ===== TAB 3: MAUZO =====
class _MauzoTab extends StatelessWidget {
  const _MauzoTab();

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessState>();
    final sales = biz.salesHistory;

    final totalMauzo =
        sales.where((s) => s.paid).fold<int>(0, (sum, s) => sum + s.amount);
    final totalMadeni = sales
        .where((s) => !s.paid)
        .fold<int>(0, (sum, s) => sum + s.remainingAmount);

    // Njia za malipo breakdown
    final Map<String, int> byMethod = {};
    for (final s in sales.where((s) => s.paid)) {
      final method = s.paymentMethod ?? 'cash';
      byMethod[method] = (byMethod[method] ?? 0) + s.amount;
    }

    // Bidhaa zilizouzwa zaidi
    final Map<String, int> byProduct = {};
    for (final s in sales) {
      for (final item in s.items) {
        byProduct[item.productName] =
            (byProduct[item.productName] ?? 0) + item.quantity;
      }
    }
    final topProducts = byProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MiniCard(
                  label: 'Jumla ya Mauzo',
                  value: '${_fmt(totalMauzo)} TZS',
                  color: _kNavy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniCard(
                  label: 'Madeni Yote',
                  value: '${_fmt(totalMadeni)} TZS',
                  color: _kOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text('Njia za Malipo',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy)),
          const SizedBox(height: 12),

          if (byMethod.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Hakuna mauzo bado',
                    style:
                        TextStyle(color: Colors.grey.shade400)),
              ),
            )
          else
            ...byMethod.entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(_methodIcon(e.key),
                          color: _kNavy, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_methodLabel(e.key),
                            style: const TextStyle(
                                fontSize: 13,
                                color: _kNavy,
                                fontWeight: FontWeight.w500)),
                      ),
                      Text('${_fmt(e.value)} TZS',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _kNavy)),
                    ],
                  ),
                )),

          const SizedBox(height: 20),

          const Text('Bidhaa Zilizouzwa Zaidi',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _kNavy)),
          const SizedBox(height: 12),

          if (topProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Hakuna data bado',
                    style:
                        TextStyle(color: Colors.grey.shade400)),
              ),
            )
          else
            ...topProducts.take(10).map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _kNavy.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            '${topProducts.indexOf(e) + 1}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _kNavy),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.key,
                            style: const TextStyle(
                                fontSize: 13,
                                color: _kNavy,
                                fontWeight: FontWeight.w500)),
                      ),
                      Text('${e.value} vilivyouzwa',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_outlined;
      case 'mobile':
        return Icons.phone_android_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  String _methodLabel(String method) {
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

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  const _ReportRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.w600)),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _MiniCard({
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}