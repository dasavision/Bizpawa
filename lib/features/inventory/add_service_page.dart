import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/services/notification_service.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/models/product.dart';

const kNavyBlue = Color(0xFF1B2E6B);
const kOrange = Color(0xFFF5A623);

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imagePath;
  bool _showDescription = false;
  String _selectedKundi = 'General';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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

  String _formatCurrency(String value) {
    final clean = value.replaceAll(',', '');
    final number = int.tryParse(clean);
    if (number == null) return value;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
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
                color: kNavyBlue,
              ),
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
                    color: const Color(0xFF6366F1)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_outlined,
                      color: Color(0xFF6366F1), size: 18),
                ),
                title: Text(
                  kundi,
                  style: TextStyle(
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
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

  void _createKundiDialog(BusinessState business) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Tengeneza Kundi Jipya',
          style: TextStyle(
              color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Mf. Ushauri, Ujenzi...',
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
          'Ongeza Huduma',
          style: TextStyle(
              color: kNavyBlue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// IMAGE
              Center(
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: kOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kOrange.withValues(alpha: 0.3),
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
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: kOrange, size: 32),
                              const SizedBox(height: 6),
                              Text(
                                'Picha',
                                style: TextStyle(
                                    fontSize: 12, color: kOrange),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _imagePath = null),
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

              /// JINA
              _label('Jina la Huduma'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                    'Mf. Ujenzi, Usafi, Ushauri...'),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Jina linahitajika'
                        : null,
              ),

              const SizedBox(height: 20),

              /// KUNDI
              _label('Kundi la Huduma'),
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
                    border: Border.all(
                        color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.folder_outlined,
                            color: Color(0xFF6366F1), size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedKundi,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// BEI
              _label('Bei ya Huduma'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: _inputDecoration('0').copyWith(
                  suffixText: 'TZS',
                ),
                onChanged: (v) {
                  final f = _formatCurrency(v);
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

              /// MAELEZO
              GestureDetector(
                onTap: () => setState(() =>
                    _showDescription = !_showDescription),
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
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: _inputDecoration(
                      'Andika maelezo ya huduma hii...'),
                ),
              ],

              const SizedBox(height: 36),

              /// HIFADHI
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
                    'Hifadhi Huduma',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
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

    final cleanPrice =
        _priceController.text.replaceAll(',', '');

    final service = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedKundi,
      unit: 'SERVICE',
      buyingPrice: 0,
      sellingPrice: int.tryParse(cleanPrice) ?? 0,
      stock: 0,
      imagePath: _imagePath,
      description: _descriptionController.text.trim(),
    );

    business.addService(service);

    NotificationService.show(
      context: context,
      message: 'Huduma mpya imehifadhiwa',
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