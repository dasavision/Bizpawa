import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/models/stock_batch.dart';
import 'edit_product_page.dart';
import 'add_stock_page.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

// =====================================================================
// BARCODE 1D PAINTER — inachora Code128-style barcode kwa CustomPainter
// Hii inafanya kazi bila package yoyote ya ziada
// =====================================================================
class BarcodePainter extends CustomPainter {
  final String data;
  final Color barColor;

  BarcodePainter({
    required this.data,
    this.barColor = Colors.black,
  });

  // Code128B encoding — kila character inabeba pattern ya bars
  static const Map<String, String> _code128 = {
    ' ': '11011001100', '!': '11001101100', '"': '11001100110',
    '#': '10010011000', r'$': '10010001100', '%': '10001001100',
    '&': '10011001000', "'": '10011000100', '(': '10001100100',
    ')': '11001001000', '*': '11001000100', '+': '11000100100',
    ',': '10110011100', '-': '10011011100', '.': '10011001110',
    '/': '10111001100', '0': '10011101100', '1': '10011100110',
    '2': '11001110010', '3': '11001011100', '4': '11001001110',
    '5': '11011100100', '6': '11001110100', '7': '11101101110',
    '8': '11101001100', '9': '11100101100', ':': '11100100110',
    ';': '11101100100', '<': '11100110100', '=': '11100110010',
    '>': '11011011000', '?': '11011000110', '@': '11000110110',
    'A': '10100011000', 'B': '10001011000', 'C': '10001000110',
    'D': '10110001000', 'E': '10001101000', 'F': '10001100010',
    'G': '11010001000', 'H': '11000101000', 'I': '11000100010',
    'J': '10110111000', 'K': '10110001110', 'L': '10001101110',
    'M': '10111011000', 'N': '10111000110', 'O': '10001110110',
    'P': '11101110110', 'Q': '11010001110', 'R': '11000101110',
    'S': '11011101000', 'T': '11011100010', 'U': '11011101110',
    'V': '11101011000', 'W': '11101000110', 'X': '11100010110',
    'Y': '11101101000', 'Z': '11101100010', '[': '11100011010',
    '\\': '11101111010', ']': '11001000010', '^': '11110001010',
    '_': '10100110000', '`': '10100001100', 'a': '10010110000',
    'b': '10010000110', 'c': '10000101100', 'd': '10000100110',
    'e': '10110010000', 'f': '10110000100', 'g': '10011010000',
    'h': '10011000010', 'i': '10000110100', 'j': '10000110010',
    'k': '11000010010', 'l': '11001010000', 'm': '11110111010',
    'n': '11000010100', 'o': '10001111010', 'p': '10100111100',
    'q': '10010111100', 'r': '10010011110', 's': '10111100100',
    't': '10011110100', 'u': '10011110010', 'v': '11110100100',
    'w': '11110010100', 'x': '11110010010', 'y': '11011011110',
    'z': '11011110110', '{': '11110110110', '|': '10101111000',
    '}': '10100011110', '~': '10001011110',
  };

  // Start B pattern
  static const String _startB = '11010010000';
  static const String _stop = '1100011101011';

