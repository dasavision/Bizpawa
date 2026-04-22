import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/models/stock_batch.dart';
import 'package:bizpawa/models/sale_entry.dart';
import 'package:bizpawa/models/customer.dart';
import 'package:bizpawa/models/expense.dart';
import 'package:bizpawa/models/supplier.dart';
import 'package:bizpawa/models/app_note.dart';
import 'package:bizpawa/models/sale_order.dart';
import 'package:bizpawa/models/sale_item.dart';
import 'package:bizpawa/models/order_item.dart';

export 'package:bizpawa/models/sale_entry.dart';
export 'package:bizpawa/models/customer.dart';
export 'package:bizpawa/models/expense.dart';
export 'package:bizpawa/models/supplier.dart';
export 'package:bizpawa/models/app_note.dart';

enum SalesFilter { today, week, custom }

class BusinessState extends ChangeNotifier {

  // ===== HIVE BOXES =====
  late final Box _profileBox;
  late final Box<Product> _productsBox;
  late final Box<SaleEntry> _salesBox;
  late final Box<Expense> _expensesBox;
  late final Box<Customer> _customersBox;
  late final Box<Supplier> _suppliersBox;
  late final Box<AppNote> _notesBox;

  /// ================== INITIALIZE — Load data kutoka Hive ==================
  Future<void> init() async {
    _profileBox   = Hive.box('profile');
    _productsBox  = Hive.box<Product>('products');
    _salesBox     = Hive.box<SaleEntry>('sales');
    _expensesBox  = Hive.box<Expense>('expenses');
    _customersBox = Hive.box<Customer>('customers');
    _suppliersBox = Hive.box<Supplier>('suppliers');
    _notesBox     = Hive.box<AppNote>('notes');

    // Load business profile
    businessName    = _profileBox.get('businessName',    defaultValue: 'Jina la Biashara');
    businessPhone   = _profileBox.get('businessPhone',   defaultValue: '---');
    businessAddress = _profileBox.get('businessAddress', defaultValue: '');
    bizType         = _profileBox.get('bizType',         defaultValue: '');

    // Load custom categories
    final savedCategories = _profileBox.get('customCategories');
    if (savedCategories != null) {
      _customCategories.addAll(List<String>.from(savedCategories));
    }

    // Load expense categories
    final savedExpCats = _profileBox.get('expenseCategories');
    if (savedExpCats != null) {
      _expenseCategories
        ..clear()
        ..addAll(List<String>.from(savedExpCats));
    }

    // Load inventory
    inventory.addAll(_productsBox.values);

    // Load sales history — mpangilio wa tarehe (mpya kwanza)
    _salesHistory.addAll(
      _salesBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );

    // Load expenses
    _expenses.addAll(
      _expensesBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
    );

    // Load customers
    _customers.addAll(_customersBox.values);

    // Load suppliers
    _suppliers.addAll(_suppliersBox.values);

    // Load notes
    _notes.addAll(_notesBox.values);
  }

  /// ================== BUSINESS PROFILE ==================
  String businessName    = 'Jina la Biashara';
  String businessPhone   = '---';
  String businessAddress = '';
  String bizType         = '';

