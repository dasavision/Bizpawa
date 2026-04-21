import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const _kNavy = Color(0xFF1B2E6B);

class SellersPage extends StatelessWidget {
  const SellersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final sellers = auth.sellers;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wauzaji',
            style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold)),
      ),
      body: sellers.isEmpty
          ? _emptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sellers.length,
              itemBuilder: (_, i) {
                final s = sellers[i];
                return GestureDetector(
                  onTap: () => _showSellerOptions(context, s, auth),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
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
                            color: _kNavy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              s.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _kNavy,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _kNavy,
                                  )),
                              Text('@${s.username}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                              Text(s.phone,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade400)),
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
                                color: _kNavy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.role == UserRole.admin
                                    ? 'Admin'
                                    : 'Muuzaji',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: _kNavy,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Icon(Icons.chevron_right,
                                color: Colors.grey, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_seller',
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined, size: 20),
        label: const Text('Ongeza Muuzaji',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => _showAddSheet(context),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Hakuna wauzaji bado',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: _kNavy)),
            const SizedBox(height: 8),
            Text('Ongeza wauzaji wa timu yako',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy, foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: const Text('Ongeza Muuzaji'),
              onPressed: () => _showAddSheet(context),
            ),
          ],
        ),
      );

  // ===== SELLER OPTIONS =====
  void _showSellerOptions(
      BuildContext context, AppUser seller, AuthState auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _kNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      seller.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _kNavy),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seller.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _kNavy)),
                      Text('@${seller.username}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security_outlined,
                    color: _kNavy, size: 20),
              ),
              title: const Text('Badilisha Ruhusa',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: _kNavy)),
              subtitle:
                  const Text('Weka vipengele anavyoweza kufikia'),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PermissionsPage(seller: seller),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_reset_outlined,
                    color: Colors.orange, size: 20),
              ),
              title: const Text('Weka PIN Mpya',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange)),
              subtitle: const Text('Badilisha PIN ya muuzaji huyu'),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showResetPinSheet(context, seller, auth);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
              title: const Text('Futa Muuzaji',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.red)),
              subtitle: const Text('Muuzaji huyu ataondolewa kabisa'),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, seller, auth);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ===== RESET PIN =====
  void _showResetPinSheet(
      BuildContext context, AppUser seller, AuthState auth) {
    final pinCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
            const Text('Weka PIN Mpya',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kNavy)),
            const SizedBox(height: 6),
            Text('PIN mpya kwa ${seller.name}',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Nambari 4 za PIN',
                prefixIcon:
                    const Icon(Icons.lock_outline, color: _kNavy),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kNavy),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  if (pinCtrl.text.length != 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('PIN lazima iwe nambari 4'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  auth.forceChangePinForSeller(seller.id, pinCtrl.text);
                  Navigator.pop(context);
                  NotificationService.show(
                    context: context,
                    message: 'PIN ya ${seller.name} imebadilishwa',
                    type: NotificationType.success,
                  );
                },
                child: const Text('Hifadhi PIN',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ===== ADD SELLER =====
  void _showAddSheet(BuildContext context) {
    final auth = context.read<AuthState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    String? usernameError;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
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
                const Text('Muuzaji Mpya',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kNavy)),
                const SizedBox(height: 20),

                // Jina
                _fieldLabel('Jina Kamili *'),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _fieldDec('Mf. Juma Hassan'),
                ),
                const SizedBox(height: 14),

                // Simu
                _fieldLabel('Namba ya Simu *'),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration:
                      _fieldDec('0712 345 678').copyWith(prefixText: '+255 '),
                ),
                const SizedBox(height: 14),

                // Username
                _fieldLabel('Username (ya kipekee) *'),
                const SizedBox(height: 6),
                TextField(
                  controller: usernameCtrl,
                  onChanged: (v) {
                    final available =
                        auth.isUsernameAvailable(v.trim());
                    setModal(() {
                      usernameError = v.trim().isEmpty
                          ? null
                          : available
                              ? null
                              : 'Username hii tayari inatumika';
                    });
                  },
                  decoration: _fieldDec('Mf. juma_hassan').copyWith(
                    prefixIcon:
                        const Icon(Icons.alternate_email, color: _kNavy),
                    errorText: usernameError,
                    suffixIcon: usernameCtrl.text.isNotEmpty &&
                            usernameError == null
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF22C55E))
                        : null,
                  ),
                ),
                const SizedBox(height: 14),

                // PIN ya muda
                _fieldLabel('PIN ya Muda (nambari 4) *'),
                const SizedBox(height: 6),
                TextField(
                  controller: pinCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: _fieldDec('Mf. 1234').copyWith(
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: _kNavy),
                    helperText:
                        'Muuzaji atabadilisha PIN mara ya kwanza',
                    helperStyle: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
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
                      if (nameCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim().isEmpty ||
                          usernameCtrl.text.trim().isEmpty ||
                          pinCtrl.text.length != 4) {
                        ScaffoldMessenger.of(ctx)
                            .showSnackBar(const SnackBar(
                          content: Text('Jaza sehemu zote'),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }

                      if (usernameError != null) return;

                      auth.addSeller(AppUser(
                        id: auth.generateSellerId(),
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        username: usernameCtrl.text.trim().toLowerCase(),
                        pin: pinCtrl.text,
                        role: UserRole.seller,
                        mustChangePinOnFirstLogin: true,
                        createdAt: DateTime.now(),
                      ));

                      Navigator.pop(ctx);
                      NotificationService.show(
                        context: context,
                        message:
                            '${nameCtrl.text.trim()} amesajiliwa! PIN: ${pinCtrl.text}',
                        type: NotificationType.success,
                      );
                    },
                    child: const Text('Hifadhi Muuzaji',
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
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppUser seller, AuthState auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Futa Muuzaji?',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
        content: Text('Futa ${seller.name} kutoka timu?'),
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
              auth.deleteSeller(seller.id);
              Navigator.pop(context);
              NotificationService.show(
                context: context,
                message: '${seller.name} amefutwa',
                type: NotificationType.error,
              );
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: _kNavy),
      );

  InputDecoration _fieldDec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kNavy, width: 2),
        ),
      );
}

