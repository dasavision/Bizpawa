import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/features/auth/onboarding_page.dart';
import 'package:bizpawa/features/auth/login_page.dart';
import 'package:bizpawa/widgets/bizpawa_logo.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class _BizCard {
  final String image;
  final String title;
  final String location;
  final Color accent;

  const _BizCard({
    required this.image,
    required this.title,
    required this.location,
    required this.accent,
  });
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _cardsCtrl;
  late AnimationController _bottomCtrl;

  late Animation<Offset> _card1;
  late Animation<Offset> _card2;
  late Animation<Offset> _card3;
  late Animation<Offset> _card4;
  late Animation<double> _cardsOpacity;
  late Animation<Offset> _bottomSlide;
  late Animation<double> _bottomOpacity;

  final List<_BizCard> _cards = const [
    _BizCard(image: 'assets/business1.png', title: 'Duka la Vifaa', location: 'Kigoma', accent: _kOrange),
    _BizCard(image: 'assets/business2.png', title: 'Pharmacy', location: 'Dar es Salaam', accent: Color(0xFF22C55E)),
    _BizCard(image: 'assets/business3.png', title: 'Fashion & Nguo', location: 'Mwanza', accent: Color(0xFFA78BFA)),
    _BizCard(image: 'assets/business4.png', title: 'Chakula & Bakery', location: 'Arusha', accent: Color(0xFFFB923C)),
  ];

  @override
  void initState() {
    super.initState();
    _cardsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bottomCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _card1 = Tween<Offset>(begin: const Offset(-1.0, -1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _card2 = Tween<Offset>(begin: const Offset(1.0, -1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic)));
    _card3 = Tween<Offset>(begin: const Offset(-1.0, 1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic)));
    _card4 = Tween<Offset>(begin: const Offset(1.0, 1.0), end: Offset.zero).animate(
        CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));
    _cardsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardsCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _bottomSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
        CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeOutCubic));
    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bottomCtrl, curve: Curves.easeIn));

    _cardsCtrl.forward().then((_) => _bottomCtrl.forward());
  }

  @override
  void dispose() {
    _cardsCtrl.dispose();
    _bottomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [_card1, _card2, _card3, _card4];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ===== TOP — picha grid =====
            Expanded(
              flex: 55,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: _kNavy)),
                  Positioned(top: -40, right: -40, child: Container(width: 200, height: 200,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _kOrange.withValues(alpha: 0.13)))),
                  Positioned(bottom: -30, left: -30, child: Container(width: 120, height: 120,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _kOrange.withValues(alpha: 0.08)))),
                  Positioned.fill(child: CustomPaint(painter: _WelcomeDotPainter())),

                  // Picha grid 2×2
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 40, 14, 14),
                    child: AnimatedBuilder(
                      animation: _cardsCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _cardsOpacity.value,
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(4, (i) => SlideTransition(
                            position: slides[i],
                            child: _BizCardWidget(card: _cards[i]),
                          )),
                        ),
                      ),
                    ),
                  ),

                  // Badge top center
                  Positioned(
                    top: 10, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kOrange.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✦  Trusted na Wafanyabiashara 1,000+',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _kNavy),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== BOTTOM — text + buttons =====
            Expanded(
              flex: 45,
              child: AnimatedBuilder(
                animation: _bottomCtrl,
                builder: (_, __) => SlideTransition(
                  position: _bottomSlide,
                  child: FadeTransition(
                    opacity: _bottomOpacity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Logo — icon + BIZPAWA text (navy mode)
                          BizPawaLogo(
                            fontSize: 18,
                            iconSize: 32,
                            letterSpacing: 2,
                            gap: 10,
                            lightMode: true,
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Karibu! 👋\nSimamia biashara yako kwa urahisi.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _kNavy,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Jiunge na maelfu ya wafanyabiashara Tanzania wanaosimamia biashara zao kwa BizPawa.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                          ),

                          const Spacer(),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kNavy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const OnboardingPage()),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Anza Safari Yako', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _kNavy,
                                side: BorderSide(color: _kNavy.withValues(alpha: 0.18)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                              ),
                              onPressed: () {
                                context.read<AuthState>().completeOnboarding();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              },
                              child: const Text('Nina Akaunti Tayari', style: TextStyle(fontSize: 14)),
                            ),
                          ),

                          const SizedBox(height: 6),
                        ],
                      ),
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

class _BizCardWidget extends StatelessWidget {
  final _BizCard card;
  const _BizCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            card.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _kNavy.withValues(alpha: 0.3),
              child: Center(child: Text(card.title[0],
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: card.accent))),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10, left: 10, right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(card.location, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Positioned(top: 8, right: 8, child: Container(width: 8, height: 8,
              decoration: BoxDecoration(color: card.accent, shape: BoxShape.circle))),
          Positioned.fill(child: Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
          ))),
        ],
      ),
    );
  }
}

class _WelcomeDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.04)..style = PaintingStyle.fill;
    const sp = 20.0;
    for (double x = 0; x < size.width; x += sp) {
      for (double y = 0; y < size.height; y += sp) {
        canvas.drawCircle(Offset(x, y), 1.0, p);
      }
    }
  }
  @override
  bool shouldRepaint(_) => false;
}