  void updateBusinessProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    businessName    = name;
    businessPhone   = phone;
    businessAddress = address;
    _profileBox.put('businessName',    businessName);
    _profileBox.put('businessPhone',   businessPhone);
    _profileBox.put('businessAddress', businessAddress);
    notifyListeners();
  }

  void updateBizType(String type) {
    bizType = type;
    _profileBox.put('bizType', bizType);
    notifyListeners();
  }

  /// ================== CUSTOMERS ==================
  final List<Customer> _customers = [];
  List<Customer> get customers => _customers;

  void addCustomer(Customer customer) {
    _customers.add(customer);
    _customersBox.put(customer.id, customer);
    notifyListeners();
  }

  void updateCustomer(Customer updated) {
    final index = _customers.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _customers[index] = updated;
      _customersBox.put(updated.id, updated);
      notifyListeners();
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    _customersBox.delete(id);
    notifyListeners();
  }

  Customer? findCustomerByPhone(String phone) {
    try {
      return _customers.firstWhere((c) => c.phone == phone);
    } catch (_) {
      return null;
    }
  }

  /// ================== SALES (Order-based) ==================
  final List<SaleOrder> _orders = [];
  List<SaleOrder> get orders => _orders.reversed.toList();

  SaleOrder? _draftOrder;
  SaleOrder? get draftOrder => _draftOrder;

  void startNewSale({String seller = 'Admin'}) {
    _draftOrder = SaleOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      sellerName: seller,
    );
    notifyListeners();
  }

  void addItemToSale(SaleItem item) {
    if (_draftOrder == null) return;
    final index = _draftOrder!.items.indexWhere(
      (i) => i.product.id == item.product.id,
    );
    if (index != -1) {
      _draftOrder!.items[index].quantity += item.quantity;
    } else {
      _draftOrder!.items.add(item);
    }
    notifyListeners();
  }

  void updateItemQuantity(String productId, int qty) {
    if (_draftOrder == null) return;
    final index = _draftOrder!.items.indexWhere((i) => i.product.id == productId);
    if (index == -1) return;
    if (qty <= 0) {
      _draftOrder!.items.removeAt(index);
    } else {
      _draftOrder!.items[index].quantity = qty;
    }
    notifyListeners();
  }

  void setDiscount(int amount) {
    if (_draftOrder == null) return;
    _draftOrder!.discount = amount;
    notifyListeners();
  }

  void setSaleNotes(String notes) {
    if (_draftOrder == null) return;
    _draftOrder!.notes = notes;
    notifyListeners();
  }

  void setCustomer(String name) {
    if (_draftOrder == null) return;
    _draftOrder!.customerName = name;
    notifyListeners();
  }

  bool completeSale({
    required PaymentStatus status,
    PaymentMethod? method,
  }) {
    if (_draftOrder == null) return false;
    if (status == PaymentStatus.unpaid &&
        (_draftOrder!.customerName == null ||
            _draftOrder!.customerName!.isEmpty)) {
      return false;
    }
    _draftOrder!
      ..status = status
      ..paymentMethod = method;
    for (final item in _draftOrder!.items) {
      if (item.product.unit != 'SERVICE') {
        item.product.stock -= item.quantity;
      }
    }
    _orders.add(_draftOrder!);
    _draftOrder = null;
    notifyListeners();
    return true;
  }

  /// ================== INVENTORY ==================
  final List<Product> inventory = [];

  void addProduct(Product product) {
    if (product.unit != 'SERVICE' && product.stock > 0) {
      final firstBatch = StockBatch(
        batchNumber: 1,
        quantity: product.stock,
        buyingPrice: product.buyingPrice,
        sellingPrice: product.sellingPrice,
        date: DateTime.now(),
        remainingStock: product.stock,
      );
      product.batches.add(firstBatch);
    }
    inventory.add(product);
    _productsBox.put(product.id, product);
    notifyListeners();
  }

  void addService(Product service) {
    inventory.add(service);
    _productsBox.put(service.id, service);
    notifyListeners();
  }

  void updateProduct(Product updated) {
    final index = inventory.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      inventory[index] = updated;
      _productsBox.put(updated.id, updated);
      notifyListeners();
    }
  }

  void deleteProductById(String productId) {
    inventory.removeWhere((p) => p.id == productId);
    _productsBox.delete(productId);
    notifyListeners();
  }

  void addStock(Product product, int quantity) {
    if (product.unit == 'SERVICE') return;
    final index = inventory.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      inventory[index].stock += quantity;
      _productsBox.put(inventory[index].id, inventory[index]);
      notifyListeners();
    }
  }

  void addStockBatch(Product product, StockBatch batch) {
    final index = inventory.indexWhere((p) => p.id == product.id);
    if (index == -1) return;
    inventory[index].batches.add(batch);
    inventory[index].stock += batch.quantity;
    _productsBox.put(inventory[index].id, inventory[index]);
    notifyListeners();
  }

  /// ================== CATEGORIES ==================
  final List<String> _customCategories = [];

  List<String> get categories {
    final set = <String>{};
    for (final p in inventory) {
      if (p.category.trim().isNotEmpty) set.add(p.category.trim());
    }
    for (final c in _customCategories) {
      if (c.trim().isNotEmpty) set.add(c.trim());
    }
    return set.isEmpty ? [] : (set.toList()..sort());
  }

  void addCustomCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    if (!_customCategories.contains(trimmed)) {
      _customCategories.add(trimmed);
      _profileBox.put('customCategories', _customCategories);
      notifyListeners();
    }
  }

  /// ================== ORDER NUMBER ==================
  String generateOrderNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final part = List.generate(5, (_) => chars[random.nextInt(chars.length)]).join();
    return 'BIZ$part';
  }

  /// ================== SALES HISTORY ==================
  final List<SaleEntry> _salesHistory = [];
  List<SaleEntry> get salesHistory => _salesHistory;

  void recordOrder({
    required List<OrderItem> items,
    required int discount,
    required DateTime date,
    required bool paid,
    String sellerName = 'Admin',
    String? customerName,
    String? customerPhone,
    String? note,
    String? paymentMethod,
  }) {
    final orderNumber = generateOrderNumber();
    int totalAmount = 0;
    int totalCogs = 0;
    final saleItems = <SaleItemEntry>[];
    final productNames = <String>[];

    for (final item in items) {
      if (item.product.unit != 'SERVICE' && item.quantity > item.product.stock) {
        continue;
      }
      if (item.product.unit != 'SERVICE') {
        item.product.stock -= item.quantity;
        _productsBox.put(item.product.id, item.product);
      }

      final itemTotal = item.product.sellingPrice * item.quantity;
      final itemCogs = item.product.unit == 'SERVICE'
          ? 0
          : item.product.buyingPrice * item.quantity;

      totalAmount += itemTotal;
      totalCogs += itemCogs;

      saleItems.add(SaleItemEntry(
        productId: item.product.id,
        productName: item.product.name,
        unit: item.product.unit,
        quantity: item.quantity,
        sellingPrice: item.product.sellingPrice,
        buyingPrice: item.product.buyingPrice,
      ));
      productNames.add(item.product.name);
    }

    final finalAmount = totalAmount - discount;

    final entry = SaleEntry(
      orderNumber: orderNumber,
      productName: productNames.length == 1
          ? productNames.first
          : '${productNames.first} +${productNames.length - 1} zaidi',
      amount: finalAmount,
      date: date,
      paid: paid,
      paidAmount: paid ? finalAmount : 0,
      customerName: customerName,
      customerPhone: customerPhone,
      sellerName: sellerName,
      discount: discount,
      note: note,
      paymentMethod: paymentMethod,
      items: saleItems,
      totalCogs: totalCogs,
    );

    _salesHistory.insert(0, entry);
    _salesBox.put(orderNumber, entry);
    notifyListeners();
  }

  void recordSale({
    required Product product,
    required int quantity,
    required int discount,
    required DateTime date,
    required bool paid,
    String sellerName = 'Admin',
  }) {
    if (product.unit != 'SERVICE' && quantity > product.stock) return;
    if (product.unit != 'SERVICE') {
      product.stock -= quantity;
      _productsBox.put(product.id, product);
    }

    final amount = (product.sellingPrice * quantity) - discount;
    final cogs = product.unit == 'SERVICE' ? 0 : product.buyingPrice * quantity;
    final orderNumber = generateOrderNumber();

    final entry = SaleEntry(
      orderNumber: orderNumber,
      productName: product.name,
      amount: amount,
      date: date,
      paid: paid,
      paidAmount: paid ? amount : 0,
      totalCogs: cogs,
      sellerName: sellerName,
      items: [
        SaleItemEntry(
          productId: product.id,
          productName: product.name,
          unit: product.unit,
          quantity: quantity,
          sellingPrice: product.sellingPrice,
          buyingPrice: product.buyingPrice,
        ),
      ],
    );

    _salesHistory.insert(0, entry);
    _salesBox.put(orderNumber, entry);
    notifyListeners();
  }

  /// ================== PARTIAL PAYMENT ==================
  void makePartialPayment({
    required String orderNumber,
    required int amount,
    required String paymentMethod,
    required DateTime date,
  }) {
    final index = _salesHistory.indexWhere((s) => s.orderNumber == orderNumber);
    if (index == -1) return;

    final sale = _salesHistory[index];
    final newPaidAmount = sale.paidAmount + amount;
    final isFullyPaid = newPaidAmount >= sale.amount;

    final payment = DebtPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      paymentMethod: paymentMethod,
      date: date,
    );

    final updated = SaleEntry(
      orderNumber: sale.orderNumber,
      productName: sale.productName,
      amount: sale.amount,
      date: sale.date,
      paid: isFullyPaid,
      paidAmount: newPaidAmount,
      customerName: sale.customerName,
      customerPhone: sale.customerPhone,
      sellerName: sale.sellerName,
      discount: sale.discount,
      note: sale.note,
      paymentMethod: isFullyPaid ? paymentMethod : sale.paymentMethod,
      items: sale.items,
      payments: [...sale.payments, payment],
      isRefunded: sale.isRefunded,
      refundAmount: sale.refundAmount,
      totalCogs: sale.totalCogs,
    );

    _salesHistory[index] = updated;
    _salesBox.put(orderNumber, updated);
    notifyListeners();
  }

  void cancelOrder(String orderNumber) {
    final saleIndex = _salesHistory.indexWhere((s) => s.orderNumber == orderNumber);
    if (saleIndex == -1) return;

    final sale = _salesHistory[saleIndex];
    for (final item in sale.items) {
      if (item.unit != 'SERVICE') {
        final productIndex = inventory.indexWhere((p) => p.id == item.productId);
        if (productIndex != -1) {
          inventory[productIndex].stock += item.quantity;
          _productsBox.put(inventory[productIndex].id, inventory[productIndex]);
        }
      }
    }
    _salesHistory.removeAt(saleIndex);
    _salesBox.delete(orderNumber);
    notifyListeners();
  }

  /// ================== REFUNDS ==================
  final List<RefundEntry> _refunds = [];
  List<RefundEntry> get refunds => _refunds;

  bool processRefund({
    required String orderNumber,
    required List<RefundItem> items,
    required String reason,
  }) {
    final saleIndex = _salesHistory.indexWhere((s) => s.orderNumber == orderNumber);
    if (saleIndex == -1) return false;

    final sale = _salesHistory[saleIndex];
    int refundAmount = 0;
    int refundCogs = 0;

    for (final refundItem in items) {
      if (refundItem.unit != 'SERVICE') {
        final productIndex = inventory.indexWhere((p) => p.id == refundItem.productId);
        if (productIndex != -1) {
          inventory[productIndex].stock += refundItem.quantity;
          _productsBox.put(inventory[productIndex].id, inventory[productIndex]);
        }
        refundCogs += refundItem.buyingPrice * refundItem.quantity;
      }
      refundAmount += refundItem.subtotal;
    }

    final totalRefunded = sale.refundAmount + refundAmount;
    final isFullRefund = totalRefunded >= sale.amount;
    final newPaidAmount = (sale.paidAmount - refundAmount).clamp(0, sale.amount);
    final newCogs = (sale.totalCogs - refundCogs).clamp(0, sale.totalCogs);

    final updated = SaleEntry(
      orderNumber: sale.orderNumber,
      productName: sale.productName,
      amount: sale.amount,
      date: sale.date,
      paid: isFullRefund ? false : sale.paid,
      paidAmount: newPaidAmount,
      customerName: sale.customerName,
      customerPhone: sale.customerPhone,
      sellerName: sale.sellerName,
      discount: sale.discount,
      note: sale.note,
      paymentMethod: sale.paymentMethod,
      items: sale.items,
      payments: sale.payments,
      isRefunded: isFullRefund,
      refundAmount: totalRefunded,
      totalCogs: newCogs,
    );

    _salesHistory[saleIndex] = updated;
    _salesBox.put(orderNumber, updated);

    _refunds.insert(
      0,
      RefundEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalOrderNumber: orderNumber,
        items: items,
        refundAmount: refundAmount,
        date: DateTime.now(),
        reason: reason,
      ),
    );

    notifyListeners();
    return true;
  }

  /// ================== EXPENSES ==================
  final List<Expense> _expenses = [];
  List<Expense> get expensesList => _expenses;

  final List<String> _expenseCategories = [
    'Chakula', 'Umeme', 'Bando', 'Usafiri',
    'Usafi', 'Kodi ya Pango', 'Mishahara', 'Matengenezo',
  ];

  List<String> get expenseCategories => _expenseCategories;

  void addExpenseCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return;
    if (!_expenseCategories.contains(trimmed)) {
      _expenseCategories.add(trimmed);
      _profileBox.put('expenseCategories', _expenseCategories);
      notifyListeners();
    }
  }

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    _expensesBox.put(expense.id, expense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _expenses.removeAt(index);
    _expensesBox.delete(id);
    notifyListeners();
  }

  int expensesForDay(DateTime day) {
    return _expenses
        .where((e) => _isSameDay(e.date, day))
        .fold<int>(0, (sum, e) => sum + e.amount);
  }

  int netProfitForDay(DateTime day) {
    final salesForDay = _salesHistory.where((s) => _isSameDay(s.date, day));
    final paidRevenue = salesForDay.fold<int>(0, (sum, s) => sum + s.paidAmount);
    final cogsForDay = salesForDay.fold<int>(0, (sum, s) {
      if (s.amount == 0) return sum;
      final paidRatio = s.paidAmount / s.amount;
      return sum + (s.totalCogs * paidRatio).round();
    });
    final expForDay = expensesForDay(day);
    return paidRevenue - cogsForDay - expForDay;
  }

  int get weeklyExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => now.difference(e.date).inDays <= 7)
        .fold<int>(0, (sum, e) => sum + e.amount);
  }

  int get monthlyExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<int>(0, (sum, e) => sum + e.amount);
  }

  int get todayExpenses => expensesForDay(DateTime.now());
  int get todayNetProfit => netProfitForDay(DateTime.now());
  int get todaySales {
    return _salesHistory
        .where((s) => _isSameDay(s.date, DateTime.now()))
        .fold<int>(0, (sum, s) => sum + s.paidAmount);
  }

  Map<String, int> get expensesByCategory {
    final map = <String, int>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  /// ================== DASHBOARD LOGIC ==================
  double get todaySalesChangePercent {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    int todayTotal = 0;
    int yesterdayTotal = 0;
    for (final sale in _salesHistory) {
      if (_isSameDay(sale.date, today)) {
        todayTotal += sale.paidAmount;
      } else if (_isSameDay(sale.date, yesterday)) {
        yesterdayTotal += sale.paidAmount;
      }
    }
    if (yesterdayTotal == 0) return todayTotal > 0 ? 100 : 0;
    return ((todayTotal - yesterdayTotal) / yesterdayTotal) * 100;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// ================== STOCK INSIGHTS ==================
  int get lowStockCount =>
      inventory.where((p) => p.unit != 'SERVICE' && p.stock <= 5).length;

  int get expiringSoonCount => inventory.where((p) {
        if (p.expiryDate == null) return false;
        final days = p.expiryDate!.difference(DateTime.now()).inDays;
        return days >= 0 && days <= 5;
      }).length;

  int get fastMovingCount => _salesHistory
      .where((s) => DateTime.now().difference(s.date).inDays <= 7)
      .length;

  /// ================== INVENTORY SUMMARY ==================
  int get totalItemsCount => inventory.length;

  int get totalBuyingStockValue {
    int total = 0;
    for (final p in inventory) {
      total += p.unit == 'SERVICE' ? p.buyingPrice : p.buyingPrice * p.stock;
    }
    return total;
  }

  int get totalSellingStockValue {
    int total = 0;
    for (final p in inventory) {
      total += p.unit == 'SERVICE' ? p.sellingPrice : p.sellingPrice * p.stock;
    }
    return total;
  }

  int get totalStockValue => totalSellingStockValue;

  /// ================== SELLERS (legacy) ==================
  final List<Seller> _sellers = [];
  List<Seller> get sellers => _sellers;

  void addSeller(Seller seller) {
    _sellers.add(seller);
    notifyListeners();
  }

  void deleteSeller(String id) {
    _sellers.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// ================== SUPPLIERS ==================
  final List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  void addSupplier(Supplier supplier) {
    _suppliers.add(supplier);
    _suppliersBox.put(supplier.id, supplier);
    notifyListeners();
  }

  void deleteSupplier(String id) {
    _suppliers.removeWhere((s) => s.id == id);
    _suppliersBox.delete(id);
    notifyListeners();
  }

  void paySupplier({
    required String supplierId,
    required int amount,
    required String method,
    required DateTime date,
  }) {
    final index = _suppliers.indexWhere((s) => s.id == supplierId);
    if (index == -1) return;

    final supplier = _suppliers[index];
    final payment = SupplierPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      method: method,
      date: date,
    );

    final updated = Supplier(
      id: supplier.id,
      name: supplier.name,
      phone: supplier.phone,
      businessName: supplier.businessName,
      totalDebt: supplier.totalDebt,
      paidAmount: supplier.paidAmount + amount,
      payments: [...supplier.payments, payment],
    );

    _suppliers[index] = updated;
    _suppliersBox.put(supplierId, updated);
    notifyListeners();
  }

  /// ================== NOTES ==================
  final List<AppNote> _notes = [];
  List<AppNote> get notes => _notes.reversed.toList();

  void addNote(AppNote note) {
    _notes.add(note);
    _notesBox.put(note.id, note);
    notifyListeners();
  }

  void updateNote(AppNote updated) {
    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notes[index] = updated;
      _notesBox.put(updated.id, updated);
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _notesBox.delete(id);
    notifyListeners();
  }
}

// ===== Seller class (legacy — itabadilishwa na AppUser) =====
class Seller {
  final String id;
  final String name;
  final String phone;
  final String? role;

  Seller({
    required this.id,
    required this.name,
    required this.phone,
    this.role,
  });
}