import 'package:flutter/material.dart';

enum UserRole { admin, seller }

class SellerPermissions {
  // MAUZO
  final bool canRecordSales;
  final bool canDeleteOwnSales;
  final bool canViewOtherSales;
  final bool canDeleteOtherSales;
  final bool canBackdateSales;
  final bool canDeleteBackdatedSales;
  final bool canRefund;

  // BIDHAA
  final bool canViewProducts;
  final bool canAddProduct;
  final bool canAddStock;
  final bool canViewBuyingPrice;
  final bool canDeleteProduct;
  final bool canEditProductPrice;
  final bool canEditProductInfo;
  final bool canViewProductHistory;

  // MADENI
  final bool canPayDebt;
  final bool canViewAllDebts;

  // MATUMIZI
  final bool canRecordExpenses;
  final bool canDeleteOwnExpenses;
  final bool canViewOtherExpenses;
  final bool canDeleteOtherExpenses;
  final bool canDeleteBackdatedExpenses;

  // RIPOTI
  final bool canViewDailyReport;
  final bool canViewSalesReport;
  final bool canViewDebtReport;
  final bool canViewProductReport;
  final bool canViewExpenseReport;
  final bool canViewProfitReport;
  final bool canViewCustomerReport;

  // ANALYTICS
  final bool canViewSalesAnalytics;
  final bool canViewProfitAnalytics;
  final bool canViewProductAnalytics;
  final bool canViewExpenseAnalytics;
  final bool canViewCustomerAnalytics;

  const SellerPermissions({
    this.canRecordSales = false,
    this.canDeleteOwnSales = false,
    this.canViewOtherSales = false,
    this.canDeleteOtherSales = false,
    this.canBackdateSales = false,
    this.canDeleteBackdatedSales = false,
    this.canRefund = false,
    this.canViewProducts = false,
    this.canAddProduct = false,
    this.canAddStock = false,
    this.canViewBuyingPrice = false,
    this.canDeleteProduct = false,
    this.canEditProductPrice = false,
    this.canEditProductInfo = false,
    this.canViewProductHistory = false,
    this.canPayDebt = false,
    this.canViewAllDebts = false,
    this.canRecordExpenses = false,
    this.canDeleteOwnExpenses = false,
    this.canViewOtherExpenses = false,
    this.canDeleteOtherExpenses = false,
    this.canDeleteBackdatedExpenses = false,
    this.canViewDailyReport = false,
    this.canViewSalesReport = false,
    this.canViewDebtReport = false,
    this.canViewProductReport = false,
    this.canViewExpenseReport = false,
    this.canViewProfitReport = false,
    this.canViewCustomerReport = false,
    this.canViewSalesAnalytics = false,
    this.canViewProfitAnalytics = false,
    this.canViewProductAnalytics = false,
    this.canViewExpenseAnalytics = false,
    this.canViewCustomerAnalytics = false,
  });