  String _encode(String input) {
    final buf = StringBuffer();
    buf.write(_startB);
    // Checksum calculation
    int checksum = 104; // Start B value
    int pos = 1;
    for (final char in input.characters) {
      final pattern = _code128[char];
      if (pattern != null) {
        buf.write(pattern);
        // Find code value for checksum
        final codeVal = _code128.keys.toList().indexOf(char);
        checksum += codeVal * pos;
        pos++;
      }
    }
    // Checksum symbol
    final checksumVal = checksum % 103;
    final checksumKey = _code128.keys.elementAt(checksumVal);
    buf.write(_code128[checksumKey] ?? '');
    buf.write(_stop);
    return buf.toString();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Tumia barcodeId kama data — digits na herufi zote zinafanya kazi
    // Fupisha data ikiwa ni ndefu sana ili iwe readable
    final encoded = _encode(data.length > 20 ? data.substring(0, 20) : data);

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final totalBits = encoded.length;
    if (totalBits == 0) return;

    final barWidth = size.width / totalBits;

    for (int i = 0; i < encoded.length; i++) {
      if (encoded[i] == '1') {
        canvas.drawRect(
          Rect.fromLTWH(i * barWidth, 0, barWidth, size.height),
          barPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BarcodePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.barColor != barColor;
}

// Widget rahisi ya kutumia BarcodePainter
class BarcodeWidget extends StatelessWidget {
  final String data;
  final double width;
  final double height;
  final Color barColor;

  const BarcodeWidget({
    super.key,
    required this.data,
    required this.width,
    required this.height,
    this.barColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: BarcodePainter(data: data, barColor: barColor),
        size: Size(width, height),
      ),
    );
  }
}

// =====================================================================
// PRODUCT DETAIL PAGE
// =====================================================================
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  String _fmt(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();
    final isService = product.unit == 'SERVICE';

    final p = business.inventory.firstWhere(
      (x) => x.id == product.id,
      orElse: () => product,
    );

    // Batch code ya sasa — #BIZB + batch number 4 digits
    final currentBatchCode = p.batches.isNotEmpty
        ? '#BIZB${p.batches.last.batchNumber.toString().padLeft(4, '0')}'
        : '#BIZB0001';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          p.name,
          style: const TextStyle(
              color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kNavyBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined,
                  color: kNavyBlue, size: 18),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditProductPage(product: p)),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 18),
            ),
            onPressed: () => _confirmDelete(context, business, p),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== BIDHAA INFO =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: kNavyBlue.withValues(alpha: 0.08),
                      image: p.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(p.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: p.imagePath == null
                        ? Icon(
                            isService
                                ? Icons.handyman
                                : Icons.inventory_2,
                            color: kNavyBlue,
                            size: 28,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kNavyBlue,
                            )),
                        const SizedBox(height: 4),
                        Text(p.category,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isService
                                ? const Color(0xFF6366F1)
                                    .withValues(alpha: 0.1)
                                : p.stock == 0
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : p.stock <= 5
                                        ? kOrange.withValues(alpha: 0.1)
                                        : const Color(0xFF22C55E)
                                            .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isService ? 'HUDUMA' : '${p.stock} ${p.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isService
                                  ? const Color(0xFF6366F1)
                                  : p.stock == 0
                                      ? Colors.red
                                      : p.stock <= 5
                                          ? kOrange
                                          : const Color(0xFF22C55E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== PRICE TAG =====
            const Text(
              'Price Tag & Barcode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kNavyBlue,
              ),
            ),
            const SizedBox(height: 12),

            _PriceTagCard(
              product: p,
              businessName: business.businessName,
              batchCode: currentBatchCode,
              fmt: _fmt,
            ),

            const SizedBox(height: 24),

            // ===== AWAMU ZA MZIGO =====
            if (!isService) ...[
              const Text(
                'Awamu za Mzigo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavyBlue,
                ),
              ),
              const SizedBox(height: 12),

              p.batches.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 40,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text('Hakuna awamu bado',
                              style: TextStyle(
                                  color: Colors.grey.shade400)),
                        ],
                      ),
                    )
                  : Column(
                      children: p.batches
                          .map((batch) => _BatchCard(
                                batch: batch,
                                fmt: _fmt,
                              ))
                          .toList(),
                    ),
            ],

            if (isService) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Bei ya Huduma',
                        '${_fmt(p.sellingPrice)} TZS'),
                    if (p.description != null &&
                        p.description!.isNotEmpty) ...[
                      const Divider(),
                      _infoRow('Maelezo', p.description!),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: !isService
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNavyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Ongeza Stock',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddStockPage(product: p)),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, BusinessState business, Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Futa Bidhaa',
            style: TextStyle(color: Colors.red)),
        content: Text('Una uhakika unataka kufuta "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              business.deleteProductById(p.id);
              Navigator.pop(context);
              Navigator.pop(context);
              NotificationService.show(
                context: context,
                message: 'Bidhaa "${p.name}" imefutwa',
                type: NotificationType.error,
              );
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PRICE TAG CARD — container ya buttons + preview
// =====================================================================
class _PriceTagCard extends StatefulWidget {
  final Product product;
  final String businessName;
  final String batchCode;
  final String Function(int) fmt;

  const _PriceTagCard({
    required this.product,
    required this.businessName,
    required this.batchCode,
    required this.fmt,
  });

  @override
  State<_PriceTagCard> createState() => _PriceTagCardState();
}

class _PriceTagCardState extends State<_PriceTagCard> {
  // GlobalKey ya RepaintBoundary — inatumika kusave image
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kNavyBlue.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.label_outline,
                    color: kNavyBlue, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Price Tag ya Bidhaa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kNavyBlue,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Price tag preview — imefungwa na RepaintBoundary
          // RepaintBoundary inatuwezesha ku-capture kama image
          Padding(
            padding: const EdgeInsets.all(20),
            child: RepaintBoundary(
              key: _repaintKey,
              child: _PriceTagPreview(
                productName: widget.product.name,
                sellingPrice: widget.product.sellingPrice,
                businessName: widget.businessName,
                barcodeId: widget.product.barcodeId,
                batchCode: widget.batchCode,
                fmt: widget.fmt,
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.print_outlined,
                    label: 'Print PDF',
                    color: kNavyBlue,
                    onTap: () => _printPdf(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.download_outlined,
                    label: 'Save Image',
                    color: const Color(0xFF22C55E),
                    onTap: () => _saveImage(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: kOrange,
                    onTap: () => _shareImage(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Capture RepaintBoundary kama PNG bytes
  Future<Uint8List?> _captureImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Pixel ratio ya juu = image ya ubora
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveImage(BuildContext context) async {
    final bytes = await _captureImage();
    if (bytes == null) {
      if (context.mounted) {
        NotificationService.show(
          context: context,
          message: 'Imeshindwa kutengeneza image',
          type: NotificationType.error,
        );
      }
      return;
    }

    try {
      // Hifadhi kwenye Downloads au temp directory
      final dir = await getTemporaryDirectory();
      final fileName =
          'pricetag_${widget.product.barcodeId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share kama njia ya kusave (iOS na Android)
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Price Tag — ${widget.product.name}',
      );
    } catch (e) {
      if (context.mounted) {
        NotificationService.show(
          context: context,
          message: 'Imeshindwa kuhifadhi image',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    final bytes = await _captureImage();
    if (bytes == null) {
      if (context.mounted) {
        NotificationService.show(
          context: context,
          message: 'Imeshindwa kutengeneza image',
          type: NotificationType.error,
        );
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/pricetag_${widget.product.barcodeId}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '🏷️ ${widget.product.name}\n💰 TZS ${widget.fmt(widget.product.sellingPrice)}\n📦 ${widget.businessName}',
      );
    } catch (e) {
      if (context.mounted) {
        NotificationService.show(
          context: context,
          message: 'Imeshindwa kushare image',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 3 * PdfPageFormat.mm,
        ),
        build: (ctx) => [
          for (int i = 0; i < 10; i++) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              margin: const pw.EdgeInsets.only(bottom: 3),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Business name
                  pw.Text(
                    widget.businessName,
                    style: pw.TextStyle(
                        fontSize: 6, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 2),
                  // Product name
                  pw.Text(
                    widget.product.name,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  // Bei kubwa
                  pw.Text(
                    'TZS ${widget.fmt(widget.product.sellingPrice)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  // 1D Barcode (Code128) — hii inafanya kazi vizuri kwenye PDF
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: widget.product.barcodeId,
                    width: double.infinity,
                    height: 28,
                    drawText: false,
                  ),
                  pw.SizedBox(height: 2),
                  // Barcode number chini
                  pw.Center(
                    child: pw.Text(
                      widget.product.barcodeId,
                      style: pw.TextStyle(fontSize: 5),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  // Batch code — discrete chini kabisa
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      widget.batchCode,
                      style: pw.TextStyle(
                        fontSize: 5,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) => doc.save(),
      name: 'PriceTag_${widget.product.name}',
    );
  }
}

// =====================================================================
// PRICE TAG PREVIEW — inaonyesha jinsi itakavyoonekana kwenye screen
// Layout inafanana na picha ulizoweka
// =====================================================================
class _PriceTagPreview extends StatelessWidget {
  final String productName;
  final int sellingPrice;
  final String businessName;
  final String barcodeId;
  final String batchCode;
  final String Function(int) fmt;

  const _PriceTagPreview({
    required this.productName,
    required this.sellingPrice,
    required this.businessName,
    required this.barcodeId,
    required this.batchCode,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ===== SEHEMU YA KUSHOTO — bidhaa info + barcode =====
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business name — ndogo juu
                    Text(
                      businessName,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product name — bold
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // 1D Barcode — flat kama kwenye picha
                    BarcodeWidget(
                      data: barcodeId,
                      width: double.infinity,
                      height: 48,
                      barColor: Colors.black,
                    ),

                    const SizedBox(height: 4),

                    // Barcode number chini ya bars
                    Text(
                      barcodeId,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                        fontFamily: 'monospace',
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Batch code — discrete, chini kabisa
                    Text(
                      batchCode,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade400,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== DIVIDER =====
            Container(
              width: 1,
              color: Colors.grey.shade300,
            ),

            // ===== SEHEMU YA KULIA — bei (manjano kama kwenye picha) =====
            Container(
              width: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFFACC15), // manjano
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'TZS\n${fmt(sellingPrice)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// BATCH CARD — details tu, bila barcode ya scan
// =====================================================================
class _BatchCard extends StatelessWidget {
  final StockBatch batch;
  final String Function(int) fmt;

  const _BatchCard({required this.batch, required this.fmt});

  String get _batchCode =>
      '#BIZB${batch.batchNumber.toString().padLeft(4, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kNavyBlue.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        batch.batchName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kNavyBlue,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _batchCode,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${batch.date.day}/${batch.date.month}/${batch.date.year}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('Bei ya kununua',
                    '${fmt(batch.buyingPrice)} TZS'),
                const SizedBox(height: 8),
                _row('Bei ya kuuza',
                    '${fmt(batch.sellingPrice)} TZS'),
                const SizedBox(height: 8),
                _row('Idadi iliyonunuliwa', '${batch.quantity}'),
                const SizedBox(height: 8),
                _row('Jumla ya manunuzi',
                    '${fmt(batch.totalCost)} TZS'),
                const Divider(height: 20),
                _row(
                  'Stock iliyobaki',
                  '${batch.remainingStock} vilivyobaki',
                  valueColor: batch.remainingStock == 0
                      ? Colors.red
                      : batch.remainingStock <= 5
                          ? kOrange
                          : const Color(0xFF22C55E),
                ),
                const SizedBox(height: 8),
                _row(
                  'Faida iliyopatikana',
                  '${fmt(batch.earnedProfit)} TZS',
                  valueColor: batch.earnedProfit > 0
                      ? const Color(0xFF22C55E)
                      : Colors.grey,
                ),
                const SizedBox(height: 8),
                _row(
                  'Faida inayotarajiwa (yote)',
                  '${fmt(batch.expectedProfit)} TZS',
                  valueColor: Colors.grey.shade500,
                  isItalic: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {Color? valueColor, bool isItalic = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? kNavyBlue,
            fontStyle:
                isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// ACTION BUTTON
// =====================================================================
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}