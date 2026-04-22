import 'dart:math';
import 'package:hive/hive.dart';

part 'stock_batch.g.dart';

@HiveType(typeId: 1)
class StockBatch {
  @HiveField(0)
  final int batchNumber;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final int buyingPrice;

  @HiveField(3)
  final int sellingPrice;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  int remainingStock;

  @HiveField(6)
  final String batchBarcodeId;

  StockBatch({
    required this.batchNumber,
    required this.quantity,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.date,
    required this.remainingStock,
    String? batchBarcodeId,
  }) : batchBarcodeId = batchBarcodeId ?? _generateBatchBarcodeId(batchNumber);

  static String _generateBatchBarcodeId(int batchNumber) {
    final random = Random();
    final digits = List.generate(8, (_) => random.nextInt(10)).join();
    final batchStr = batchNumber.toString().padLeft(2, '0');
    return 'BIZB$batchStr$digits';
  }

  int get totalCost => quantity * buyingPrice;
  int get expectedProfit => (sellingPrice - buyingPrice) * quantity;
  int get earnedProfit => (sellingPrice - buyingPrice) * (quantity - remainingStock);

  String get batchName {
    const names = [
      'Kwanza', 'Pili', 'Tatu', 'Nne', 'Tano',
      'Sita', 'Saba', 'Nane', 'Tisa', 'Kumi',
    ];
    if (batchNumber <= names.length) {
      return 'Awamu ya ${names[batchNumber - 1]}';
    }
    return 'Awamu ya $batchNumber';
  }
}