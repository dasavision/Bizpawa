import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/auth_state.dart';
import 'package:bizpawa/features/auth/login_page.dart';
import 'package:bizpawa/features/auth/register_page.dart';
import 'package:bizpawa/widgets/bizpawa_logo.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kOrange = Color(0xFFF5A623);

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _current = 0;

  late AnimationController _slideCtrl;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _contentOpacity;
  late Animation<double> _illoScale;

  final List<_OnboardSlide> _slides = const [
    _OnboardSlide(
      bgColor: Color(0xFF1B2E6B),
      accentColor: Color(0xFFF5A623),
      title: 'Simamia\nBiashara Yako',
      subtitle: 'Fuatilia mauzo, stock, na faida yako kwa urahisi kutoka simu moja.',
      chips: ['📦 Stock', '💰 Mauzo', '📈 Faida'],
      illoType: _IlloType.dashboard,
    ),
    _OnboardSlide(
      bgColor: Color(0xFF16A34A),
      accentColor: Color(0xFFF5A623),
      title: 'Rekodi\nTaarifa Zote',
      subtitle: 'Risiti za PDF, rekodi za madeni, na historia ya mauzo — yote mahali pamoja.',
      chips: ['🧾 Risiti', '💳 Madeni', '📋 Historia'],
      illoType: _IlloType.records,
    ),
    _OnboardSlide(
      bgColor: Color(0xFF7C3AED),
      accentColor: Color(0xFFF5A623),
      title: 'Simamia\nTimu Yako',
      subtitle: 'Weka ruhusa tofauti kwa kila muuzaji. Admin anasimamia yote kwa usalama.',
      chips: ['👤 Wauzaji', '🔐 Ruhusa', '📊 Ripoti'],
      illoType: _IlloType.team,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _playEntry();
  }

  void _initAnimations() {
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _illoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic)));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideCtrl, curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)));
  }

  void _playEntry() => _slideCtrl.forward(from: 0.0);

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_current < _slides.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<AuthState>().completeOnboarding();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  void _skip() {
    context.read<AuthState>().completeOnboarding();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) { setState(() => _current = i); _playEntry(); },
            itemCount: _slides.length,
            itemBuilder: (_, i) => _SlideBackground(slide: _slides[i]),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [

                // ===== TOP BAR — BizPawaLogo.small + skip =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      // Logo icon + BIZPAWA (white + orange) kwenye dark bg
                      BizPawaLogo(
                        fontSize: 13,
                        iconSize: 28,
                        letterSpacing: 2,
                        gap: 8,
                        lightMode: false,
                      ),
                      const Spacer(),
                      if (_current < _slides.length - 1)
                        GestureDetector(
                          onTap: _skip,
                          child: Text('Ruka →',
                              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                        ),
                    ],
                  ),
                ),

                // Illustration
                Expanded(
                  flex: 5,
                  child: AnimatedBuilder(
                    animation: _slideCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _illoScale.value,
                      child: Opacity(
                        opacity: _contentOpacity.value,
                        child: _IllustrationWidget(
                          type: _slides[_current].illoType,
                          accentColor: _slides[_current].accentColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // Text + dots + button
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                          animation: _slideCtrl,
                          builder: (_, __) => SlideTransition(
                            position: _titleSlide,
                            child: FadeTransition(
                              opacity: _contentOpacity,
                              child: Text(_slides[_current].title,
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                                      color: Colors.white, height: 1.2)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        AnimatedBuilder(
                          animation: _slideCtrl,
                          builder: (_, __) => SlideTransition(
                            position: _subtitleSlide,
                            child: FadeTransition(
                              opacity: _contentOpacity,
                              child: Text(_slides[_current].subtitle,
                                  style: TextStyle(fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.65), height: 1.5)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        AnimatedBuilder(
                          animation: _slideCtrl,
                          builder: (_, __) => FadeTransition(
                            opacity: _contentOpacity,
                            child: Row(
                              children: _slides[_current].chips.map((chip) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                                ),
                                child: Text(chip,
                                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                              )).toList(),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            Row(
                              children: List.generate(_slides.length, (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: _current == i ? 24 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _current == i ? _kOrange : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              )),
                            ),
                            const Spacer(),
                            _current == _slides.length - 1
                                ? _FinishButtons(
                                    onBack: () => _pageCtrl.previousPage(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOutCubic),
                                    onFinish: _finish,
                                  )
                                : GestureDetector(
                                    onTap: _goNext,
                                    child: Container(
                                      width: 56, height: 56,
                                      decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
                                      child: const Icon(Icons.arrow_forward_rounded, color: _kNavy, size: 22),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideBackground extends StatelessWidget {
  final _OnboardSlide slide;
  const _SlideBackground({required this.slide});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: slide.bgColor,
      child: Stack(
        children: [
          Positioned(top: -80, right: -60, child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle, color: slide.accentColor.withValues(alpha: 0.08)))),
          Positioned(bottom: -50, left: -40, child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)))),
          Positioned(top: 200, left: 20, child: Container(width: 60, height: 60,
              decoration: BoxDecoration(shape: BoxShape.circle, color: slide.accentColor.withValues(alpha: 0.1)))),
          Positioned.fill(child: CustomPaint(painter: _ObDotPainter())),
          Positioned.fill(child: CustomPaint(painter: _ObDiagonalPainter(accent: slide.accentColor))),
        ],
      ),
    );
  }
}

class _IllustrationWidget extends StatefulWidget {
  final _IlloType type;
  final Color accentColor;
  const _IllustrationWidget({required this.type, required this.accentColor});

  @override
  State<_IllustrationWidget> createState() => _IllustrationWidgetState();
}

class _IllustrationWidgetState extends State<_IllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _float = Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _float.value),
        child: Center(
          child: SizedBox(
            width: 240, height: 240,
            child: CustomPaint(painter: _IlloPainter(type: widget.type, accent: widget.accentColor)),
          ),
        ),
      ),
    );
  }
}

enum _IlloType { dashboard, records, team }

class _IlloPainter extends CustomPainter {
  final _IlloType type;
  final Color accent;
  _IlloPainter({required this.type, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _IlloType.dashboard: _drawDashboard(canvas, size);
      case _IlloType.records: _drawRecords(canvas, size);
      case _IlloType.team: _drawTeam(canvas, size);
    }
  }

  void _drawDashboard(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    _drawCard(canvas, Rect.fromLTWH(w*.08, h*.15, w*.84, h*.55), radius: 16);
    _txt(canvas, 'Mauzo ya Leo', Offset(w*.16, h*.25), fontSize: 11, opacity: 0.5);
    _txtB(canvas, '1,250,000', Offset(w*.16, h*.37), fontSize: 20, color: accent);
    _txt(canvas, 'TZS', Offset(w*.16, h*.43), fontSize: 9, opacity: 0.35);
    final bars = [0.35, 0.5, 0.7, 0.9, 0.65, 0.45];
    for (int i = 0; i < bars.length; i++) {
      final bH = h*.18 * bars[i]; final bX = w*.16 + i * (w*.08 + 4);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bX, h*.63-bH, w*.08, bH), const Radius.circular(3)),
          Paint()..color = i==3 ? accent : Colors.white.withValues(alpha: .18+bars[i]*.3));
    }
    canvas.drawLine(Offset(w*.72, h*.58), Offset(w*.84, h*.46),
        Paint()..color = const Color(0xFF22C55E)..strokeWidth = 1.5..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(w*.84, h*.46), 4, Paint()..color = const Color(0xFF22C55E));
    _drawSmallCard(canvas, Rect.fromLTWH(w*.64, h*.04, w*.33, h*.12), radius: 10);
    _txtB(canvas, '↑ 24%', Offset(w*.7, h*.09), fontSize: 10, color: accent);
    _txt(canvas, 'kuliko jana', Offset(w*.7, h*.14), fontSize: 8, opacity: 0.4);
    _drawSmallCardGreen(canvas, Rect.fromLTWH(w*.05, h*.74, w*.33, h*.1), radius: 8);
    _txt(canvas, 'Stock ✓ OK', Offset(w*.1, h*.805), fontSize: 9, color: const Color(0xFF22C55E));
  }

  void _drawRecords(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    _drawCardOpacity(canvas, Rect.fromLTWH(w*.15, h*.08, w*.72, h*.72), radius: 12, opacity: 0.05, rotate: -0.06);
    _drawCardOpacity(canvas, Rect.fromLTWH(w*.12, h*.07, w*.72, h*.72), radius: 12, opacity: 0.08, rotate: 0.03);
    _drawCard(canvas, Rect.fromLTWH(w*.1, h*.06, w*.72, h*.72), radius: 12);
    _drawRoundRect(canvas, Rect.fromLTWH(w*.2, h*.14, w*.52, h*.05), radius: 4, opacity: 0.3);
    canvas.drawLine(Offset(w*.18, h*.23), Offset(w*.74, h*.23),
        Paint()..color = Colors.white.withValues(alpha: .1)..strokeWidth = 1);
    for (int i = 0; i < 3; i++) {
      final y = h*(.27+i*.1);
      _drawRoundRect(canvas, Rect.fromLTWH(w*.18, y, w*.28, h*.04), radius: 3, opacity: 0.2);
      _drawRoundRect(canvas, Rect.fromLTWH(w*.56, y, w*.18, h*.04), radius: 3, color: accent.withValues(alpha:.6));
    }
    canvas.drawLine(Offset(w*.18, h*.58), Offset(w*.74, h*.58),
        Paint()..color = Colors.white.withValues(alpha: .1)..strokeWidth = 1);
    _drawBadgeGreen(canvas, Rect.fromLTWH(w*.26, h*.61, w*.38, h*.08), radius: 10);
    _txt(canvas, 'IMELIPWA ✓', Offset(w*.33, h*.655), fontSize: 10, color: const Color(0xFF22C55E));
    _drawCardOpacity(canvas, Rect.fromLTWH(w*.18, h*.7, w*.56, h*.06), radius: 4, opacity: 0.06);
    _txt(canvas, 'PDF · QR · WhatsApp', Offset(w*.24, h*.74), fontSize: 8, opacity: 0.35);
    _drawSmallCardRed(canvas, Rect.fromLTWH(w*.66, h*.04, w*.32, h*.12), radius: 8);
    _txt(canvas, '2 Madeni', Offset(w*.7, h*.085), fontSize: 8, color: const Color(0xFFFCA5A5));
  }

  void _drawTeam(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawCircle(Offset(w*.5, h*.33), w*.16, Paint()..color = accent.withValues(alpha:.13));
    canvas.drawCircle(Offset(w*.5, h*.33), w*.16,
        Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(w*.5, h*.26), w*.07, Paint()..color = accent.withValues(alpha:.7));
    _txtB(canvas, 'ADMIN', Offset(w*.375, h*.405), fontSize: 9, color: accent);
    _drawSellerCircle(canvas, Offset(w*.18, h*.27), w*.12, 'Amina');
    _drawSellerCircle(canvas, Offset(w*.82, h*.27), w*.12, 'Hassan');
    _drawDashedLine(canvas, Offset(w*.3, h*.29), Offset(w*.38, h*.33));
    _drawDashedLine(canvas, Offset(w*.7, h*.29), Offset(w*.62, h*.33));
    _drawPermBadge(canvas, Rect.fromLTWH(w*.1, h*.53, w*.34, h*.08), radius: 8, isGreen: true, label: '✓ Mauzo');
    _drawPermBadge(canvas, Rect.fromLTWH(w*.56, h*.53, w*.34, h*.08), radius: 8, label: '✗ Faida');
    _drawPermBadge(canvas, Rect.fromLTWH(w*.22, h*.65, w*.56, h*.08), radius: 8, isOrange: true, label: '⚙ Ruhusa za Admin');
    _drawPermBadge(canvas, Rect.fromLTWH(w*.1, h*.77, w*.8, h*.08), radius: 8, isGray: true, label: '🔐  PIN · Username · Wauzaji');
  }

  void _drawCard(Canvas canvas, Rect rect, {double radius = 12}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = Colors.white.withValues(alpha: .1));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = Colors.white.withValues(alpha: .15)..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
  void _drawSmallCard(Canvas canvas, Rect rect, {double radius = 8}) =>
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = Colors.white.withValues(alpha: .12));
  void _drawSmallCardGreen(Canvas canvas, Rect rect, {double radius = 8}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = const Color(0xFF22C55E).withValues(alpha: .15));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = const Color(0xFF22C55E).withValues(alpha: .35)..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
  void _drawSmallCardRed(Canvas canvas, Rect rect, {double radius = 8}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = const Color(0xFFEF4444).withValues(alpha: .15));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = const Color(0xFFEF4444).withValues(alpha: .3)..style = PaintingStyle.stroke..strokeWidth = 0.5);
  }
  void _drawBadgeGreen(Canvas canvas, Rect rect, {double radius = 8}) =>
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = const Color(0xFF22C55E).withValues(alpha: .18));
  void _drawCardOpacity(Canvas canvas, Rect rect, {double radius = 12, double opacity = 0.1, double rotate = 0.0}) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(rotate);
    canvas.translate(-rect.center.dx, -rect.center.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = Colors.white.withValues(alpha: opacity));
    canvas.restore();
  }
  void _drawRoundRect(Canvas canvas, Rect rect, {double radius = 4, double opacity = 0.25, Color? color}) =>
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
          Paint()..color = color ?? Colors.white.withValues(alpha: opacity));
  void _txt(Canvas canvas, String text, Offset offset, {double fontSize = 12, double opacity = 1.0, Color? color}) {
    (TextPainter(text: TextSpan(text: text,
        style: TextStyle(fontSize: fontSize, color: color ?? Colors.white.withValues(alpha: opacity))),
        textDirection: TextDirection.ltr)..layout()).paint(canvas, offset);
  }
  void _txtB(Canvas canvas, String text, Offset offset, {double fontSize = 14, Color? color}) {
    (TextPainter(text: TextSpan(text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        textDirection: TextDirection.ltr)..layout()).paint(canvas, offset);
  }
  void _drawSellerCircle(Canvas canvas, Offset center, double radius, String name) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withValues(alpha: .07));
    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withValues(alpha: .2)..style = PaintingStyle.stroke..strokeWidth = 0.5);
    canvas.drawCircle(center - Offset(0, radius*.25), radius*.4, Paint()..color = Colors.white.withValues(alpha: .3));
    _txt(canvas, name, center + Offset(-radius*.6, radius*.55), fontSize: 8, opacity: 0.4);
  }
  void _drawDashedLine(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()..color = accent.withValues(alpha: .4)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    final dx = b.dx-a.dx; final dy = b.dy-a.dy; final len = (b-a).distance;
    const dL = 4.0, gL = 3.0;
    for (int i = 0; i < (len/(dL+gL)).floor(); i++) {
      final t0 = i*(dL+gL)/len; final t1 = (i*(dL+gL)+dL)/len;
      canvas.drawLine(Offset(a.dx+dx*t0, a.dy+dy*t0), Offset(a.dx+dx*t1, a.dy+dy*t1), paint);
    }
  }
  void _drawPermBadge(Canvas canvas, Rect rect, {double radius = 8, bool isGreen = false, bool isOrange = false, bool isGray = false, required String label}) {
    final Color bg, border, tc;
    if (isGreen) { bg = const Color(0xFF22C55E).withValues(alpha:.12); border = const Color(0xFF22C55E).withValues(alpha:.3); tc = const Color(0xFF86EFAC); }
    else if (isOrange) { bg = accent.withValues(alpha:.1); border = accent.withValues(alpha:.3); tc = accent; }
    else if (isGray) { bg = Colors.white.withValues(alpha:.05); border = Colors.white.withValues(alpha:.15); tc = Colors.white.withValues(alpha:.4); }
    else { bg = const Color(0xFFEF4444).withValues(alpha:.12); border = const Color(0xFFEF4444).withValues(alpha:.3); tc = const Color(0xFFFCA5A5); }
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = bg);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = border..style = PaintingStyle.stroke..strokeWidth = 0.5);
    _txt(canvas, label, Offset(rect.left+10, rect.top+rect.height*.28), fontSize: 9, color: tc);
  }

  @override
  bool shouldRepaint(_IlloPainter old) => old.type != type || old.accent != accent;
}

class _FinishButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFinish;
  const _FinishButtons({required this.onBack, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: .2), width: 0.5)),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20)),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFinish,
          child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(26)),
              child: const Row(children: [
                Text('Anza Sasa', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kNavy)),
                SizedBox(width: 6),
                Icon(Icons.check_circle_outline, color: _kNavy, size: 18),
              ])),
        ),
      ],
    );
  }
}

class _OnboardSlide {
  final Color bgColor; final Color accentColor; final String title;
  final String subtitle; final List<String> chips; final _IlloType illoType;
  const _OnboardSlide({required this.bgColor, required this.accentColor,
      required this.title, required this.subtitle, required this.chips, required this.illoType});
}

class _ObDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: .04)..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) { canvas.drawCircle(Offset(x, y), 1.2, p); }
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _ObDiagonalPainter extends CustomPainter {
  final Color accent;
  const _ObDiagonalPainter({required this.accent});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(Path()..moveTo(size.width*.6, 0)..lineTo(size.width, size.height*.25)
        ..lineTo(size.width, size.height*.2)..lineTo(size.width*.65, 0)..close(),
        Paint()..color = accent.withValues(alpha: .05));
  }
  @override bool shouldRepaint(_ObDiagonalPainter old) => old.accent != accent;
}