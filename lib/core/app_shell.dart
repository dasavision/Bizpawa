import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/features/sales/sales_page.dart';
import 'package:bizpawa/features/dashboard/dashboard_page.dart';
import 'package:bizpawa/features/inventory/inventory_page.dart';
import 'package:bizpawa/features/analytics/analytics_page.dart';
import 'package:bizpawa/features/more/more_page.dart';

const _kNavy = Color(0xFF1B2E6B);

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isAdmin = auth.isAdmin;
    final perms = auth.permissions;

    // ===== TABS ZINAZOONYESHWA =====
    // Admin → anaona tabs zote
    // Muuzaji → anaona tu tabs alizopewa ruhusa
    //
    // Tab index:
    //   0 = Dashibodi
    //   1 = Mauzo
    //   2 = Stock
    //   3 = Madeni/Analytics
    //   4 = Zaidi

    final List<_TabItem> allTabs = [
      _TabItem(
        page: const DashboardPage(),
        label: 'Dashibodi',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        // Dashibodi inaonyeshwa kila wakati
        allowed: true,
      ),
      _TabItem(
        page: const SalesPage(),
        label: 'Mauzo',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        // Muuzaji anahitaji ruhusa ya mauzo
        allowed: isAdmin || perms.canRecordSales || perms.canViewOtherSales,
      ),
      _TabItem(
        page: const InventoryPage(),
        label: 'Stock',
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        // Muuzaji anahitaji ruhusa ya kuona bidhaa
        allowed: isAdmin || perms.canViewProducts,
      ),
      _TabItem(
        page: const AnalyticsPage(),
        label: 'Madeni',
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        // Muuzaji anahitaji ruhusa ya madeni au matumizi
        allowed: isAdmin ||
            perms.canViewAllDebts ||
            perms.canRecordExpenses ||
            perms.canViewDailyReport,
      ),
      _TabItem(
        page: const MorePage(),
        label: 'Zaidi',
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        // Zaidi inaonyeshwa kila wakati (logout ipo hapa)
        allowed: true,
      ),
    ];

    // Chagua tabs zinazoruhusiwa tu
    final visibleTabs = allTabs.where((t) => t.allowed).toList();

    // Validate index — isiende nje ya mipaka baada ya tabs kubadilika
    final safeIndex = _currentIndex.clamp(0, visibleTabs.length - 1);

    return Scaffold(
      body: visibleTabs[safeIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _kNavy,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) => setState(() => _currentIndex = index),
        items: visibleTabs.map((tab) => BottomNavigationBarItem(
          icon: Icon(tab.icon),
          activeIcon: Icon(tab.activeIcon),
          label: tab.label,
        )).toList(),
      ),
    );
  }
}

class _TabItem {
  final Widget page;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool allowed;

  const _TabItem({
    required this.page,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.allowed,
  });
}