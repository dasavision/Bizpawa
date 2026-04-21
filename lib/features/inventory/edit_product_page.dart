import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/models/product.dart';
import 'package:bizpawa/core/state/business_state.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;

  late String _selectedKundi;
  late String _selectedUnit;
  String? _imagePath;
  bool _showDescription = false;
  DateTime? _expiryDate;

  bool get _isService => widget.product.unit == 'SERVICE';

  static const List<String> _units = [
    'PCS', 'KG', 'BOX', 'LTR',
    'Piece', 'Pack', 'Packet', 'Bottle',
    'Can', 'Bag', 'Jar', 'Tube',
    'Roll', 'Bundle', 'Set', 'Dozen', 'Tray',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: _fmt(widget.product.sellingPrice.toString()),
    );
    _buyingPriceController = TextEditingController(
      text: _fmt(widget.product.buyingPrice.toString()),
    );
    _sellingPriceController = TextEditingController(
      text: _fmt(widget.product.sellingPrice.toString()),
    );
    _stockController = TextEditingController();
    _descriptionController =
        TextEditingController(text: widget.product.description ?? '');

    _imagePath = widget.product.imagePath;
    _selectedKundi = widget.product.category;
    _expiryDate = widget.product.expiryDate;

    _selectedUnit = _isService
        ? 'SERVICE'
        : (_units.contains(widget.product.unit)
            ? widget.product.unit
            : 'PCS');

    if (widget.product.description?.isNotEmpty ?? false) {
      _showDescription = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: _expiryDate ?? DateTime.now(),
    );
    if (date != null) setState(() => _expiryDate = date);
  }

  String _fmt(String value) {
    final clean = value.replaceAll(',', '');
    final number = int.tryParse(clean);
    if (number == null) return value;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _createKundiDialog(BusinessState business) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tengeneza Kundi Jipya',
            style: TextStyle(
                color: kNavyBlue, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Mf. Nafaka, Vinywaji...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
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

  void _delete(BusinessState business) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Futa ${_isService ? 'Huduma' : 'Bidhaa'}',
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
            'Una uhakika unataka kufuta "${widget.product.name}"?'),
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
              final name = widget.product.name;
              business.deleteProductById(widget.product.id);
              Navigator.pop(context);
              Navigator.pop(context);
              NotificationService.show(
                context: context,
                message: _isService
                    ? 'Huduma "$name" imefutwa'
                    : 'Bidhaa "$name" imefutwa',
                type: NotificationType.error,
              );
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessState>();

    final makundi = [
      'General',
      ...business.categories.where((k) => k != 'General'),
    ];

    if (!makundi.contains(_selectedKundi)) {
      _selectedKundi = 'General';
    }

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
          _isService ? 'Hariri Huduma' : 'Hariri Bidhaa',
          style: const TextStyle(
              color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _delete(business),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ===== IMAGE =====
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
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
                                      fontSize: 12,
                                      color: kNavyBlue)),
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

              const SizedBox(height: 20),

              // ===== BARCODE — read only, inaonyesha tu =====
              // FIX: Barcode inaonyeshwa lakini haibadiliki ukiedit
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.barcode_reader,
                        color: Colors.grey.shade400, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barcode ya Bidhaa',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            widget.product.barcodeId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: kNavyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lock — barcode haibadiliki
                    Tooltip(
                      message: 'Barcode haibadiliki baada ya kusajili',
                      child: Icon(Icons.lock_outline,
                          size: 14, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== JINA =====
              _label(_isService ? 'Jina la Huduma' : 'Jina la Bidhaa'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDec(''),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Jina linahitajika'
                    : null,
              ),

              const SizedBox(height: 20),

              // ===== KUNDI =====
              _label('Kundi la Bidhaa'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedKundi,
                decoration: _inputDec(''),
                items: makundi
                    .map((k) => DropdownMenuItem(
                        value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedKundi = v);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kNavyBlue,
                  side: BorderSide(
                      color: kNavyBlue.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tengeneza Kundi Jipya'),
                onPressed: () => _createKundiDialog(business),
              ),

              const SizedBox(height: 20),

              // ===== BIDHAA FIELDS =====
              if (!_isService) ...[
                _label('Unit / Packaging'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: _inputDec(''),
                  items: _units
                      .map((u) => DropdownMenuItem(
                          value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedUnit = v);
                  },
                ),

                const SizedBox(height: 20),

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
                            decoration: _inputDec('0')
                                .copyWith(suffixText: 'TZS'),
                            onChanged: (v) {
                              final f = _fmt(v);
                              if (f != v) {
                                _buyingPriceController.value =
                                    TextEditingValue(
                                  text: f,
                                  selection:
                                      TextSelection.collapsed(
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
                            decoration: _inputDec('0')
                                .copyWith(suffixText: 'TZS'),
                            onChanged: (v) {
                              final f = _fmt(v);
                              if (f != v) {
                                _sellingPriceController.value =
                                    TextEditingValue(
                                  text: f,
                                  selection:
                                      TextSelection.collapsed(
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

                _label('Ongeza Stock'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: _inputDec('0').copyWith(
                    helperText:
                        'Stock ya sasa: ${widget.product.stock} ${widget.product.unit}',
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _pickExpiryDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey.shade200),
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
                              ? 'Expire: ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
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
                            onTap: () =>
                                setState(() => _expiryDate = null),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              // ===== HUDUMA — BEI TU =====
              if (_isService) ...[
                _label('Bei ya Huduma'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration:
                      _inputDec('0').copyWith(suffixText: 'TZS'),
                  onChanged: (v) {
                    final f = _fmt(v);
                    if (f != v) {
                      _priceController.value = TextEditingValue(
                        text: f,
                        selection: TextSelection.collapsed(
                            offset: f.length),
                      );
                    }
                  },
                  validator: (v) {
                    final clean = v?.replaceAll(',', '') ?? '';
                    if (clean.isEmpty) return 'Bei inahitajika';
                    if (int.tryParse(clean) == null) {
                      return 'Weka namba sahihi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // ===== MAELEZO =====
              GestureDetector(
                onTap: () => setState(
                    () => _showDescription = !_showDescription),
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
                        color: _showDescription
                            ? kNavyBlue
                            : Colors.grey,
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
                      _inputDec('Andika maelezo ya ziada...'),
                ),
              ],

              const SizedBox(height: 36),

              // ===== HIFADHI =====
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
                    'Hifadhi Mabadiliko',
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
    if (!_formKey.currentState!.validate()) return;

    final addedStock = int.tryParse(_stockController.text) ?? 0;

    int sellingPrice;
    int buyingPrice;

    if (_isService) {
      sellingPrice = int.tryParse(
              _priceController.text.replaceAll(',', '')) ??
          0;
      buyingPrice = 0;
    } else {
      sellingPrice = int.tryParse(
              _sellingPriceController.text.replaceAll(',', '')) ??
          0;
      buyingPrice = int.tryParse(
              _buyingPriceController.text.replaceAll(',', '')) ??
          0;
    }

    final updated = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      category: _selectedKundi,
      unit: _isService ? 'SERVICE' : _selectedUnit,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      stock: _isService
          ? 0
          : widget.product.stock + addedStock,
      imagePath: _imagePath,
      description: _descriptionController.text.trim(),
      expiryDate: _isService ? null : _expiryDate,
      batches: widget.product.batches, // ← preserve batches
      barcodeId: widget.product.barcodeId, // ← FIX: barcode inahifadhiwa
    );

    business.updateProduct(updated);

    NotificationService.show(
      context: context,
      message: 'Mabadiliko yamehifadhiwa',
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

  InputDecoration _inputDec(String hint) {
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