  SellerPermissions copyWith({
    bool? canRecordSales, bool? canDeleteOwnSales, bool? canViewOtherSales,
    bool? canDeleteOtherSales, bool? canBackdateSales, bool? canDeleteBackdatedSales,
    bool? canRefund, bool? canViewProducts, bool? canAddProduct, bool? canAddStock,
    bool? canViewBuyingPrice, bool? canDeleteProduct, bool? canEditProductPrice,
    bool? canEditProductInfo, bool? canViewProductHistory, bool? canPayDebt,
    bool? canViewAllDebts, bool? canRecordExpenses, bool? canDeleteOwnExpenses,
    bool? canViewOtherExpenses, bool? canDeleteOtherExpenses,
    bool? canDeleteBackdatedExpenses, bool? canViewDailyReport,
    bool? canViewSalesReport, bool? canViewDebtReport, bool? canViewProductReport,
    bool? canViewExpenseReport, bool? canViewProfitReport, bool? canViewCustomerReport,
    bool? canViewSalesAnalytics, bool? canViewProfitAnalytics,
    bool? canViewProductAnalytics, bool? canViewExpenseAnalytics,
    bool? canViewCustomerAnalytics,
  }) {
    return SellerPermissions(
      canRecordSales: canRecordSales ?? this.canRecordSales,
      canDeleteOwnSales: canDeleteOwnSales ?? this.canDeleteOwnSales,
      canViewOtherSales: canViewOtherSales ?? this.canViewOtherSales,
      canDeleteOtherSales: canDeleteOtherSales ?? this.canDeleteOtherSales,
      canBackdateSales: canBackdateSales ?? this.canBackdateSales,
      canDeleteBackdatedSales: canDeleteBackdatedSales ?? this.canDeleteBackdatedSales,
      canRefund: canRefund ?? this.canRefund,
      canViewProducts: canViewProducts ?? this.canViewProducts,
      canAddProduct: canAddProduct ?? this.canAddProduct,
      canAddStock: canAddStock ?? this.canAddStock,
      canViewBuyingPrice: canViewBuyingPrice ?? this.canViewBuyingPrice,
      canDeleteProduct: canDeleteProduct ?? this.canDeleteProduct,
      canEditProductPrice: canEditProductPrice ?? this.canEditProductPrice,
      canEditProductInfo: canEditProductInfo ?? this.canEditProductInfo,
      canViewProductHistory: canViewProductHistory ?? this.canViewProductHistory,
      canPayDebt: canPayDebt ?? this.canPayDebt,
      canViewAllDebts: canViewAllDebts ?? this.canViewAllDebts,
      canRecordExpenses: canRecordExpenses ?? this.canRecordExpenses,
      canDeleteOwnExpenses: canDeleteOwnExpenses ?? this.canDeleteOwnExpenses,
      canViewOtherExpenses: canViewOtherExpenses ?? this.canViewOtherExpenses,
      canDeleteOtherExpenses: canDeleteOtherExpenses ?? this.canDeleteOtherExpenses,
      canDeleteBackdatedExpenses: canDeleteBackdatedExpenses ?? this.canDeleteBackdatedExpenses,
      canViewDailyReport: canViewDailyReport ?? this.canViewDailyReport,
      canViewSalesReport: canViewSalesReport ?? this.canViewSalesReport,
      canViewDebtReport: canViewDebtReport ?? this.canViewDebtReport,
      canViewProductReport: canViewProductReport ?? this.canViewProductReport,
      canViewExpenseReport: canViewExpenseReport ?? this.canViewExpenseReport,
      canViewProfitReport: canViewProfitReport ?? this.canViewProfitReport,
      canViewCustomerReport: canViewCustomerReport ?? this.canViewCustomerReport,
      canViewSalesAnalytics: canViewSalesAnalytics ?? this.canViewSalesAnalytics,
      canViewProfitAnalytics: canViewProfitAnalytics ?? this.canViewProfitAnalytics,
      canViewProductAnalytics: canViewProductAnalytics ?? this.canViewProductAnalytics,
      canViewExpenseAnalytics: canViewExpenseAnalytics ?? this.canViewExpenseAnalytics,
      canViewCustomerAnalytics: canViewCustomerAnalytics ?? this.canViewCustomerAnalytics,
    );
  }
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String username;
  final String pin;
  final UserRole role;
  final SellerPermissions permissions;
  final bool mustChangePinOnFirstLogin;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.username,
    required this.pin,
    required this.role,
    this.permissions = const SellerPermissions(),
    this.mustChangePinOnFirstLogin = false,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  AppUser copyWith({
    String? pin,
    SellerPermissions? permissions,
    bool? mustChangePinOnFirstLogin,
  }) {
    return AppUser(
      id: id, name: name, phone: phone, username: username,
      pin: pin ?? this.pin, role: role,
      permissions: permissions ?? this.permissions,
      mustChangePinOnFirstLogin: mustChangePinOnFirstLogin ?? this.mustChangePinOnFirstLogin,
      createdAt: createdAt,
    );
  }
}

