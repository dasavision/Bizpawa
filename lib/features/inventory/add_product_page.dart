import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/product.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _stockController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imagePath;
  bool _showDescription = false;
  bool _showBarcode = false;
  String _selectedKundi = 'General';
  String? _selectedUnit;
  DateTime? _expiryDate;

  // Auto-generated barcode ID kwa bidhaa hii
  // Inatengenezwa mara moja na haibadiliki isipokuwa user ascan/aweke mwenyewe
  late String _autoBarcodeId;

  final List<String> _units = [
    'PCS', 'KG', 'BOX', 'LTR',
    'Kipande', 'Pakiti', 'Chupa',
    'Mkebe', 'Mfuko', 'Gunia',
    'Karatasi', 'Roli', 'Seti',
    'Dazeni', 'Trei',
  ];

  @override
  void initState() {
    super.initState();
    // Generate barcode mara moja wakati page inafunguka
    _autoBarcodeId = _generateBarcodeId();
    // Weka kwenye controller ili user aone
    _barcodeController.text = _autoBarcodeId;
  }

  /// Generate barcode ID: BIZ + digits 10
  String _generateBarcodeId() {
    final random = Random();
    final digits =
        List.generate(10, (_) => random.nextInt(10)).join();
    return 'BIZ$digits';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _stockController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    setState(() => _imagePath = image.path);
  }

  void _showImageOptions() {
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chagua Picha',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kNavyBlue,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kNavyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: kNavyBlue, size: 18),
              ),
              title: const Text('Piga Picha'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: kOrange, size: 18),
              ),
              title: const Text('Chagua kutoka Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                ),
                title: const Text('Toa Picha',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _imagePath = null);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: DateTime.now(),
    );
    if (date != null) setState(() => _expiryDate = date);
  }

  String _formatCurrency(String value) {
    final clean = value.replaceAll(',', '');
    final number = int.tryParse(clean);
    if (number == null) return value;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _openScanner() {
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan Barcode ya Bidhaa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Elekeza kamera kwenye barcode ya bidhaa',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          final barcode = capture.barcodes.firstOrNull;
                          final raw = barcode?.rawValue;
                          if (raw != null) {
                            controller.dispose();
                            Navigator.pop(context);
                            NotificationService.playScanner();
                            setState(() {
                              _barcodeController.text = raw;
                              _showBarcode = true;
                            });
                            NotificationService.show(
                              context: context,
                              message: 'Barcode imescanniwa vizuri',
                              type: NotificationType.success,
                            );
                          }
                        },
                      ),
                      Container(color: Colors.black45),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 280,
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: kOrange, width: 2.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  _corner(Alignment.topLeft, true, true),
                                  _corner(Alignment.topRight, true, false),
                                  _corner(Alignment.bottomLeft, false, true),
                                  _corner(Alignment.bottomRight, false, false),
                                  Center(
                                    child: Container(
                                      height: 2,
                                      width: 260,
                                      color: kOrange.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Weka barcode ndani ya mstari',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => controller.toggleTorch(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.flashlight_on,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(context);
              },
              child: const Text('Ghairi',
                  style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 8),
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
                ? const BorderSide(color: kOrange, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: kOrange, width: 3)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: kOrange, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: kOrange, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showKundiSheet(BusinessState business) {
    final makundi = [
      'General',
      ...business.categories.where((k) => k != 'General'),
    ];

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
              'Chagua Kundi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavyBlue),
            ),
            const SizedBox(height: 12),
            ...makundi.map((kundi) {
              final selected = _selectedKundi == kundi;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_outlined,
                      color: Color(0xFF6366F1), size: 18),
                ),
                title: Text(
                  kundi,
                  style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? kNavyBlue : Colors.black87,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check, color: kNavyBlue)
                    : null,
                onTap: () {
                  setState(() => _selectedKundi = kundi);
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _createKundiDialog(business);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kNavyBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tengeneza Kundi Jipya',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUnitSheet() {
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
              'Chagua Kipimo / Kifungashio',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kNavyBlue),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _units.map((unit) {
                  final selected = _selectedUnit == unit;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kNavyBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.straighten,
                          color: kNavyBlue, size: 18),
                    ),
                    title: Text(
                      unit,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color: selected ? kNavyBlue : Colors.black87,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check, color: kNavyBlue)
                        : null,
                    onTap: () {
                      setState(() => _selectedUnit = unit);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _createKundiDialog(BusinessState business) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Tengeneza Kundi Jipya',
          style:
              TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Mf. Nafaka, Vinywaji...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavyBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                business.addCustomCategory(value);
                setState(() => _selectedKundi = value);
              }
              Navigator.pop(context);
            },
            child: const Text('Hifadhi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kNavyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ongeza Bidhaa Mpya',
          style:
              TextStyle(color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // IMAGE
              Center(
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: kNavyBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kNavyBlue.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      image: _imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: kNavyBlue, size: 32),
                              const SizedBox(height: 6),
                              const Text('Picha',
                                  style: TextStyle(
                                      fontSize: 12, color: kNavyBlue)),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _imagePath = null),
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.red),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // JINA
              _label('Jina la Bidhaa'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Mf. Sukari, Mchele...'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Jina linahitajika' : null,
              ),

              const SizedBox(height: 20),

              // KUNDI
              _label('Kundi la Bidhaa'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _showKundiSheet(business),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.folder_outlined,
                            color: Color(0xFF6366F1), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(_selectedKundi,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87)),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // UNIT
              _label('Kipimo / Kifungashio'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _showUnitSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedUnit == null
                          ? Colors.grey.shade200
                          : kNavyBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kNavyBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.straighten,
                            color: kNavyBlue, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedUnit ?? 'Chagua Kipimo / Kifungashio',
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedUnit == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),

              if (_selectedUnit == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Kipimo au Kifungashio kinahitajika',
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 20),

              // STOCK
              _label('Idadi ya Kuanzia (Stock)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: _inputDecoration('0'),
              ),

              const SizedBox(height: 20),

              // PRICES
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Bei Kununua'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _buyingPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _inputDecoration('0').copyWith(
                            suffixText: 'TZS',
                            helperText: 'Bei ya bidhaa moja',
                            helperStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                          onChanged: (v) {
                            final f = _formatCurrency(v);
                            if (f != v) {
                              _buyingPriceController.value =
                                  TextEditingValue(
                                text: f,
                                selection: TextSelection.collapsed(
                                    offset: f.length),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Bei Kuuza'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _sellingPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _inputDecoration('0').copyWith(
                            suffixText: 'TZS',
                            helperText: 'Bei ya bidhaa moja',
                            helperStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                          onChanged: (v) {
                            final f = _formatCurrency(v);
                            if (f != v) {
                              _sellingPriceController.value =
                                  TextEditingValue(
                                text: f,
                                selection: TextSelection.collapsed(
                                    offset: f.length),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ===== BARCODE SECTION =====
              // Barcode inaonyeshwa DAIMA — auto-generated, lakini user anaweza
              // kubadilisha kwa kuandika au kuscan barcode ya nje
              _label('Barcode ya Bidhaa'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kNavyBlue.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kNavyBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info badge — auto-generated
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 12,
                                  color: Color(0xFF22C55E)),
                              SizedBox(width: 4),
                              Text(
                                'Imetengenezwa Auto',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Scan button — kubadilisha na barcode ya nje
                        GestureDetector(
                          onTap: _openScanner,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kNavyBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.qr_code_scanner,
                                    size: 14, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Scan ya Nje',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Barcode value field
                    TextFormField(
                      controller: _barcodeController,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration('').copyWith(
                        prefixIcon: const Icon(
                            Icons.barcode_reader,
                            color: kNavyBlue,
                            size: 20),
                        helperText:
                            'Unaweza kubadilisha au uscan barcode ya nje',
                        helperStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Maelezo
                    Text(
                      '📌 Barcode hii itaprintwa na kuwekwa kwenye bidhaa kama price tag',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // EXPIRY DATE
              GestureDetector(
                onTap: _pickExpiryDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _expiryDate != null
                          ? kNavyBlue
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event,
                          color: _expiryDate != null
                              ? kNavyBlue
                              : Colors.grey,
                          size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _expiryDate != null
                            ? 'Tarehe ya Kuharibika: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                            : 'Tarehe ya Kuharibika (hiari)',
                        style: TextStyle(
                          color: _expiryDate != null
                              ? kNavyBlue
                              : Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      if (_expiryDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _expiryDate = null),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // MAELEZO
              GestureDetector(
                onTap: () =>
                    setState(() => _showDescription = !_showDescription),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showDescription
                          ? kNavyBlue
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showDescription
                            ? Icons.notes
                            : Icons.add_circle_outline,
                        color:
                            _showDescription ? kNavyBlue : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Maelezo ya Ziada (hiari)',
                        style: TextStyle(
                          color: _showDescription
                              ? kNavyBlue
                              : Colors.grey.shade600,
                          fontWeight: _showDescription
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _showDescription
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              if (_showDescription) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      _inputDecoration('Andika maelezo ya bidhaa...'),
                ),
              ],

              const SizedBox(height: 36),

              // HIFADHI
              SizedBox(
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
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Hifadhi Bidhaa',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _save(business),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BusinessState business) {
    if (_selectedUnit == null) {
      NotificationService.show(
        context: context,
        message: 'Tafadhali chagua kipimo cha bidhaa',
        type: NotificationType.error,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Tumia barcode iliyoandikwa/scanned — au auto-generated
    final barcodeId = _barcodeController.text.trim().isNotEmpty
        ? _barcodeController.text.trim()
        : _autoBarcodeId;

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedKundi,
      unit: _selectedUnit!,
      buyingPrice: int.tryParse(
              _buyingPriceController.text.replaceAll(',', '')) ??
          0,
      sellingPrice: int.tryParse(
              _sellingPriceController.text.replaceAll(',', '')) ??
          0,
      stock: int.tryParse(_stockController.text) ?? 0,
      imagePath: _imagePath,
      description: _descriptionController.text.trim(),
      expiryDate: _expiryDate,
      barcodeId: barcodeId, // ← barcode ya bidhaa
    );

    business.addProduct(product);

    NotificationService.show(
      context: context,
      message: 'Bidhaa mpya imehifadhiwa — barcode imetengenezwa',
      type: NotificationType.success,
    );

    Navigator.pop(context);
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kNavyBlue,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kNavyBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}