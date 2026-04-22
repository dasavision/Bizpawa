import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/models/order_item.dart';
import 'scanner_checkout_page.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);
const _kGreen = Color(0xFF22C55E);

class ScannerSalePage extends StatefulWidget {
  const ScannerSalePage({super.key});

  @override
  State<ScannerSalePage> createState() => _ScannerSalePageState();
}

class _ScannerSalePageState extends State<ScannerSalePage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  // Cart ya bidhaa zilizoscanned
  final List<OrderItem> _cartItems = [];

  // Kuzuia scan mara nyingi kwa wakati mmoja
  bool _isProcessing = false;

  // Bidhaa iliyoscanned mara ya mwisho (kwa animation)
  String? _lastScannedName;

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  int get _totalAmount =>
      _cartItems.fold(0, (sum, item) => sum + item.total);

  int get _totalItems =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    setState(() => _isProcessing = true);

    final business = context.read<BusinessState>();

    // Tafuta bidhaa kwa barcode
    Product? found;
    try {
      found = business.inventory.firstWhere(
        (p) => p.barcodeId == raw || p.id == raw,
      );
    } catch (_) {
      found = null;
    }

    if (found == null) {
      // Bidhaa haikupatikana
      HapticFeedback.heavyImpact();
      NotificationService.playScanner();
      NotificationService.show(
        context: context,
        message: 'Bidhaa haikupatikana: $raw',
        type: NotificationType.error,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _isProcessing = false);
      });
      return;
    }

    if (found.unit != 'SERVICE' && found.stock <= 0) {
      HapticFeedback.heavyImpact();
      NotificationService.show(
        context: context,
        message: '${found.name} — stock imekwisha!',
        type: NotificationType.warning,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _isProcessing = false);
      });
      return;
    }

    // Ongeza kwenye cart au ongeza idadi
    HapticFeedback.lightImpact();
    NotificationService.playScanner();

    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == found!.id,
      );

      if (existingIndex != -1) {
        // Bidhaa ipo tayari — ongeza idadi
        _cartItems[existingIndex].quantity += 1;
      } else {
        // Bidhaa mpya — ongeza kwenye cart
        _cartItems.insert(0, OrderItem(product: found!, quantity: 1));
      }

      _lastScannedName = found!.name;
    });

    // Ruhusu scan nyingine baada ya ms 800
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  void _increaseQty(int index) {
    final item = _cartItems[index];
    if (item.product.unit != 'SERVICE' &&
        item.quantity >= item.product.stock) {
      NotificationService.show(
        context: context,
        message: 'Stock imefika kikomo: ${item.product.stock}',
        type: NotificationType.warning,
      );
      return;
    }
    setState(() => _cartItems[index].quantity++);
  }

  void _decreaseQty(int index) {
    setState(() {
      if (_cartItems[index].quantity <= 1) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() => _cartItems.removeAt(index));
  }

  void _goToCheckout() {
    if (_cartItems.isEmpty) {
      NotificationService.show(
        context: context,
        message: 'Scan bidhaa kwanza',
        type: NotificationType.warning,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerCheckoutPage(items: List.from(_cartItems)),
      ),
    ).then((completed) {
      // Ukimaliza checkout — futa cart
      if (completed == true && mounted) {
        setState(() {
          _cartItems.clear();
          _lastScannedName = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ===== SCANNER JUU =====
            SizedBox(
              height: screenH * 0.45,
              child: Stack(
                children: [
                  // Camera
                  ClipRRect(
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: _onBarcodeDetected,
                    ),
                  ),

                  // Overlay ya scanning frame
                  Center(
                    child: Container(
                      width: 260,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isProcessing
                              ? _kGreen
                              : Colors.white.withValues(alpha: 0.8),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          _corner(Alignment.topLeft, true, true),
                          _corner(Alignment.topRight, true, false),
                          _corner(Alignment.bottomLeft, false, true),
                          _corner(Alignment.bottomRight, false, false),
                        ],
                      ),
                    ),
                  ),

                  // AppBar custom
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Scanner ya Mauzo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Torch
                          IconButton(
                            icon: const Icon(Icons.flashlight_on,
                                color: Colors.white),
                            onPressed: () =>
                                _scannerController.toggleTorch(),
                          ),
                          // Total badge
                          if (_cartItems.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _kOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_formatCurrency(_totalAmount)} TZS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Last scanned notification
                  if (_lastScannedName != null)
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: AnimatedOpacity(
                        opacity: _isProcessing ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _kGreen.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '✓  $_lastScannedName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ===== CART CHINI =====
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Header ya cart
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart_outlined,
                              color: _kNavy, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Bidhaa Zilizoscanned',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _kNavy,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_cartItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _kNavy.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_totalItems bidhaa',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kNavy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const Spacer(),
                          // Total
                          if (_cartItems.isNotEmpty)
                            Text(
                              '${_formatCurrency(_totalAmount)} TZS',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _kOrange,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Cart items list
                    Expanded(
                      child: _cartItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    size: 48,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Scan bidhaa kuanza',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              itemCount: _cartItems.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, indent: 16),
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return Dismissible(
                                  key: Key(item.product.id),
                                  direction:
                                      DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(
                                        right: 20),
                                    color: Colors.red.shade50,
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                  ),
                                  onDismissed: (_) =>
                                      _removeItem(index),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        // Bidhaa info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product.name,
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 13,
                                                  color: _kNavy,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_formatCurrency(item.product.sellingPrice)} /=',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Subtotal
                                        Text(
                                          '${_formatCurrency(item.total)} TZS',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: _kNavy,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        // +/- buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _QtyButton(
                                              icon: Icons.remove,
                                              color: Colors.red.shade400,
                                              onTap: () =>
                                                  _decreaseQty(index),
                                            ),
                                            Container(
                                              width: 32,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 14,
                                                  color: _kNavy,
                                                ),
                                              ),
                                            ),
                                            _QtyButton(
                                              icon: Icons.add,
                                              color: _kGreen,
                                              onTap: () =>
                                                  _increaseQty(index),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Checkout button
                    if (_cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 20),
                            label: Text(
                              'Maliza Order — ${_formatCurrency(_totalAmount)} TZS',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _goToCheckout,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corner(Alignment alignment, bool isTop, bool isLeft) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: _kOrange, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: _kOrange, width: 3)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: _kOrange, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: _kOrange, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}