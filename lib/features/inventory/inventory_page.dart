import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'add_product_page.dart';
import 'add_service_page.dart';
import 'product_detail_page.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

enum InventoryFilter { available, lowStock, outOfStock, expiringSoon }
enum TypeFilter { all, bidhaa, huduma }

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  InventoryFilter _currentFilter = InventoryFilter.available;
  TypeFilter _typeFilter = TypeFilter.all;
  String? _selectedKundi;
  String _searchQuery = '';

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
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

    // Muuzaji asiye na ruhusa ya kuona bidhaa → onyesha locked screen
    if (!isAdmin && !perms.canViewProducts) {
      return _LockedPage(
        icon: Icons.inventory_2_outlined,
        title: 'Stock / Bidhaa',
        message: 'Huna ruhusa ya kuona bidhaa.\nOmba Admin akupe ruhusa.',
      );
    }

    final filteredItems = business.inventory.where((item) {
      final matchesSearch = item.name.toLowerCase()
          .contains(_searchQuery.toLowerCase());
      bool matchesType = true;
      switch (_typeFilter) {
        case TypeFilter.bidhaa: matchesType = item.unit != 'SERVICE'; break;
        case TypeFilter.huduma: matchesType = item.unit == 'SERVICE'; break;
        case TypeFilter.all: matchesType = true; break;
      }
      final matchesKundi = _selectedKundi == null || item.category == _selectedKundi;
      bool matchesStatus = true;
      switch (_currentFilter) {
        case InventoryFilter.available:
          matchesStatus = item.unit == 'SERVICE' || item.stock > 0; break;
        case InventoryFilter.lowStock:
          matchesStatus = item.unit != 'SERVICE' && item.stock > 0 && item.stock <= 5; break;
        case InventoryFilter.outOfStock:
          matchesStatus = item.unit != 'SERVICE' && item.stock == 0; break;
        case InventoryFilter.expiringSoon:
          if (item.expiryDate == null) return false;
          final days = item.expiryDate!.difference(DateTime.now()).inDays;
          matchesStatus = days >= 0 && days <= 5;
          break;
      }
      return matchesSearch && matchesType && matchesKundi && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Bidhaa / Huduma Stock',
            style: TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold)),
      ),

      body: Column(
        children: [
          // SEARCH + FILTERS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tafuta bidhaa...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showFilterSheet(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _currentFilter != InventoryFilter.available
                              ? kNavyBlue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.tune,
                            color: _currentFilter != InventoryFilter.available
                                ? Colors.white : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _typeChip(label: 'Zote',
                          selected: _typeFilter == TypeFilter.all && _selectedKundi == null,
                          onTap: () => setState(() {
                            _typeFilter = TypeFilter.all; _selectedKundi = null;
                          })),
                      _typeChip(label: 'Bidhaa', icon: Icons.inventory_2_outlined,
                          selected: _typeFilter == TypeFilter.bidhaa, color: kNavyBlue,
                          onTap: () => setState(() {
                            _typeFilter = TypeFilter.bidhaa; _selectedKundi = null;
                          })),
                      _typeChip(label: 'Huduma', icon: Icons.handyman_outlined,
                          selected: _typeFilter == TypeFilter.huduma, color: kOrange,
                          onTap: () => setState(() {
                            _typeFilter = TypeFilter.huduma; _selectedKundi = null;
                          })),
                      _typeChip(label: _selectedKundi ?? 'Makundi',
                          icon: Icons.category_outlined,
                          selected: _selectedKundi != null,
                          color: const Color(0xFF6366F1),
                          onTap: () => _showKundiSheet(context.read<BusinessState>())),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SUMMARY CARDS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _SummaryCard(title: 'Bidhaa',
                    value: business.totalItemsCount.toString(),
                    icon: Icons.inventory_2_outlined, color: kNavyBlue),
                const SizedBox(width: 10),
                // Bei ya kununua — inaonyeshwa ikiwa admin au ana ruhusa
                _SummaryCard(
                    title: 'Thamani Kununua',
                    value: (isAdmin || perms.canViewBuyingPrice)
                        ? '${_formatAmount(business.totalBuyingStockValue)} TZS'
                        : '--- TZS',
                    icon: Icons.shopping_cart_outlined,
                    color: const Color(0xFFF97316)),
                const SizedBox(width: 10),
                _SummaryCard(title: 'Thamani Kuuza',
                    value: '${_formatAmount(business.totalSellingStockValue)} TZS',
                    icon: Icons.sell_outlined, color: const Color(0xFF22C55E)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (_currentFilter != InventoryFilter.available)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: kNavyBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.filter_alt, size: 14, color: kNavyBlue),
                      const SizedBox(width: 4),
                      Text(_filterLabel(_currentFilter),
                          style: const TextStyle(fontSize: 12, color: kNavyBlue,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(
                            () => _currentFilter = InventoryFilter.available),
                        child: const Icon(Icons.close, size: 14, color: kNavyBlue),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

          // LIST
          Expanded(
            child: RefreshIndicator(
              color: kNavyBlue,
              strokeWidth: 2.5,
              displacement: 20,
              onRefresh: _onRefresh,
              child: filteredItems.isEmpty
                  ? ListView(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 60,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(_searchQuery.isNotEmpty
                                  ? 'Hakuna bidhaa inayolingana'
                                  : 'Hakuna bidhaa bado',
                                  style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isService = item.unit == 'SERVICE';

                        Color statusColor() {
                          if (isService) return const Color(0xFF6366F1);
                          if (item.stock == 0) return const Color(0xFFEF4444);
                          if (item.stock <= 5) return const Color(0xFFF97316);
                          return const Color(0xFF22C55E);
                        }

                        String statusText() {
                          if (isService) return 'HUDUMA';
                          if (item.stock == 0) return 'IMEISHA';
                          if (item.stock <= 5) return 'KARIBIA';
                          return 'IPO';
                        }

                        return GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(product: item))),
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
                                  height: 52, width: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: statusColor().withValues(alpha: 0.1),
                                    image: item.imagePath != null
                                        ? DecorationImage(
                                            image: FileImage(File(item.imagePath!)),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: item.imagePath == null
                                      ? Icon(isService ? Icons.handyman
                                          : Icons.inventory_2,
                                          color: statusColor(), size: 22)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14, color: kNavyBlue)),
                                      const SizedBox(height: 3),
                                      Text(isService
                                          ? 'Huduma • ${item.category}'
                                          : '${item.stock} ${item.unit} • ${item.category}',
                                          style: TextStyle(fontSize: 12,
                                              color: Colors.grey.shade500)),
                                      // Bei ya kununua — inaficha kwa muuzaji asiye na ruhusa
                                      if (isAdmin || perms.canViewBuyingPrice) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kununua: ${_formatAmount(item.buyingPrice)} TZS',
                                          style: TextStyle(fontSize: 10,
                                              color: Colors.grey.shade400),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: statusColor().withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8)),
                                      child: Text(statusText(),
                                          style: TextStyle(fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor())),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('${_formatAmount(item.sellingPrice)} TZS',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13, color: kNavyBlue)),
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

      // FAB — inaonyeshwa tu kama ana ruhusa ya kuongeza bidhaa
      floatingActionButton: (isAdmin || perms.canAddProduct)
          ? FloatingActionButton.extended(
              backgroundColor: kNavyBlue,
              foregroundColor: Colors.white,
              onPressed: () => _showAddOptions(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Bidhaa Mpya',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ===== HELPERS =====

  Widget _typeChip({required String label, required bool selected,
      required VoidCallback onTap, IconData? icon, Color color = Colors.grey}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade200),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : Colors.black87)),
        ]),
      ),
    );
  }

  void _showKundiSheet(BusinessState business) {
    final makundi = business.categories.isEmpty ? ['General'] : business.categories;
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
          const Text('Chagua Kundi', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: kNavyBlue)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(width: 36, height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.select_all,
                  color: Color(0xFF6366F1), size: 18)),
            title: const Text('Makundi Yote'),
            trailing: _selectedKundi == null
                ? const Icon(Icons.check, color: kNavyBlue) : null,
            onTap: () { setState(() => _selectedKundi = null); Navigator.pop(context); },
          ),
          const Divider(),
          ...makundi.map((kundi) {
            final selected = _selectedKundi == kundi;
            final count = business.inventory.where((p) => p.category == kundi).length;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.folder_outlined,
                    color: Color(0xFF6366F1), size: 18)),
              title: Text(kundi, style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? kNavyBlue : Colors.black87)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 26, height: 26,
                  decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      shape: BoxShape.circle),
                  child: Center(child: Text(count.toString(),
                      style: const TextStyle(fontSize: 11,
                          fontWeight: FontWeight.bold, color: Color(0xFF6366F1))))),
                if (selected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, color: kNavyBlue),
                ],
              ]),
              onTap: () {
                setState(() { _selectedKundi = selected ? null : kundi; _typeFilter = TypeFilter.all; });
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final business = context.read<BusinessState>();
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
          const Text('Chuja Hali ya Stock', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: kNavyBlue)),
          const SizedBox(height: 16),
          _filterOption(context, label: 'Zilizopo',
              icon: Icons.check_circle_outline, color: const Color(0xFF22C55E),
              filter: InventoryFilter.available,
              count: business.inventory.where((p) => p.unit == 'SERVICE' || p.stock > 0).length),
          _filterOption(context, label: 'Karibia Kuisha (≤5)',
              icon: Icons.warning_amber_rounded, color: const Color(0xFFF97316),
              filter: InventoryFilter.lowStock,
              count: business.inventory.where((p) => p.unit != 'SERVICE' && p.stock > 0 && p.stock <= 5).length),
          _filterOption(context, label: 'Zilizoisha',
              icon: Icons.remove_circle_outline, color: const Color(0xFFEF4444),
              filter: InventoryFilter.outOfStock,
              count: business.inventory.where((p) => p.unit != 'SERVICE' && p.stock == 0).length),
          _filterOption(context, label: 'Karibia Kuharibika (≤5 siku)',
              icon: Icons.event_busy, color: const Color(0xFF6366F1),
              filter: InventoryFilter.expiringSoon,
              count: business.inventory.where((p) {
                if (p.expiryDate == null) return false;
                final days = p.expiryDate!.difference(DateTime.now()).inDays;
                return days >= 0 && days <= 5;
              }).length),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _filterOption(BuildContext context, {required String label,
      required IconData icon, required Color color,
      required InventoryFilter filter, required int count}) {
    final selected = _currentFilter == filter;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18)),
      title: Text(label, style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? kNavyBlue : Colors.black87)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 26, height: 26,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: Center(child: Text(count.toString(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                  color: color)))),
        if (selected) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check, color: kNavyBlue),
        ],
      ]),
      onTap: () { setState(() => _currentFilter = filter); Navigator.pop(context); },
    );
  }

  void _showAddOptions(BuildContext context) {
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
          const Text('Unataka kuongeza nini?', style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: kNavyBlue)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () { Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())); },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: kNavyBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kNavyBlue.withValues(alpha: 0.2))),
              child: const Row(children: [
                Icon(Icons.inventory_2_outlined, color: kNavyBlue),
                SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bidhaa', style: TextStyle(fontWeight: FontWeight.bold,
                      color: kNavyBlue, fontSize: 15)),
                  Text('Ina stock inayohesabika',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
                Spacer(),
                Icon(Icons.chevron_right, color: kNavyBlue),
              ]),
            ),
          ),
          GestureDetector(
            onTap: () { Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddServicePage())); },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kOrange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kOrange.withValues(alpha: 0.3))),
              child: const Row(children: [
                Icon(Icons.handyman_outlined, color: kOrange),
                SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Huduma', style: TextStyle(fontWeight: FontWeight.bold,
                      color: kOrange, fontSize: 15)),
                  Text('Haina stock — inatolewa bila kikomo',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
                Spacer(),
                Icon(Icons.chevron_right, color: kOrange),
              ]),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  String _filterLabel(InventoryFilter filter) {
    switch (filter) {
      case InventoryFilter.available: return 'Zilizopo';
      case InventoryFilter.lowStock: return 'Karibia Kuisha';
      case InventoryFilter.outOfStock: return 'Zilizoisha';
      case InventoryFilter.expiringSoon: return 'Karibia Kuharibika';
    }
  }
}

// ===== LOCKED PAGE =====
class _LockedPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _LockedPage({
    required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: Text(title, style: const TextStyle(
            color: kNavyBlue, fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.lock_outline,
                  color: Colors.grey.shade400, size: 36)),
            const SizedBox(height: 20),
            Text(message, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14,
                    height: 1.5)),
          ],
        ),
      ),
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
              fontSize: 13, color: color)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}