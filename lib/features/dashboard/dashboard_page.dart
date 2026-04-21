import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/features/auth/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

String formatCurrency(int amount) {
  return amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _tipsController = PageController();
  int _currentTip = 0;
  Timer? _timer;

  // Admin anaweza kuficha/kuonyesha faida (privacy mode)
  bool _profitVisible = true;

  final List<Map<String, String>> _tips = [
    {'icon': '💡', 'title': 'Angalia Stock Yako',
      'body': 'Bidhaa zinazokaribia kuisha zinapoteza wateja. Agiza mapema!'},
    {'icon': '📈', 'title': 'Faida Inakua',
      'body': 'Weka bei ya kuuza angalau 20% juu ya bei ya kununua.'},
    {'icon': '🤝', 'title': 'Wateja wa Mkopo',
      'body': 'Weka rekodi ya madeni yote ili usipoteze pesa yako.'},
    {'icon': '⚡', 'title': 'Bidhaa Zinazotoka Haraka',
      'body': 'Zinazotoka haraka ndizo zinazoleta faida zaidi. Zipe kipaumbele!'},
    {'icon': '📅', 'title': 'Tarehe ya Kuharibika',
      'body': 'Angalia bidhaa za karibia kuharibika. Uza kwanza kabla hazijaharibika.'},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentTip + 1) % _tips.length;
      _tipsController.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentTip = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tipsController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final auth = context.watch<AuthState>();
    final isAdmin = auth.isAdmin;
    final perms = auth.permissions;

    final businessName = business.businessName;
    final businessInitial = businessName.trim().isNotEmpty
        ? businessName.trim()[0].toUpperCase()
        : 'B';

    // Jina la mtumiaji aliyeingia (Admin au Muuzaji)
    final userName = auth.currentUser?.name ?? businessName;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 36),
          ],
        ),
        actions: [
          // Bell ya notifications
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: kNavyBlue, size: 26),
                onPressed: () => _showNotifications(context),
              ),
              if (NotificationService.unreadCount > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(
                        color: kOrange, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        NotificationService.unreadCount > 9
                            ? '9+' : NotificationService.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white,
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Msaada
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined,
                color: kNavyBlue, size: 24),
            onPressed: () => _callSupport(context),
          ),

          // Profile circle
          GestureDetector(
            onTap: () => _showProfileSheet(
                context, businessName, businessInitial),
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 4),
              width: 36, height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kNavyBlue, Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (auth.currentUser?.name ?? businessName)[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        color: kNavyBlue,
        strokeWidth: 2.5,
        displacement: 20,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Greeting — jina la mtumiaji aliyeingia
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Habari, $userName! 👋',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600,
                        color: kNavyBlue,
                      ),
                    ),
                  ),
                  // Badge ya role
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? kNavyBlue.withValues(alpha: 0.1)
                          : const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAdmin ? '👑 Admin' : '👤 Muuzaji',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: isAdmin
                            ? kNavyBlue : const Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mauzo ya leo — inaonyeshwa kila wakati
              _TodaySalesCard(
                amount: business.todaySales,
                changePercent: business.todaySalesChangePercent,
              ),

              const SizedBox(height: 16),

              // Faida ya Leo + Thamani ya Stock
              Row(
                children: [
                  // ===== FAIDA YA LEO — PERMISSIONS =====
                  Expanded(
                    child: isAdmin
                        // ADMIN: anaona faida + kitufe cha jicho (kuficha/kuonyesha)
                        ? _ProfitCardAdmin(
                            profit: business.todayNetProfit,
                            visible: _profitVisible,
                            onToggle: () => setState(
                                () => _profitVisible = !_profitVisible),
                          )
                        // MUUZAJI: anaona lock ikiwa hana ruhusa
                        : perms.canViewProfitAnalytics
                            ? _InfoCard(
                                title: 'Faida ya Leo',
                                value:
                                    '${formatCurrency(business.todayNetProfit)} TZS',
                                color: business.todayNetProfit >= 0
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                                icon: business.todayNetProfit >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                              )
                            : const _LockedCard(
                                title: 'Faida ya Leo',
                                reason: 'Ruhusa inahitajika',
                              ),
                  ),

                  const SizedBox(width: 12),

                  // Thamani ya Stock
                  Expanded(
                    child: _InfoCard(
                      title: 'Thamani ya Stock',
                      value: '${formatCurrency(business.totalStockValue)} TZS',
                      color: kNavyBlue,
                      icon: Icons.inventory,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stock insights
              const Text('Taarifa za Stock',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w600, color: kNavyBlue)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MiniCard(
                      title: 'Zinazokaribia\nKuisha',
                      value: business.lowStockCount.toString(),
                      color: const Color(0xFFF97316),
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCard(
                      title: 'Karibia\nKu-expire',
                      value: business.expiringSoonCount.toString(),
                      color: const Color(0xFFEF4444),
                      icon: Icons.event_busy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniCard(
                      title: 'Zinazotoka\nHaraka',
                      value: business.fastMovingCount.toString(),
                      color: const Color(0xFF0EA5E9),
                      icon: Icons.bolt,
                    ),
                  ),
                ],
              ),

              // Muuzaji — onyesha permissions zake
              if (!isAdmin) ...[
                const SizedBox(height: 20),
                _SellerPermissionsCard(perms: perms),
              ],

              const SizedBox(height: 28),

              // Tips carousel
              const Text('Vidokezo vya Biashara',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w600, color: kNavyBlue)),
              const SizedBox(height: 12),

              SizedBox(
                height: 110,
                child: PageView.builder(
                  controller: _tipsController,
                  onPageChanged: (i) => setState(() => _currentTip = i),
                  itemCount: _tips.length,
                  itemBuilder: (context, index) {
                    final tip = _tips[index];
                    return _TipCard(
                      icon: tip['icon']!,
                      title: tip['title']!,
                      body: tip['body']!,
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_tips.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentTip == index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _currentTip == index
                          ? kNavyBlue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    NotificationService.markAllRead();
    setState(() {});
    final notifications = NotificationService.history;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Taarifa za Leo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: kNavyBlue)),
            const SizedBox(height: 16),
            notifications.isEmpty
                ? Center(child: Column(children: [
                    const SizedBox(height: 20),
                    Icon(Icons.notifications_none, size: 48,
                        color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Hakuna taarifa leo',
                        style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 20),
                  ]))
                : Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final n = notifications[index];
                        Color typeColor() {
                          switch (n.type) {
                            case NotificationType.success: return const Color(0xFF22C55E);
                            case NotificationType.error: return const Color(0xFFEF4444);
                            case NotificationType.warning: return kOrange;
                            case NotificationType.info: return kNavyBlue;
                          }
                        }
                        IconData typeIcon() {
                          switch (n.type) {
                            case NotificationType.success: return Icons.check_circle_outline;
                            case NotificationType.error: return Icons.error_outline;
                            case NotificationType.warning: return Icons.warning_amber_rounded;
                            case NotificationType.info: return Icons.info_outline;
                          }
                        }
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: typeColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8)),
                            child: Icon(typeIcon(), color: typeColor(), size: 18)),
                          title: Text(n.message,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            '${n.time.hour.toString().padLeft(2, '0')}:${n.time.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _callSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Piga Simu Msaada'),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.headset_mic, size: 40, color: kNavyBlue),
          SizedBox(height: 12),
          Text('+255 753 412 681',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: kNavyBlue)),
          SizedBox(height: 8),
          Text('Timu yetu iko tayari kukusaidia',
              style: TextStyle(color: Colors.black54)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Ghairi')),
          ElevatedButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('Piga Simu'),
            onPressed: () async {
  Navigator.pop(context);
  final uri = Uri(scheme: 'tel', path: '+255753412681');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
},
          ),
        ],
      ),
    );
  }

  void _showProfileSheet(
      BuildContext context, String businessName, String businessInitial) {
    final business = context.read<BusinessState>();
    final auth = context.read<AuthState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [kNavyBlue, Color(0xFF2563EB)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                (auth.currentUser?.name ?? businessName)[0].toUpperCase(),
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 28))),
            ),
            const SizedBox(height: 12),
            Text(auth.currentUser?.name ?? businessName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: kNavyBlue)),
            const SizedBox(height: 4),
            Text(auth.isAdmin ? '👑 Admin' : '👤 Muuzaji',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            if (business.businessAddress.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(business.businessAddress,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
            const SizedBox(height: 8),
            Text(business.businessPhone,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Toka', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Toka kwenye App?',
                        style: TextStyle(color: kNavyBlue,
                            fontWeight: FontWeight.bold)),
                    content: const Text('Una uhakika unataka kutoka?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context),
                          child: const Text('Ghairi')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          context.read<AuthState>().logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        },
                        child: const Text('Toka'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ===== FAIDA CARD — ADMIN (na jicho la privacy) =====
class _ProfitCardAdmin extends StatelessWidget {
  final int profit;
  final bool visible;
  final VoidCallback onToggle;

  const _ProfitCardAdmin({
    required this.profit,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profit >= 0;
    final color = isPositive
        ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color, size: 18),
              const Spacer(),
              // Kitufe cha jicho — kuficha/kuonyesha faida
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: color.withValues(alpha: 0.7),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Faida ya Leo',
              style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 4),
          visible
              ? Text(
                  '${formatCurrency(profit.abs())} TZS',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 15, color: color),
                )
              : Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
        ],
      ),
    );
  }
}

