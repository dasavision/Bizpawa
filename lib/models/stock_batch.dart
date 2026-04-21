import 'dart:math';

class StockBatch {
  final int batchNumber;
  final int quantity;
  final int buyingPrice;
  final int sellingPrice;
  final DateTime date;
  int remainingStock;
  final String batchBarcodeId; // ← MPYA: barcode ya batch hii

  StockBatch({
    required this.batchNumber,
    required this.quantity,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.date,
    required this.remainingStock,
    String? batchBarcodeId, // hiari — ikiwa haitolewa, inagenerate auto
  }) : batchBarcodeId = batchBarcodeId ?? _generateBatchBarcodeId(batchNumber);

  /// Auto-generate barcode ya batch kwa format: BIZB + batchNumber + digits 8
  /// Mfano: BIZB01-12345678
  /// "B" inamaanisha "Batch" — tofauti na barcode ya bidhaa (BIZ...)
  static String _generateBatchBarcodeId(int batchNumber) {
    final random = Random();
    final digits =
        List.generate(8, (_) => random.nextInt(10)).join();
    final batchStr = batchNumber.toString().padLeft(2, '0');
    return 'BIZB$batchStr$digits';
  }

  /// Jumla ya manunuzi
  int get totalCost => quantity * buyingPrice;

  /// Faida inayotarajiwa (ukiuza yote)
  int get expectedProfit => (sellingPrice - buyingPrice) * quantity;

  /// Faida iliyopatikana (kutoka stock iliyouzwa)
  int get earnedProfit =>
      (sellingPrice - buyingPrice) * (quantity - remainingStock);

  /// Jina la awamu kwa Kiswahili
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