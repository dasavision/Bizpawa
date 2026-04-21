import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/core/app_shell.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class PinEntryPage extends StatefulWidget {
  final String? phone;       // Admin anapoingia kwa simu
  final String? username;    // Muuzaji anapoingia kwa username
  final bool isAdmin;

  const PinEntryPage({
    super.key,
    this.phone,
    this.username,
    required this.isAdmin,
  });

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage>
    with SingleTickerProviderStateMixin {
  final List<String> _pin = [];
  bool _hasError = false;
  String _errorMsg = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _hasError = false;
      _pin.add(digit);
    });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), _tryLogin);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _hasError = false;
      _pin.removeLast();
    });
  }

  void _tryLogin() {
    final auth = context.read<AuthState>();
    bool success = false;

    if (widget.isAdmin) {
      success = auth.loginAdmin(widget.phone!, _pin.join());
    } else {
      success = auth.loginSeller(widget.username!, _pin.join());
    }

    if (success) {
      // Check mustChangePinOnFirstLogin kwa seller
      if (!widget.isAdmin && auth.currentUser!.mustChangePinOnFirstLogin) {
        // TODO: Navigate to change PIN page
      }
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (route) => false,
      );
    } else {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _hasError = true;
        _errorMsg = widget.isAdmin
            ? 'PIN si sahihi. Jaribu tena.'
            : 'Username au PIN si sahihi.';
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isAdmin ? _kNavy : const Color(0xFF7C3AED);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // TOP
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _kNavy),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isAdmin
                            ? Icons.admin_panel_settings_outlined
                            : Icons.person_outlined,
                        color: color, size: 32,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      widget.isAdmin ? 'Ingiza PIN Yako' : 'Ingiza PIN Yako',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kNavy),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.isAdmin
                          ? '+255 ${widget.phone}'
                          : '@${widget.username}',
                      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 36),

                    // PIN dots — with shake animation
                    AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(_hasError ? 8 * (0.5 - (_shakeAnim.value % 0.5)) * 4 : 0, 0),
                        child: child,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final filled = i < _pin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: filled ? 18 : 16,
                            height: filled ? 18 : 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _hasError
                                  ? Colors.red
                                  : filled ? color : Colors.transparent,
                              border: Border.all(
                                color: _hasError
                                    ? Colors.red
                                    : filled ? color : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Error
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _hasError ? 44 : 0,
                      child: _hasError
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(
                                _errorMsg,
                                style: const TextStyle(color: Colors.red, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : null,
                    ),

                    const Spacer(),

                    // Keypad
                    _Keypad(onKey: _onKey, onDelete: _onDelete, color: color),

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

// ===== KEYPAD =====
class _Keypad extends StatelessWidget {
  final void Function(String) onKey;
  final VoidCallback onDelete;
  final Color color;

  const _Keypad({required this.onKey, required this.onDelete, required this.color});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 72, height: 72);
            return GestureDetector(
              onTap: () => key == 'del' ? onDelete() : onKey(key),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: key == 'del' ? Colors.transparent : Colors.grey.shade50,
                  shape: BoxShape.circle,
                  border: key == 'del' ? null : Border.all(
                      color: Colors.grey.shade200, width: 0.5),
                ),
                child: Center(
                  child: key == 'del'
                      ? Icon(Icons.backspace_outlined, color: Colors.grey.shade600, size: 22)
                      : Text(key, style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w500, color: _kNavy)),
                ),
              ),
            );
          }).toList(),
        ),
      )).toList(),
    );
  }
}