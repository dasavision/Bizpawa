import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/features/auth/welcome_page.dart';
import 'package:bizpawa/features/auth/login_page.dart';
import 'package:bizpawa/core/app_shell.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _dotsCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotate;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _logoRotate = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    // Subiri minimum time + animations zimalize
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2800)),
      _logoCtrl.forward(),
    ]);

    // Hakikisha widget bado ipo
    if (!mounted) return;

    final auth = context.read<AuthState>();
    Widget next;

    if (auth.isLoggedIn) {
      next = const AppShell();
    } else if (auth.isRegistered) {
      next = const LoginPage();
    } else if (!auth.hasSeenOnboarding) {
      next = const WelcomePage();
    } else {
      next = const LoginPage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND =====
          Container(color: _kNavy),

          // Orange diagonal block — top right
          Positioned(
            top: -size.height * 0.06,
            right: -size.width * 0.08,
            child: Container(
              width: size.width * 0.78,
              height: size.height * 0.44,
              decoration: const BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(90),
                ),
              ),
            ),
          ),

          // Navy circle overlap on orange
          Positioned(
            top: size.height * 0.08,
            right: -size.width * 0.12,
            child: Container(
              width: size.width * 0.48,
              height: size.width * 0.48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kNavy.withValues(alpha: 0.55),
              ),
            ),
          ),

          // Orange accent bottom left
          Positioned(
            bottom: -size.width * 0.18,
            left: -size.width * 0.12,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kOrange.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Small orange circle mid left
          Positioned(
            top: size.height * 0.38,
            left: size.width * 0.06,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kOrange.withValues(alpha: 0.18),
              ),
            ),
          ),

          // Dot grid
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),

          // Diagonal accents
          Positioned.fill(
            child: CustomPaint(painter: _DiagonalPainter()),
          ),

          // ===== CENTER CONTENT =====
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo — animating
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotate.value,
                        child: Image.asset(
                          'assets/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // BIZPAWA text + tagline
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'BIZ',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'PAWA',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: _kOrange,
                                    letterSpacing: 3,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _taglineOpacity,
                            child: Text(
                              'Smarter Control, Stronger Growth',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.55),
                                letterSpacing: 0.5,
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

          // ===== LOADING DOTS bottom =====
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, __) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final t =
                      ((_dotsCtrl.value - i * 0.22) % 1.0).clamp(0.0, 1.0);
                  final active = t > 0.0 && t < 0.45;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? _kOrange
                          : Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.62)
        ..lineTo(size.width * 0.38, size.height * 0.28)
        ..lineTo(size.width * 0.43, size.height * 0.28)
        ..lineTo(size.width * 0.05, size.height * 0.62)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.025),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.58, 0)
        ..lineTo(size.width, size.height * 0.33)
        ..lineTo(size.width, size.height * 0.28)
        ..lineTo(size.width * 0.63, 0)
        ..close(),
      Paint()..color = _kOrange.withValues(alpha: 0.05),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}