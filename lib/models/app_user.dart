import 'package:hive/hive.dart';

part 'app_user.g.dart';

enum UserRole { admin, seller }

@HiveType(typeId: 12)
class SellerPermissions {
  @HiveField(0) final bool canRecordSales;
  @HiveField(1) final bool canDeleteOwnSales;
  @HiveField(2) final bool canViewOtherSales;
  @HiveField(3) final bool canDeleteOtherSales;
  @HiveField(4) final bool canBackdateSales;
  @HiveField(5) final bool canDeleteBackdatedSales;
  @HiveField(6) final bool canRefund;
  @HiveField(7) final bool canViewProducts;
  @HiveField(8) final bool canAddProduct;
  @HiveField(9) final bool canAddStock;
  @HiveField(10) final bool canViewBuyingPrice;
  @HiveField(11) final bool canDeleteProduct;
  @HiveField(12) final bool canEditProductPrice;
  @HiveField(13) final bool canEditProductInfo;
  @HiveField(14) final bool canViewProductHistory;
  @HiveField(15) final bool canPayDebt;
  @HiveField(16) final bool canViewAllDebts;
  @HiveField(17) final bool canRecordExpenses;
  @HiveField(18) final bool canDeleteOwnExpenses;
  @HiveField(19) final bool canViewOtherExpenses;
  @HiveField(20) final bool canDeleteOtherExpenses;
  @HiveField(21) final bool canDeleteBackdatedExpenses;
  @HiveField(22) final bool canViewDailyReport;
  @HiveField(23) final bool canViewSalesReport;
  @HiveField(24) final bool canViewDebtReport;
  @HiveField(25) final bool canViewProductReport;
  @HiveField(26) final bool canViewExpenseReport;
  @HiveField(27) final bool canViewProfitReport;
  @HiveField(28) final bool canViewCustomerReport;
  @HiveField(29) final bool canViewSalesAnalytics;
  @HiveField(30) final bool canViewProfitAnalytics;
  @HiveField(31) final bool canViewProductAnalytics;
  @HiveField(32) final bool canViewExpenseAnalytics;
  @HiveField(33) final bool canViewCustomerAnalytics;

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

@HiveType(typeId: 13)
class AppUser {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String pin;

  @HiveField(5)
  final String roleString;

  @HiveField(6)
  final SellerPermissions permissions;

  @HiveField(7)
  final bool mustChangePinOnFirstLogin;

  @HiveField(8)
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.username,
    required this.pin,
    required this.roleString,
    this.permissions = const SellerPermissions(),
    this.mustChangePinOnFirstLogin = false,
    required this.createdAt,
  });

  factory AppUser.withRole({
    required String id,
    required String name,
    required String phone,
    required String username,
    required String pin,
    required UserRole role,
    SellerPermissions permissions = const SellerPermissions(),
    bool mustChangePinOnFirstLogin = false,
    required DateTime createdAt,
  }) {
    return AppUser(
      id: id,
      name: name,
      phone: phone,
      username: username,
      pin: pin,
      roleString: role == UserRole.admin ? 'admin' : 'seller',
      permissions: permissions,
      mustChangePinOnFirstLogin: mustChangePinOnFirstLogin,
      createdAt: createdAt,
    );
  }

  UserRole get role => roleString == 'admin' ? UserRole.admin : UserRole.seller;
  bool get isAdmin => role == UserRole.admin;

  AppUser copyWith({
    String? pin,
    SellerPermissions? permissions,
    bool? mustChangePinOnFirstLogin,
  }) {
    return AppUser(
      id: id,
      name: name,
      phone: phone,
      username: username,
      pin: pin ?? this.pin,
      roleString: roleString,
      permissions: permissions ?? this.permissions,
      mustChangePinOnFirstLogin:
          mustChangePinOnFirstLogin ?? this.mustChangePinOnFirstLogin,
      createdAt: createdAt,
    );
  }
}