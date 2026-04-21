import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/features/auth/login_page.dart';
import 'customers_page.dart';
import 'suppliers_page.dart';
import 'sellers_page.dart';
import 'reports_page.dart';
import 'notes_page.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final auth = context.watch<AuthState>();
    final isAdmin = auth.isAdmin;
    final perms = auth.permissions;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _kNavy,
            expandedHeight: 100,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Zaidi', style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(business.businessName,
                      style: const TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // USER INFO CARD
                  _UserInfoCard(
                    user: auth.currentUser,
                    onLogout: () => _confirmLogout(context, auth),
                  ),

                  const SizedBox(height: 20),

                  // HARAKA GRID — zinaonyesha kulingana na permissions
                  _sectionLabel('Haraka'),
                  const SizedBox(height: 10),

                  // Build quick cards dynamically
                  _buildQuickCards(context, business, auth, isAdmin, perms),

                  const SizedBox(height: 20),

                  // ZANA — Notes zinaonekana kwa wote
                  _sectionLabel('Zana'),
                  const SizedBox(height: 10),
                  _NotesPreviewCard(
                      onTap: () => _go(context, const NotesPage())),

                  const SizedBox(height: 20),

                  // MIPANGILIO — Admin peke yake anabadilisha taarifa za biashara
                  _sectionLabel('Mipangilio'),
                  const SizedBox(height: 10),

                  if (isAdmin) ...[
                    _SettingsItem(
                      icon: Icons.store_outlined,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: _kNavy,
                      title: 'Taarifa za Biashara',
                      subtitle: business.businessName,
                      onTap: () => _showBusinessProfileSheet(context, business),
                    ),
                    const SizedBox(height: 8),
                  ],

                  _SettingsItem(
                    icon: Icons.info_outline,
                    iconBg: Colors.grey.shade100,
                    iconColor: Colors.grey.shade600,
                    title: 'Kuhusu BizPawa',
                    subtitle: 'Toleo 1.0.0 • Smarter Control, Stronger Growth',
                    onTap: () => _showAbout(context),
                  ),

                  const SizedBox(height: 8),

                  // LOGOUT
                  GestureDetector(
                    onTap: () => _confirmLogout(context, auth),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 14),
                        Expanded(child: Text('Toka kwenye App',
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600, color: Colors.red))),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== QUICK CARDS — dynamic kulingana na permissions =====
  Widget _buildQuickCards(BuildContext context, BusinessState business,
      AuthState auth, bool isAdmin, SellerPermissions perms) {

    // Wateja — admin au mwenye ruhusa ya kuona madeni (anahitaji kujua wateja)
    final canSeeCustomers = isAdmin || perms.canViewAllDebts ||
        perms.canPayDebt;
    // Wasambazaji — admin peke yake
    final canSeeSuppliers = isAdmin;
    // Wauzaji — admin peke yake
    final canSeeSellers = isAdmin;
    // Ripoti — admin au mwenye ruhusa ya ripoti
    final canSeeReports = isAdmin || perms.canViewDailyReport ||
        perms.canViewSalesReport || perms.canViewProductReport;

    final List<Widget> cards = [];

    if (canSeeCustomers)
      cards.add(_QuickCard(
        icon: Icons.people_outline,
        iconBg: const Color(0xFFEEF2FF),
        iconColor: _kNavy,
        title: 'Wateja',
        subtitle: '${business.customers.length} wamesajiliwa',
        onTap: () => _go(context, const CustomersPage()),
      ));

    if (canSeeSuppliers)
      cards.add(_QuickCard(
        icon: Icons.local_shipping_outlined,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFEA580C),
        title: 'Wasambazaji',
        subtitle: '${business.suppliers.length} wasambazaji',
        onTap: () => _go(context, const SuppliersPage()),
      ));

    if (canSeeSellers)
      cards.add(_QuickCard(
        icon: Icons.badge_outlined,
        iconBg: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF16A34A),
        title: 'Wauzaji',
        subtitle: '${auth.sellers.length} wauzaji',
        onTap: () => _go(context, const SellersPage()),
      ));

    if (canSeeReports)
      cards.add(_QuickCard(
        icon: Icons.bar_chart_outlined,
        iconBg: const Color(0xFFFFF0F0),
        iconColor: const Color(0xFFEF4444),
        title: 'Ripoti',
        subtitle: 'Mauzo, stock, faida',
        onTap: () => _go(context, const ReportsPage()),
      ));

    if (cards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(children: [
          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Text('Hakuna vipengele vilivyoidhinishwa',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ]),
      );
    }

    // Ikiwa kuna cards 1 au 3, tumia ListView
    if (cards.length <= 1 || cards.length == 3) {
      return Column(
        children: cards.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 10), child: c)).toList(),
      );
    }

    // Cards 2 au 4 — grid 2 columns
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: cards,
    );
  }

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _sectionLabel(String label) => Text(
    label.toUpperCase(),
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
        color: Colors.grey.shade500, letterSpacing: 0.8),
  );

  void _confirmLogout(BuildContext context, AuthState auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Toka kwenye App?',
            style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold)),
        content: Text('Unataka kutoka kama ${auth.currentUser?.name ?? 'Admin'}?',
            style: TextStyle(color: Colors.grey.shade600)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Ghairi')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              auth.logout();
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false);
            },
            child: const Text('Toka'),
          ),
        ],
      ),
    );
  }

  void _showBusinessProfileSheet(BuildContext context, BusinessState business) {
    final nameCtrl = TextEditingController(text: business.businessName);
    final phoneCtrl = TextEditingController(text: business.businessPhone);
    final addressCtrl = TextEditingController(text: business.businessAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Taarifa za Biashara', style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold, color: _kNavy)),
              const SizedBox(height: 6),
              Text('Taarifa hizi zitaonekana kwenye risiti na dashibodi',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 20),

              const Text('Jina la Biashara', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: _kNavy)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: 'Mf. Duka la Amani',
                    prefixIcon: const Icon(Icons.store_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 14),

              const Text('Namba ya Simu', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: _kNavy)),
              const SizedBox(height: 6),
              TextField(controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: '0712 345 678',
                    prefixText: '+255 ',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 14),

              const Text('Anuani / Mahali', style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: _kNavy)),
              const SizedBox(height: 6),
              TextField(controller: addressCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                    hintText: 'Mf. Kariakoo, Dar es Salaam',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.save_outlined, size: 20),
                  label: const Text('Hifadhi Taarifa', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    business.updateBusinessProfile(
                      name: nameCtrl.text.trim().isEmpty
                          ? business.businessName : nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim().isEmpty
                          ? business.businessPhone : phoneCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('BizPawa',
            style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smarter Control, Stronger Growth',
                style: TextStyle(color: _kOrange, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('Toleo: 1.0.0',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text('Msaada: +255 753 412 681',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kNavy,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }
}

// ===== WIDGETS =====

class _UserInfoCard extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onLogout;

  const _UserInfoCard({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kNavy, Color(0xFF2563EB)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(user!.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: Colors.white)))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user!.name, style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(user!.isAdmin ? '👑 Admin' : '@${user!.username}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        )),
        GestureDetector(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              Icon(Icons.logout, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text('Toka', style: TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({required this.icon, required this.iconBg,
      required this.iconColor, required this.title, required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 18)),
          const Spacer(),
          Text(title, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.bold, color: _kNavy)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11,
              color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}

class _NotesPreviewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NotesPreviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.sticky_note_2_outlined,
                  color: Color(0xFFF59E0B), size: 20)),
          const SizedBox(width: 14),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kumbukumbu zangu', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.bold, color: _kNavy)),
              SizedBox(height: 2),
              Text('Andika maelezo, vikumbusho, mipango...',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({required this.icon, required this.iconBg,
      required this.iconColor, required this.title, required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(color: iconBg,
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: _kNavy)),
              Text(subtitle, style: TextStyle(fontSize: 11,
                  color: Colors.grey.shade500)),
            ],
          )),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }
}