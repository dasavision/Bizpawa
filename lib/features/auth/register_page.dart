import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'business_type_page.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bizNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bizNameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ===== TOP BAR =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _kNavy),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Step indicator
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == 0 ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == 0 ? _kNavy : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Header
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _kNavy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_outline, color: _kNavy, size: 24),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Sajili Biashara Yako',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _kNavy),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hatua 1 ya 3 — Taarifa za Msingi',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),

                      const SizedBox(height: 32),

                      // Jina la Admin
                      _label('Jina Lako Kamili'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec('Mf. Amina Hassan', Icons.person_outline),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Jina linahitajika' : null,
                      ),

                      const SizedBox(height: 18),

                      // Namba ya Simu
                      _label('Namba ya Simu'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _dec('712 345 678', Icons.phone_outlined).copyWith(
                          prefixText: '+255 ',
                          prefixStyle: const TextStyle(
                            color: _kNavy,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Simu inahitajika';
                          if (v.trim().length < 9) return 'Namba si sahihi';
                          return null;
                        },
                      ),

                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kNavy.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: _kNavy.withValues(alpha: 0.6)),
                            const SizedBox(width: 6),
                            Text(
                              'Namba hii itatumika kuingia kwenye app',
                              style: TextStyle(fontSize: 11, color: _kNavy.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Jina la Biashara
                      _label('Jina la Biashara'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bizNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: _dec('Mf. Duka la Amani', Icons.store_outlined),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Jina la biashara linahitajika'
                            : null,
                      ),

                      const SizedBox(height: 18),

                      // Anuani ya Biashara
                      _label('Anuani ya Biashara'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                        decoration: _dec('Mf. Kigoma Mjini, Mitaa ya Mwanga', Icons.location_on_outlined).copyWith(
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Anuani inahitajika'
                            : null,
                      ),

                      const SizedBox(height: 6),
                      Text(
                        'Unaweza kubadilisha anuani baadaye kwenye mipangilio',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                      ),

                      const SizedBox(height: 36),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _onNext,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Endelea',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
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
    );
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessTypePage(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          bizName: _bizNameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kNavy),
      );

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
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
          borderSide: const BorderSide(color: _kNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}