import 'dart:math';
import 'stock_batch.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String unit;
  final int buyingPrice;
  final int sellingPrice;
  int stock;
  final String? imagePath;
  final String? description;
  final DateTime? expiryDate;
  final List<StockBatch> batches;
  final String barcodeId; // ← MPYA: barcode ya bidhaa (auto-generated)

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    this.imagePath,
    this.description,
    this.expiryDate,
    List<StockBatch>? batches,
    String? barcodeId, // hiari — ikiwa haitolewa, inagenerate auto
  })  : batches = batches ?? [],
        barcodeId = barcodeId ?? _generateBarcodeId();

  /// Auto-generate barcode ID kwa format: BIZ + digits 10
  /// Mfano: BIZ1234567890
  /// Inaweza kuscanniwa na kuunganishwa na bidhaa kwenye app
  static String _generateBarcodeId() {
    final random = Random();
    final digits =
        List.generate(10, (_) => random.nextInt(10)).join();
    return 'BIZ$digits';
  }
}