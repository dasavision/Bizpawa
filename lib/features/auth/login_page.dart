import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/widgets/bizpawa_logo.dart';
import 'register_page.dart';
import 'pin_entry_page.dart';

const _kNavy = Color(0xFF1B2E6B);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // 0 = chaguo (Admin/Muuzaji), 1 = Admin login, 2 = Muuzaji login
  int _step = 0;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    _animCtrl.forward(from: 0);
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // TOP — logo + back button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _kNavy),
                      onPressed: () => _goTo(0),
                    )
                  else
                    const SizedBox(width: 12),
                  BizPawaLogo(
                    fontSize: 16,
                    iconSize: 30,
                    letterSpacing: 2,
                    gap: 8,
                    lightMode: true,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: _step == 0
                      ? _ChoiceScreen(
                          isRegistered: auth.isRegistered,
                          onAdmin: () => _goTo(1),
                          onSeller: () => _goTo(2),
                          onRegister: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RegisterPage())),
                        )
                      : _step == 1
                          ? _AdminLoginScreen(onBack: () => _goTo(0))
                          : _SellerLoginScreen(onBack: () => _goTo(0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CHOICE SCREEN =====
class _ChoiceScreen extends StatelessWidget {
  final bool isRegistered;
  final VoidCallback onAdmin;
  final VoidCallback onSeller;
  final VoidCallback onRegister;

  const _ChoiceScreen({
    required this.isRegistered,
    required this.onAdmin,
    required this.onSeller,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Karibu Tena! 👋',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _kNavy),
          ),
          const SizedBox(height: 6),
          Text(
            'Unaingia kama nani leo?',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 40),

          // Admin card
          _RoleCard(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin / Mmiliki',
            desc: 'Simamia biashara yako yote kwa udhibiti kamili',
            color: _kNavy,
            onTap: onAdmin,
          ),

          const SizedBox(height: 14),

          // Muuzaji card
          _RoleCard(
            icon: Icons.person_outlined,
            title: 'Muuzaji',
            desc: 'Ingia kwa username na PIN uliyopewa na Admin',
            color: const Color(0xFF7C3AED),
            onTap: onSeller,
          ),

          const Spacer(),

          if (!isRegistered) ...[
            Center(
              child: Column(
                children: [
                  Text('Bado huna akaunti?',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onRegister,
                    child: const Text(
                      'Sajili Biashara Yako',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _kNavy,
                        decoration: TextDecoration.underline,
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
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon, required this.title, required this.desc,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15,
                      fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 3),
                  Text(desc, style: TextStyle(fontSize: 12,
                      color: Colors.grey.shade500, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}

// ===== ADMIN LOGIN — simu + PIN =====
class _AdminLoginScreen extends StatefulWidget {
  final VoidCallback onBack;
  const _AdminLoginScreen({required this.onBack});

  @override
  State<_AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<_AdminLoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _phoneEntered = false;
  String _error = '';

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: _kNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.admin_panel_settings_outlined, color: _kNavy, size: 24)),
          const SizedBox(height: 14),
          const Text('Ingia kama Admin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kNavy)),
          const SizedBox(height: 6),
          Text('Ingiza namba yako ya simu',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),

          const SizedBox(height: 32),

          // Phone field
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => setState(() { _phoneEntered = v.length >= 9; _error = ''; }),
            decoration: InputDecoration(
              hintText: '712 345 678',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixText: '+255 ',
              prefixStyle: const TextStyle(color: _kNavy, fontWeight: FontWeight.w600),
              prefixIcon: const Icon(Icons.phone_outlined, color: _kNavy, size: 20),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kNavy, width: 1.5)),
            ),
          ),

          if (_error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 14),
                const SizedBox(width: 6),
                Text(_error, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ]),
            ),
          ],

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _phoneEntered ? _kNavy : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _phoneEntered ? _goToPinEntry : null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Endelea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPinEntry() {
    final auth = context.read<AuthState>();
    // Check phone exists
    final phone = _phoneCtrl.text.trim();
    final admin = auth.adminUser;
    if (admin == null) {
      setState(() => _error = 'Hakuna akaunti iliyosajiliwa');
      return;
    }
    // Navigate to PIN entry
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PinEntryPage(
        phone: phone,
        isAdmin: true,
      ),
    ));
  }
}

// ===== SELLER LOGIN — username + PIN =====
class _SellerLoginScreen extends StatefulWidget {
  final VoidCallback onBack;
  const _SellerLoginScreen({required this.onBack});

  @override
  State<_SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends State<_SellerLoginScreen> {
  final _usernameCtrl = TextEditingController();
  bool _usernameEntered = false;

  @override
  void dispose() { _usernameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_outlined, color: Color(0xFF7C3AED), size: 24)),
          const SizedBox(height: 14),
          const Text('Ingia kama Muuzaji',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kNavy)),
          const SizedBox(height: 6),
          Text('Ingiza username uliyopewa na Admin',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),

          const SizedBox(height: 32),

          TextField(
            controller: _usernameCtrl,
            onChanged: (v) => setState(() => _usernameEntered = v.trim().length >= 3),
            decoration: InputDecoration(
              hintText: 'Mf. amina.hassan',
              prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF7C3AED), size: 20),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _usernameEntered ? const Color(0xFF7C3AED) : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _usernameEntered
                  ? () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PinEntryPage(
                          username: _usernameCtrl.text.trim(),
                          isAdmin: false,
                        ),
                      ))
                  : null,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Endelea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}