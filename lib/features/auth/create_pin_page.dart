import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/app_shell.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class CreatePinPage extends StatefulWidget {
  final String name;
  final String phone;
  final String bizName;
  final String address;
  final String bizType;

  const CreatePinPage({
    super.key,
    required this.name,
    required this.phone,
    required this.bizName,
    required this.address,
    required this.bizType,
  });

  @override
  State<CreatePinPage> createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _confirming = false;
  bool _hasError = false;
  String _errorMsg = '';

  void _onKey(String digit) {
    setState(() {
      _hasError = false;
      if (!_confirming) {
        if (_pin.length < 4) {
          _pin.add(digit);
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() => _confirming = true);
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin.add(digit);
          if (_confirmPin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _validateAndSave();
            });
          }
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      _hasError = false;
      if (_confirming) {
        if (_confirmPin.isNotEmpty) _confirmPin.removeLast();
      } else {
        if (_pin.isNotEmpty) _pin.removeLast();
      }
    });
  }

  void _validateAndSave() {
    if (_pin.join() != _confirmPin.join()) {
      setState(() {
        _hasError = true;
        _errorMsg = 'PIN hazilingani — jaribu tena';
        _confirmPin.clear();
      });
      return;
    }

    final auth = context.read<AuthState>();
    final business = context.read<BusinessState>();

    // Sajili admin
    auth.registerAdmin(
      name: widget.name,
      phone: widget.phone,
      pin: _pin.join(),
    );

    // Weka taarifa za biashara (jina + simu + anuani)
    business.updateBusinessProfile(
      name: widget.bizName,
      phone: '+255${widget.phone}',
      address: widget.address,
    );

    // Hifadhi aina ya biashara
    business.updateBizType(widget.bizType);

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _confirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _kNavy),
                    onPressed: () {
                      if (_confirming) {
                        setState(() {
                          _confirming = false;
                          _confirmPin.clear();
                          _hasError = false;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  // Step indicator
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 24,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _kNavy,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _confirming
                            ? _kOrange.withValues(alpha: 0.12)
                            : _kNavy.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _confirming ? Icons.lock_outline : Icons.lock_open_outlined,
                        color: _confirming ? _kOrange : _kNavy,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _confirming ? 'Thibitisha PIN Yako' : 'Tengeneza PIN Yako',
                        key: ValueKey(_confirming),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _kNavy,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _confirming
                            ? 'Ingiza tena PIN uliyotengeneza'
                            : 'Hatua 3 ya 3 — PIN ya namba 4 itakayolinda akaunti yako',
                        key: ValueKey('sub$_confirming'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // PIN dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final filled = i < currentPin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: filled ? 18 : 16,
                          height: filled ? 18 : 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? (_confirming ? _kOrange : _kNavy)
                                : Colors.transparent,
                            border: Border.all(
                              color: filled
                                  ? (_confirming ? _kOrange : _kNavy)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Error message
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _hasError ? 40 : 0,
                      child: _hasError
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.red, size: 14),
                                    const SizedBox(width: 6),
                                    Text(_errorMsg,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 12)),
                                  ],
                                ),
                              ),
                            )
                          : null,
                    ),

                    const Spacer(),

                    // Keypad
                    _Keypad(onKey: _onKey, onDelete: _onDelete),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== KEYPAD WIDGET =====
class _Keypad extends StatelessWidget {
  final void Function(String) onKey;
  final VoidCallback onDelete;

  const _Keypad({required this.onKey, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72, height: 72);
              return _KeyButton(
                label: key,
                onTap: () => key == 'del' ? onDelete() : onKey(key),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDel = label == 'del';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDel ? Colors.transparent : Colors.grey.shade50,
          shape: BoxShape.circle,
          border: isDel ? null : Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Center(
          child: isDel
              ? Icon(Icons.backspace_outlined, color: Colors.grey.shade600, size: 22)
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: _kNavy,
                  ),
                ),
        ),
      ),
    );
  }
}