import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bizpawa/models/app_user.dart';

export 'package:bizpawa/models/app_user.dart' show
    AppUser, UserRole, SellerPermissions;

class AuthState extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isRegistered = false;
  bool _hasSeenOnboarding = false;
  AppUser? _adminUser;
  final List<AppUser> _sellers = [];

  late final Box _authBox;
  late final Box<AppUser> _sellersBox;

  AppUser? get currentUser => _currentUser;
  bool get isRegistered => _isRegistered;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  AppUser? get adminUser => _adminUser;
  List<AppUser> get sellers => _sellers;
  SellerPermissions get permissions =>
      _currentUser?.permissions ?? const SellerPermissions();

  // ===== INITIALIZE — Load data kutoka Hive =====
  Future<void> init() async {
    _authBox = Hive.box('auth');
    _sellersBox = Hive.box<AppUser>('sellers');

    // Load onboarding flag
    _hasSeenOnboarding = _authBox.get('hasSeenOnboarding', defaultValue: false);

    // Load admin user
    final adminData = _authBox.get('adminUser');
    if (adminData != null) {
      _adminUser = adminData as AppUser;
      _isRegistered = true;
    }

    // Load sellers
    _sellers.clear();
    _sellers.addAll(_sellersBox.values);

    // Load current user aliyekuwa ameingia — Remember Me
    final currentUserId = _authBox.get('currentUserId');
    if (currentUserId != null) {
      if (currentUserId == 'admin_001' && _adminUser != null) {
        _currentUser = _adminUser;
      } else {
        try {
          _currentUser = _sellers.firstWhere((s) => s.id == currentUserId);
        } catch (_) {}
      }
    }
  }

  // ===== SAVE HELPERS =====
  Future<void> _saveAdmin() async {
    await _authBox.put('adminUser', _adminUser);
    await _authBox.put('isRegistered', _isRegistered);
  }

  Future<void> _saveSellers() async {
    await _sellersBox.clear();
    for (final seller in _sellers) {
      await _sellersBox.put(seller.id, seller);
    }
  }

  Future<void> _saveOnboarding() async {
    await _authBox.put('hasSeenOnboarding', _hasSeenOnboarding);
  }

  // ===== ONBOARDING =====
  void completeOnboarding() {
    _hasSeenOnboarding = true;
    _saveOnboarding();
    notifyListeners();
  }

  // ===== REGISTRATION =====
  void registerAdmin({
    required String name,
    required String phone,
    required String pin,
  }) {
    _adminUser = AppUser.withRole(
      id: 'admin_001',
      name: name,
      phone: phone,
      username: 'admin',
      pin: pin,
      role: UserRole.admin,
      permissions: const SellerPermissions(),
      createdAt: DateTime.now(),
    );
    _isRegistered = true;
    _currentUser = _adminUser;
    _authBox.put('currentUserId', _currentUser!.id);
    _saveAdmin();
    notifyListeners();
  }

  // ===== LOGIN — Admin kwa namba ya simu + PIN =====
  bool loginAdmin(String phone, String pin) {
    if (_adminUser == null) return false;
    final normalizedInput = _normalizePhone(phone);
    final normalizedStored = _normalizePhone(_adminUser!.phone);
    if (normalizedInput != normalizedStored) return false;
    if (_adminUser!.pin != pin) return false;
    _currentUser = _adminUser;
    _authBox.put('currentUserId', _currentUser!.id);
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
      _authBox.put('currentUserId', _currentUser!.id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  String _normalizePhone(String phone) {
    String p = phone.replaceAll(' ', '').replaceAll('-', '');
    if (p.startsWith('+255')) p = p.substring(4);
    if (p.startsWith('255')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  // ===== LOGOUT =====
  void logout() async {
    _currentUser = null;
    await _authBox.delete('currentUserId');
    notifyListeners();
  }

  // ===== SELLERS =====
  void addSeller(AppUser seller) {
    _sellers.add(seller);
    _saveSellers();
    notifyListeners();
  }

  void updateSellerPermissions(String sellerId, SellerPermissions permissions) {
    final index = _sellers.indexWhere((s) => s.id == sellerId);
    if (index != -1) {
      _sellers[index] = _sellers[index].copyWith(permissions: permissions);
      _saveSellers();
      notifyListeners();
    }
  }

  void deleteSeller(String sellerId) {
    _sellers.removeWhere((s) => s.id == sellerId);
    _saveSellers();
    notifyListeners();
  }

  // ===== PIN CHANGE =====
  bool changePin({required String oldPin, required String newPin}) {
    if (_currentUser == null) return false;
    if (_currentUser!.pin != oldPin) return false;
    if (_currentUser!.isAdmin) {
      _adminUser = _adminUser!.copyWith(pin: newPin);
      _currentUser = _adminUser;
      _saveAdmin();
    } else {
      final index = _sellers.indexWhere((s) => s.id == _currentUser!.id);
      if (index != -1) {
        _sellers[index] = _sellers[index].copyWith(
            pin: newPin, mustChangePinOnFirstLogin: false);
        _currentUser = _sellers[index];
        _saveSellers();
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
      _saveSellers();
      notifyListeners();
    }
  }

  bool isUsernameAvailable(String username) {
    if (username.toLowerCase() == 'admin') return false;
    return !_sellers
        .any((s) => s.username.toLowerCase() == username.toLowerCase());
  }

  String generateSellerId() =>
      'seller_${DateTime.now().millisecondsSinceEpoch}';
}