import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class InvoicePage extends StatefulWidget {
  final SaleEntry order;
  final String businessName;
  final String businessPhone;

  const InvoicePage({
    super.key,
    required this.order,
    required this.businessName,
    required this.businessPhone,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool _isPrinting = false;
  bool _isConnecting = false;
  String? _connectedPrinterMac;
  List<BluetoothInfo> _printers = [];

  String _fmt(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _paymentMethodName(String? method) {
    switch (method) {
      case 'cash': return 'Pesa Taslimu';
      case 'mobile': return 'Simu (M-Pesa/Tigo)';
      case 'bank': return 'Benki';
      default: return method ?? '---';
    }
  }

  Future<pw.ImageProvider> _buildQrImage() async {
    final qrPainter = QrPainter(
      data: widget.order.orderNumber,
      version: QrVersions.auto,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
      gapless: true,
    );
    final imageData = await qrPainter.toImageData(200);
    return pw.MemoryImage(imageData!.buffer.asUint8List());
  }

  Future<Uint8List> _buildPdfBytes() async {
    final pdf = pw.Document();
    final order = widget.order;
    final subtotal =
        order.items.fold<int>(0, (sum, item) => sum + item.subtotal);
    final qrImage = await _buildQrImage();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              widget.businessName.toUpperCase(),
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text('Tel: ${widget.businessPhone}',
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Text(order.orderNumber,
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 2),
            pw.Text(
              '${order.date.day}/${order.date.month}/${order.date.year}  '
              '${order.date.hour.toString().padLeft(2, '0')}:'
              '${order.date.minute.toString().padLeft(2, '0')}',
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Muuzaji:',
                    style: const pw.TextStyle(fontSize: 7)),
                pw.Text(order.sellerName,
                    style: pw.TextStyle(
                        fontSize: 7, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            if (order.customerName != null &&
                order.customerName!.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Mteja:',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(order.customerName!,
                      style: pw.TextStyle(
                          fontSize: 7, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
            if (order.customerPhone != null &&
                order.customerPhone!.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Simu:',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(order.customerPhone!,
                      style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
            ],
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Row(
              children: [
                pw.Expanded(
                    flex: 4,
                    child: pw.Text('BIDHAA',
                        style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('IDADI',
                        style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center)),
                pw.Expanded(
                    flex: 3,
                    child: pw.Text('KIASI',
                        style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right)),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.3),
            ...order.items.map((item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Expanded(
                              flex: 4,
                              child: pw.Text(item.productName,
                                  style: pw.TextStyle(
                                      fontSize: 7,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                item.unit == 'SERVICE'
                                    ? '${item.quantity}'
                                    : '${item.quantity} ${item.unit}',
                                style: const pw.TextStyle(fontSize: 7),
                                textAlign: pw.TextAlign.center,
                              )),
                          pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                'Tshs ${_fmt(item.subtotal)}',
                                style: const pw.TextStyle(fontSize: 7),
                                textAlign: pw.TextAlign.right,
                              )),
                        ],
                      ),
                      pw.Text('@${_fmt(item.sellingPrice)} /=',
                          style: const pw.TextStyle(
                              fontSize: 6, color: PdfColors.grey600)),
                    ],
                  ),
                )),
            pw.Divider(thickness: 0.3),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Jumla Ndogo:',
                    style: const pw.TextStyle(fontSize: 7)),
                pw.Text('Tshs ${_fmt(subtotal)} /=',
                    style: const pw.TextStyle(fontSize: 7)),
              ],
            ),
            if (order.discount > 0) ...[
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Punguzo:',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text('- Tshs ${_fmt(order.discount)} /=',
                      style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
            ],
            pw.SizedBox(height: 2),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('JUMLA KUBWA:',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('Tshs ${_fmt(order.amount)} /=',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Malipo:',
                    style: const pw.TextStyle(fontSize: 7)),
                pw.Text(order.paid ? 'IMELIPWA' : 'HAIJALIPIWA',
                    style: pw.TextStyle(
                        fontSize: 7, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            if (order.paymentMethod != null) ...[
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Njia:', style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(_paymentMethodName(order.paymentMethod),
                      style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
            ],
            if (order.note != null && order.note!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text('Maelezo: ${order.note}',
                  style: const pw.TextStyle(fontSize: 6)),
            ],
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 6),
            pw.Center(
                child: pw.Image(qrImage, width: 55, height: 55)),
            pw.SizedBox(height: 2),
            pw.Text(order.orderNumber,
                style: const pw.TextStyle(fontSize: 6),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Text('★  Asante na Karibu Tena!  ★',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 2),
            pw.Text('Tunakaribisha kila wakati',
                style: const pw.TextStyle(fontSize: 6),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 6),
            pw.Text('Powered by BizPawa',
                style: pw.TextStyle(
                    fontSize: 6, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
            pw.Text('Smarter Control, Stronger Growth',
                style: const pw.TextStyle(
                    fontSize: 5, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 6),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ===== BLUETOOTH =====
  Future<void> _scanPrinters() async {
  setState(() => _isConnecting = true);
  try {
    // Omba permissions kwanza
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    // Angalia kama permissions zimepewa
    final connectStatus = await Permission.bluetoothConnect.status;
    final scanStatus = await Permission.bluetoothScan.status;

    if (connectStatus.isDenied || scanStatus.isDenied) {
      if (mounted) {
        NotificationService.show(
          context: context,
          message: 'Ruhusa ya Bluetooth inahitajika',
          type: NotificationType.error,
        );
      }
      setState(() => _isConnecting = false);
      return;
    }

    // Angalia Bluetooth imewashwa
    final bool enabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!enabled) {
      if (mounted) {
        NotificationService.show(
          context: context,
          message: 'Washa Bluetooth kwanza',
          type: NotificationType.error,
        );
      }
      setState(() => _isConnecting = false);
      return;
    }

    // Pata printers zilizounganishwa
    final List<BluetoothInfo> devices =
        await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
      _printers = devices;
      _isConnecting = false;
    });

    if (devices.isEmpty) {
      if (mounted) {
        NotificationService.show(
          context: context,
          message: 'Hakuna printer. Unganisha kwenye Bluetooth settings kwanza.',
          type: NotificationType.warning,
        );
      }
    } else {
      if (mounted) _showPrinterSheet();
    }
  } catch (e) {
    setState(() => _isConnecting = false);
    if (mounted) {
      NotificationService.show(
        context: context,
        message: 'Hitilafu ya Bluetooth: $e',
        type: NotificationType.error,
      );
    }
  }
}

  void _showPrinterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chagua Printer',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavyBlue),
            ),
            const SizedBox(height: 12),
            ..._printers.map((printer) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kNavyBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_outlined,
                        color: kNavyBlue, size: 20),
                  ),
                  title: Text(printer.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: kNavyBlue)),
                  subtitle: Text(printer.macAdress,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                  trailing: _connectedPrinterMac == printer.macAdress
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF22C55E))
                      : const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                  onTap: () async {
                    Navigator.pop(context);
                    await _connectAndPrint(printer);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _connectAndPrint(BluetoothInfo printer) async {
    setState(() => _isPrinting = true);
    try {
      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAdress,
      );

      if (!connected) {
        if (mounted) {
          NotificationService.show(
            context: context,
            message: 'Imeshindwa kuunganisha na ${printer.name}',
            type: NotificationType.error,
          );
        }
        setState(() => _isPrinting = false);
        return;
      }

      setState(() => _connectedPrinterMac = printer.macAdress);
      await _printEscPos();
    } catch (e) {
      if (mounted) {
        NotificationService.show(
          context: context,
          message: 'Hitilafu: $e',
          type: NotificationType.error,
        );
      }
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  Future<void> _printEscPos() async {
    final order = widget.order;
    final subtotal =
        order.items.fold<int>(0, (sum, item) => sum + item.subtotal);

    List<int> bytes = [];

    // Init
    bytes += [0x1B, 0x40];

    // Center
    bytes += [0x1B, 0x61, 0x01];
    // Bold on
    bytes += [0x1B, 0x45, 0x01];
    bytes += _txt('${widget.businessName}\n');
    // Bold off
    bytes += [0x1B, 0x45, 0x00];
    bytes += _txt('Tel: ${widget.businessPhone}\n');
    bytes += _txt('--------------------------------\n');

    // Left
    bytes += [0x1B, 0x61, 0x00];
    bytes += _txt('Order: ${order.orderNumber}\n');
    bytes += _txt(
        'Tarehe: ${order.date.day}/${order.date.month}/${order.date.year}\n');
    bytes += _txt(
        'Muda: ${order.date.hour.toString().padLeft(2, '0')}:${order.date.minute.toString().padLeft(2, '0')}\n');
    bytes += _txt('Muuzaji: ${order.sellerName}\n');
    if (order.customerName != null && order.customerName!.isNotEmpty) {
      bytes += _txt('Mteja: ${order.customerName}\n');
    }
    if (order.customerPhone != null && order.customerPhone!.isNotEmpty) {
      bytes += _txt('Simu: ${order.customerPhone}\n');
    }
    bytes += _txt('--------------------------------\n');

    // Items
    for (final item in order.items) {
      bytes += _txt('${item.productName}\n');
      final qty = item.unit == 'SERVICE'
          ? '${item.quantity}'
          : '${item.quantity} ${item.unit}';
      final line = '  $qty x ${_fmt(item.sellingPrice)}'.padRight(22) +
          '${_fmt(item.subtotal)}\n';
      bytes += _txt(line);
    }

    bytes += _txt('--------------------------------\n');

    if (order.discount > 0) {
      bytes += _txt('Jumla ndogo:'.padRight(18) + '${_fmt(subtotal)} TZS\n');
      bytes +=
          _txt('Punguzo:'.padRight(18) + '-${_fmt(order.discount)} TZS\n');
    }

    bytes += [0x1B, 0x45, 0x01];
    bytes +=
        _txt('JUMLA KUBWA:'.padRight(18) + '${_fmt(order.amount)} TZS\n');
    bytes += [0x1B, 0x45, 0x00];

    bytes += _txt('--------------------------------\n');
    bytes += _txt('Hali: ${order.paid ? 'IMELIPWA' : 'HAIJALIPIWA'}\n');
    if (order.paymentMethod != null) {
      bytes += _txt('Njia: ${_paymentMethodName(order.paymentMethod)}\n');
    }

    if (order.note != null && order.note!.isNotEmpty) {
      bytes += _txt('Maelezo: ${order.note}\n');
    }

    bytes += _txt('--------------------------------\n');

    // Center
    bytes += [0x1B, 0x61, 0x01];
    bytes += [0x1B, 0x45, 0x01];
    bytes += _txt('* Asante na Karibu Tena! *\n');
    bytes += [0x1B, 0x45, 0x00];
    bytes += _txt('Powered by BizPawa\n');
    bytes += _txt('Smarter Control, Stronger Growth\n');

    // Feed + cut
    bytes += [0x1B, 0x64, 0x05];
    bytes += [0x1D, 0x56, 0x41, 0x00];

    final bool result = await PrintBluetoothThermal.writeBytes(bytes);

    if (mounted) {
      NotificationService.show(
        context: context,
        message:
            result ? 'Risiti imechapishwa!' : 'Imeshindwa kuchapisha.',
        type: result ? NotificationType.success : NotificationType.error,
      );
    }
  }

  List<int> _txt(String text) => text.codeUnits;

  @override
  Widget build(BuildContext context) {
    final business = context.read<BusinessState>();
    final order = widget.order;
    final subtotal =
        order.items.fold<int>(0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Risiti ya Order',
          style: TextStyle(
              color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [

          // ===== RECEIPT PREVIEW =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Text(
                        widget.businessName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kNavyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tel: ${widget.businessPhone}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      if (business.businessAddress.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          business.businessAddress,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      const SizedBox(height: 6),

                      // Order info
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kNavyBlue,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.date.day}/${order.date.month}/${order.date.year}  '
                        '${order.date.hour.toString().padLeft(2, '0')}:'
                        '${order.date.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Divider(thickness: 0.5),
                      const SizedBox(height: 6),

                      _row('Muuzaji:', order.sellerName),
                      if (order.customerName != null &&
                          order.customerName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _row('Mteja:', order.customerName!),
                      ],
                      if (order.customerPhone != null &&
                          order.customerPhone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _row('Simu:', order.customerPhone!),
                      ],
                      const SizedBox(height: 8),
                      const Divider(thickness: 0.5),
                      const SizedBox(height: 6),

                      // Items header
                      Row(
                        children: const [
                          Expanded(
                            flex: 4,
                            child: Text('BIDHAA',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('IDADI',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('KIASI',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                      const Divider(thickness: 0.3),

                      // Items
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(item.productName,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        item.unit == 'SERVICE'
                                            ? '${item.quantity}'
                                            : '${item.quantity} ${item.unit}',
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Tshs ${_fmt(item.subtotal)}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '@${_fmt(item.sellingPrice)} /=',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )),

                      const Divider(thickness: 0.3),
                      const SizedBox(height: 4),

                      // Totals
                      _row('Jumla Ndogo:',
                          'Tshs ${_fmt(subtotal)} /='),
                      if (order.discount > 0) ...[
                        const SizedBox(height: 4),
                        _row('Punguzo:',
                            '- Tshs ${_fmt(order.discount)} /=',
                            valueColor: Colors.red),
                      ],
                      const SizedBox(height: 6),
                      const Divider(thickness: 1),
                      const SizedBox(height: 6),
                      _row(
                        'JUMLA KUBWA:',
                        'Tshs ${_fmt(order.amount)} /=',
                        bold: true,
                        valueColor: kNavyBlue,
                      ),
                      const SizedBox(height: 8),
                      const Divider(thickness: 0.5),
                      const SizedBox(height: 6),

                      // Payment
                      _row(
                        'Malipo:',
                        order.paid ? 'IMELIPWA' : 'HAIJALIPIWA',
                        valueColor: order.paid
                            ? const Color(0xFF22C55E)
                            : kOrange,
                      ),
                      if (order.paymentMethod != null) ...[
                        const SizedBox(height: 4),
                        _row('Njia:',
                            _paymentMethodName(order.paymentMethod)),
                      ],

                      if (order.note != null &&
                          order.note!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Maelezo: ${order.note}',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // QR Code
                      QrImageView(
                        data: order.orderNumber,
                        version: QrVersions.auto,
                        size: 80,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: kNavyBlue,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: kNavyBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500),
                      ),

                      const SizedBox(height: 16),
                      const Divider(thickness: 0.5),
                      const SizedBox(height: 8),

                      const Text(
                        '★  Asante na Karibu Tena!  ★',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: kNavyBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tunakaribisha kila wakati',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),
                      const Divider(thickness: 0.5),
                      const SizedBox(height: 6),

                      Text(
                        'Powered by BizPawa',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Smarter Control, Stronger Growth',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== BUTTONS =====
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: Column(
              children: [

                // PRINT BLUETOOTH
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isPrinting || _isConnecting
                              ? Colors.grey.shade300
                              : kNavyBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isPrinting || _isConnecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.print_outlined, size: 18),
                    label: Text(
                      _isPrinting
                          ? 'Inachapisha...'
                          : _isConnecting
                              ? 'Inatafuta printer...'
                              : _connectedPrinterMac != null
                                  ? 'Chapisha Tena (Bluetooth)'
                                  : 'Chapisha (Bluetooth)',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isPrinting || _isConnecting
                        ? null
                        : () async {
                            if (_connectedPrinterMac != null) {
                              setState(() => _isPrinting = true);
                              await _printEscPos();
                              setState(() => _isPrinting = false);
                            } else {
                              await _scanPrinters();
                            }
                          },
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    // SHARE PDF
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kNavyBlue,
                            side: const BorderSide(color: kNavyBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Shiriki'),
                          onPressed: () async {
                            final bytes = await _buildPdfBytes();
                            await Printing.sharePdf(
                              bytes: bytes,
                              filename:
                                  '${widget.order.orderNumber}.pdf',
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // DOWNLOAD PDF
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(
                                color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.download_outlined,
                              size: 18),
                          label: const Text('Pakua PDF'),
                          onPressed: () async {
                            final bytes = await _buildPdfBytes();
                            await Printing.layoutPdf(
                              onLayout: (_) async => bytes,
                              name: widget.order.orderNumber,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 12 : 10,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}