class AuthState extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isRegistered = false;
  bool _hasSeenOnboarding = false;
  AppUser? _adminUser;
  final List<AppUser> _sellers = [];

  AppUser? get currentUser => _currentUser;
  bool get isRegistered => _isRegistered;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  AppUser? get adminUser => _adminUser;
  List<AppUser> get sellers => _sellers;
  SellerPermissions get permissions =>
      _currentUser?.permissions ?? const SellerPermissions();

  // ===== ONBOARDING =====
  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  // ===== REGISTRATION =====
  void registerAdmin({
    required String name,
    required String phone,
    required String pin,
  }) {
    _adminUser = AppUser(
      id: 'admin_001',
      name: name,
      phone: phone,
      username: 'admin', // default username
      pin: pin,
      role: UserRole.admin,
      permissions: const SellerPermissions(),
      createdAt: DateTime.now(),
    );
    _isRegistered = true;
    _currentUser = _adminUser;
    notifyListeners();
  }

  // ===== LOGIN — Admin kwa namba ya simu + PIN =====
  bool loginAdmin(String phone, String pin) {
    if (_adminUser == null) return false;
    // Normalize phone — ondoa +255 au 0 mwanzoni
    final normalizedInput = _normalizePhone(phone);
    final normalizedStored = _normalizePhone(_adminUser!.phone);
    if (normalizedInput != normalizedStored) return false;
    if (_adminUser!.pin != pin) return false;
    _currentUser = _adminUser;
    notifyListeners();
    return true;
  }

  // ===== LOGIN — Seller kwa username + PIN =====
  bool loginSeller(String username, String pin) {
    try {
      final seller = _sellers.firstWhere(
        (s) => s.username.toLowerCase() == username.toLowerCase(),
      );
      if (seller.pin != pin) return false;
      _currentUser = seller;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Normalize phone — fanya ziwe sawa bila prefix
  String _normalizePhone(String phone) {
    String p = phone.replaceAll(' ', '').replaceAll('-', '');
    if (p.startsWith('+255')) p = p.substring(4);
    if (p.startsWith('255')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  // ===== LOGOUT =====
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ===== SELLERS =====
  void addSeller(AppUser seller) {
    _sellers.add(seller);
    notifyListeners();
  }

  void updateSellerPermissions(String sellerId, SellerPermissions permissions) {
    final index = _sellers.indexWhere((s) => s.id == sellerId);
    if (index != -1) {
      _sellers[index] = _sellers[index].copyWith(permissions: permissions);
      notifyListeners();
    }
  }

  void deleteSeller(String sellerId) {
    _sellers.removeWhere((s) => s.id == sellerId);
    notifyListeners();
  }

  // ===== PIN CHANGE =====
  bool changePin({required String oldPin, required String newPin}) {
    if (_currentUser == null) return false;
    if (_currentUser!.pin != oldPin) return false;
    if (_currentUser!.isAdmin) {
      _adminUser = _adminUser!.copyWith(pin: newPin);
      _currentUser = _adminUser;
    } else {
      final index = _sellers.indexWhere((s) => s.id == _currentUser!.id);
      if (index != -1) {
        _sellers[index] = _sellers[index].copyWith(
          pin: newPin, mustChangePinOnFirstLogin: false);
        _currentUser = _sellers[index];
      }
    }
    notifyListeners();
    return true;
  }

  void forceChangePinForSeller(String sellerId, String newPin) {
    final index = _sellers.indexWhere((s) => s.id == sellerId);
    if (index != -1) {
      _sellers[index] = _sellers[index].copyWith(
        pin: newPin, mustChangePinOnFirstLogin: false);
      if (_currentUser?.id == sellerId) _currentUser = _sellers[index];
      notifyListeners();
    }
  }

  bool isUsernameAvailable(String username) {
    if (username.toLowerCase() == 'admin') return false;
    return !_sellers.any((s) => s.username.toLowerCase() == username.toLowerCase());
  }

  String generateSellerId() => 'seller_${DateTime.now().millisecondsSinceEpoch}';
}