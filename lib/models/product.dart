import 'dart:math';
import 'package:hive/hive.dart';
import 'stock_batch.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final int buyingPrice;

  @HiveField(5)
  final int sellingPrice;

  @HiveField(6)
  int stock;

  @HiveField(7)
  final String? imagePath;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final DateTime? expiryDate;

  @HiveField(10)
  final List<StockBatch> batches;

  @HiveField(11)
  final String barcodeId;

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
    String? barcodeId,
  })  : batches = batches ?? [],
        barcodeId = barcodeId ?? _generateBarcodeId();

  static String _generateBarcodeId() {
    final random = Random();
    final digits = List.generate(10, (_) => random.nextInt(10)).join();
    return 'BIZ$digits';
  }
}