// ===== LOCKED CARD — Muuzaji asiye na ruhusa =====
class _LockedCard extends StatelessWidget {
  final String title;
  final String reason;

  const _LockedCard({required this.title, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 18),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 4),
          Text(reason,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

// ===== SELLER PERMISSIONS CARD =====
class _SellerPermissionsCard extends StatelessWidget {
  final SellerPermissions perms;
  const _SellerPermissionsCard({required this.perms});

  @override
  Widget build(BuildContext context) {
    final granted = <String>[];
    final denied = <String>[];

    void check(bool has, String name) =>
        has ? granted.add(name) : denied.add(name);

    check(perms.canRecordSales, 'Kuuza');
    check(perms.canViewProducts, 'Kuona Stock');
    check(perms.canAddProduct, 'Kuongeza Bidhaa');
    check(perms.canViewBuyingPrice, 'Kuona Bei ya Kununua');
    check(perms.canViewProfitAnalytics, 'Kuona Faida');
    check(perms.canRecordExpenses, 'Kurekodi Matumizi');
    check(perms.canViewAllDebts, 'Kuona Madeni Yote');
    check(perms.canRefund, 'Kufanya Refund');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.shield_outlined, color: kNavyBlue, size: 16),
            const SizedBox(width: 6),
            const Text('Ruhusa Zako',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: kNavyBlue)),
          ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              ...granted.map((p) => _PermChip(label: p, granted: true)),
              ...denied.map((p) => _PermChip(label: p, granted: false)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermChip extends StatelessWidget {
  final String label;
  final bool granted;
  const _PermChip({required this.label, required this.granted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: granted
            ? const Color(0xFF22C55E).withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: granted
              ? const Color(0xFF22C55E).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(granted ? Icons.check : Icons.lock_outline,
            size: 11,
            color: granted
                ? const Color(0xFF22C55E) : Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10,
                color: granted ? const Color(0xFF22C55E) : Colors.grey.shade400,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ===== EXISTING WIDGETS (unchanged) =====

class _TodaySalesCard extends StatelessWidget {
  final int amount;
  final double changePercent;

  const _TodaySalesCard({required this.amount, required this.changePercent});

  @override
  Widget build(BuildContext context) {
    final isUp = changePercent >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kNavyBlue, Color(0xFF2563EB)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mauzo ya Leo',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('${formatCurrency(amount)} TZS',
              style: const TextStyle(fontSize: 28,
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text('${changePercent.abs().toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 6),
            const Text('kuliko jana',
                style: TextStyle(color: Colors.white70)),
          ]),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _InfoCard({required this.title, required this.value,
      required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniCard({required this.title, required this.value,
      required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String icon;
  final String title;
  final String body;

  const _TipCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kNavyBlue, Color(0xFF2563EB)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: Colors.white70,
                    fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}