// ===== PERMISSIONS PAGE =====
class PermissionsPage extends StatefulWidget {
  final AppUser seller;
  const PermissionsPage({super.key, required this.seller});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  late SellerPermissions _perms;
  final Map<String, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _perms = widget.seller.permissions;
  }

  void _toggle(String key, bool value) {
    setState(() {
      switch (key) {
        // MAUZO
        case 'canRecordSales': _perms = _perms.copyWith(canRecordSales: value); break;
        case 'canDeleteOwnSales': _perms = _perms.copyWith(canDeleteOwnSales: value); break;
        case 'canViewOtherSales': _perms = _perms.copyWith(canViewOtherSales: value); break;
        case 'canDeleteOtherSales': _perms = _perms.copyWith(canDeleteOtherSales: value); break;
        case 'canBackdateSales': _perms = _perms.copyWith(canBackdateSales: value); break;
        case 'canDeleteBackdatedSales': _perms = _perms.copyWith(canDeleteBackdatedSales: value); break;
        case 'canRefund': _perms = _perms.copyWith(canRefund: value); break;
        // BIDHAA
        case 'canViewProducts': _perms = _perms.copyWith(canViewProducts: value); break;
        case 'canAddProduct': _perms = _perms.copyWith(canAddProduct: value); break;
        case 'canAddStock': _perms = _perms.copyWith(canAddStock: value); break;
        case 'canViewBuyingPrice': _perms = _perms.copyWith(canViewBuyingPrice: value); break;
        case 'canDeleteProduct': _perms = _perms.copyWith(canDeleteProduct: value); break;
        case 'canEditProductPrice': _perms = _perms.copyWith(canEditProductPrice: value); break;
        case 'canEditProductInfo': _perms = _perms.copyWith(canEditProductInfo: value); break;
        case 'canViewProductHistory': _perms = _perms.copyWith(canViewProductHistory: value); break;
        // MADENI
        case 'canPayDebt': _perms = _perms.copyWith(canPayDebt: value); break;
        case 'canViewAllDebts': _perms = _perms.copyWith(canViewAllDebts: value); break;
        // MATUMIZI
        case 'canRecordExpenses': _perms = _perms.copyWith(canRecordExpenses: value); break;
        case 'canDeleteOwnExpenses': _perms = _perms.copyWith(canDeleteOwnExpenses: value); break;
        case 'canViewOtherExpenses': _perms = _perms.copyWith(canViewOtherExpenses: value); break;
        case 'canDeleteOtherExpenses': _perms = _perms.copyWith(canDeleteOtherExpenses: value); break;
        case 'canDeleteBackdatedExpenses': _perms = _perms.copyWith(canDeleteBackdatedExpenses: value); break;
        // RIPOTI
        case 'canViewDailyReport': _perms = _perms.copyWith(canViewDailyReport: value); break;
        case 'canViewSalesReport': _perms = _perms.copyWith(canViewSalesReport: value); break;
        case 'canViewDebtReport': _perms = _perms.copyWith(canViewDebtReport: value); break;
        case 'canViewProductReport': _perms = _perms.copyWith(canViewProductReport: value); break;
        case 'canViewExpenseReport': _perms = _perms.copyWith(canViewExpenseReport: value); break;
        case 'canViewProfitReport': _perms = _perms.copyWith(canViewProfitReport: value); break;
        case 'canViewCustomerReport': _perms = _perms.copyWith(canViewCustomerReport: value); break;
        // ANALYTICS
        case 'canViewSalesAnalytics': _perms = _perms.copyWith(canViewSalesAnalytics: value); break;
        case 'canViewProfitAnalytics': _perms = _perms.copyWith(canViewProfitAnalytics: value); break;
        case 'canViewProductAnalytics': _perms = _perms.copyWith(canViewProductAnalytics: value); break;
        case 'canViewExpenseAnalytics': _perms = _perms.copyWith(canViewExpenseAnalytics: value); break;
        case 'canViewCustomerAnalytics': _perms = _perms.copyWith(canViewCustomerAnalytics: value); break;
      }
    });
  }

  bool _sectionValue(String section) {
    switch (section) {
      case 'mauzo': return _perms.canRecordSales && _perms.canDeleteOwnSales && _perms.canViewOtherSales && _perms.canDeleteOtherSales && _perms.canBackdateSales && _perms.canDeleteBackdatedSales && _perms.canRefund;
      case 'bidhaa': return _perms.canViewProducts && _perms.canAddProduct && _perms.canAddStock && _perms.canViewBuyingPrice && _perms.canDeleteProduct && _perms.canEditProductPrice && _perms.canEditProductInfo && _perms.canViewProductHistory;
      case 'madeni': return _perms.canPayDebt && _perms.canViewAllDebts;
      case 'matumizi': return _perms.canRecordExpenses && _perms.canDeleteOwnExpenses && _perms.canViewOtherExpenses && _perms.canDeleteOtherExpenses && _perms.canDeleteBackdatedExpenses;
      case 'ripoti': return _perms.canViewDailyReport && _perms.canViewSalesReport && _perms.canViewDebtReport && _perms.canViewProductReport && _perms.canViewExpenseReport && _perms.canViewProfitReport && _perms.canViewCustomerReport;
      case 'analytics': return _perms.canViewSalesAnalytics && _perms.canViewProfitAnalytics && _perms.canViewProductAnalytics && _perms.canViewExpenseAnalytics && _perms.canViewCustomerAnalytics;
      default: return false;
    }
  }

  void _toggleSection(String section, bool value) {
    setState(() {
      switch (section) {
        case 'mauzo':
          _perms = _perms.copyWith(canRecordSales: value, canDeleteOwnSales: value, canViewOtherSales: value, canDeleteOtherSales: value, canBackdateSales: value, canDeleteBackdatedSales: value, canRefund: value);
          break;
        case 'bidhaa':
          _perms = _perms.copyWith(canViewProducts: value, canAddProduct: value, canAddStock: value, canViewBuyingPrice: value, canDeleteProduct: value, canEditProductPrice: value, canEditProductInfo: value, canViewProductHistory: value);
          break;
        case 'madeni':
          _perms = _perms.copyWith(canPayDebt: value, canViewAllDebts: value);
          break;
        case 'matumizi':
          _perms = _perms.copyWith(canRecordExpenses: value, canDeleteOwnExpenses: value, canViewOtherExpenses: value, canDeleteOtherExpenses: value, canDeleteBackdatedExpenses: value);
          break;
        case 'ripoti':
          _perms = _perms.copyWith(canViewDailyReport: value, canViewSalesReport: value, canViewDebtReport: value, canViewProductReport: value, canViewExpenseReport: value, canViewProfitReport: value, canViewCustomerReport: value);
          break;
        case 'analytics':
          _perms = _perms.copyWith(canViewSalesAnalytics: value, canViewProfitAnalytics: value, canViewProductAnalytics: value, canViewExpenseAnalytics: value, canViewCustomerAnalytics: value);
          break;
      }
    });
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ruhusa za Muuzaji',
                style: TextStyle(
                    color: _kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(widget.seller.name,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context
                  .read<AuthState>()
                  .updateSellerPermissions(widget.seller.id, _perms);
              Navigator.pop(context);
              NotificationService.show(
                context: context,
                message: 'Ruhusa zimehifadhiwa',
                type: NotificationType.success,
              );
            },
            child: const Text('Hifadhi',
                style: TextStyle(
                    color: _kNavy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('mauzo', 'Mauzo', Icons.receipt_long_outlined, [
            _permItem('canRecordSales', 'Kurekodi mauzo yake', _perms.canRecordSales),
            _permItem('canDeleteOwnSales', 'Kufuta mauzo yake', _perms.canDeleteOwnSales),
            _permItem('canViewOtherSales', 'Kuona mauzo ya wauzaji wengine', _perms.canViewOtherSales),
            _permItem('canDeleteOtherSales', 'Kufuta mauzo ya wauzaji wengine', _perms.canDeleteOtherSales),
            _permItem('canBackdateSales', 'Kurekodi mauzo ya siku za nyuma', _perms.canBackdateSales),
            _permItem('canDeleteBackdatedSales', 'Kufuta mauzo ya siku za nyuma', _perms.canDeleteBackdatedSales),
            _permItem('canRefund', 'Kufanya refund', _perms.canRefund),
          ]),
          _section('bidhaa', 'Bidhaa', Icons.inventory_2_outlined, [
            _permItem('canViewProducts', 'Kuona bidhaa zote', _perms.canViewProducts),
            _permItem('canAddProduct', 'Kusajili bidhaa mpya', _perms.canAddProduct),
            _permItem('canAddStock', 'Kuongeza stock', _perms.canAddStock),
            _permItem('canViewBuyingPrice', 'Kuona thamani ya kununua na kuuza', _perms.canViewBuyingPrice),
            _permItem('canDeleteProduct', 'Kufuta bidhaa', _perms.canDeleteProduct),
            _permItem('canEditProductPrice', 'Kuedit idadi na bei ya bidhaa', _perms.canEditProductPrice),
            _permItem('canEditProductInfo', 'Kuedit taarifa za bidhaa', _perms.canEditProductInfo),
            _permItem('canViewProductHistory', 'Kuona mlolongo wa bidhaa', _perms.canViewProductHistory),
          ]),
          _section('madeni', 'Madeni', Icons.schedule_outlined, [
            _permItem('canPayDebt', 'Kulipia deni', _perms.canPayDebt),
            _permItem('canViewAllDebts', 'Kuona madeni yote', _perms.canViewAllDebts),
          ]),
          _section('matumizi', 'Matumizi', Icons.money_off_outlined, [
            _permItem('canRecordExpenses', 'Kurekodi matumizi yake', _perms.canRecordExpenses),
            _permItem('canDeleteOwnExpenses', 'Kufuta matumizi yake', _perms.canDeleteOwnExpenses),
            _permItem('canViewOtherExpenses', 'Kuona matumizi ya wauzaji wengine', _perms.canViewOtherExpenses),
            _permItem('canDeleteOtherExpenses', 'Kufuta matumizi ya wauzaji wengine', _perms.canDeleteOtherExpenses),
            _permItem('canDeleteBackdatedExpenses', 'Kufuta matumizi ya siku za nyuma', _perms.canDeleteBackdatedExpenses),
          ]),
          _section('ripoti', 'Ripoti', Icons.bar_chart_outlined, [
            _permItem('canViewDailyReport', 'Kuona ripoti hesabu ya siku', _perms.canViewDailyReport),
            _permItem('canViewSalesReport', 'Kuona ripoti za mauzo', _perms.canViewSalesReport),
            _permItem('canViewDebtReport', 'Kuona ripoti za madeni', _perms.canViewDebtReport),
            _permItem('canViewProductReport', 'Kuona ripoti za bidhaa', _perms.canViewProductReport),
            _permItem('canViewExpenseReport', 'Kuona ripoti za matumizi', _perms.canViewExpenseReport),
            _permItem('canViewProfitReport', 'Kuona ripoti za faida', _perms.canViewProfitReport),
            _permItem('canViewCustomerReport', 'Kuona ripoti za wateja', _perms.canViewCustomerReport),
          ]),
          _section('analytics', 'Analytics', Icons.analytics_outlined, [
            _permItem('canViewSalesAnalytics', 'Kuona analytics mauzo', _perms.canViewSalesAnalytics),
            _permItem('canViewProfitAnalytics', 'Kuona analytics faida', _perms.canViewProfitAnalytics),
            _permItem('canViewProductAnalytics', 'Kuona analytics bidhaa', _perms.canViewProductAnalytics),
            _permItem('canViewExpenseAnalytics', 'Kuona analytics matumizi', _perms.canViewExpenseAnalytics),
            _permItem('canViewCustomerAnalytics', 'Kuona analytics wateja', _perms.canViewCustomerAnalytics),
          ]),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: Colors.white,
        child: SizedBox(
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
              context
                  .read<AuthState>()
                  .updateSellerPermissions(widget.seller.id, _perms);
              Navigator.pop(context);
              NotificationService.show(
                context: context,
                message: 'Ruhusa za ${widget.seller.name} zimehifadhiwa',
                type: NotificationType.success,
              );
            },
            child: const Text('Hifadhi Ruhusa',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _section(String key, String title, IconData icon,
      List<Widget> children) {
    final isExpanded = _expanded[key] ?? false;
    final sectionOn = _sectionValue(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          GestureDetector(
            onTap: () =>
                setState(() => _expanded[key] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: _kNavy, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _kNavy),
                    ),
                  ),
                  // Toggle yote kwa mara moja
                  Switch(
                    value: sectionOn,
                    onChanged: (v) => _toggleSection(key, v),
                    activeColor: _kNavy,
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _permItem(String key, String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700)),
          ),
          Checkbox(
            value: value,
            onChanged: (v) => _toggle(key, v ?? false),
            activeColor: _kNavy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}