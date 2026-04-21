import 'package:flutter/material.dart';

/// ================================================================
/// BizPawaLogo — Widget inayotumika kila mahali kwenye app
///
/// Matumizi:
///   BizPawaLogo()                    // default
///   BizPawaLogo(fontSize: 32)        // kubwa (splash)
///   BizPawaLogo(fontSize: 14)        // ndogo (top bar)
///   BizPawaLogo(iconSize: 40)        // icon tu bila text
///   BizPawaLogo(showText: false)     // icon peke yake
///   BizPawaLogo(lightMode: true)     // kwenye background nyeupe
/// ================================================================

class BizPawaLogo extends StatelessWidget {
  final double fontSize;
  final double iconSize;
  final double letterSpacing;
  final double gap;
  final bool showText;
  final bool lightMode; // true = text inakuwa navy+orange, false = white+orange

  const BizPawaLogo({
    super.key,
    this.fontSize = 26,
    this.iconSize = 36,
    this.letterSpacing = 1.5,
    this.gap = 10,
    this.showText = true,
    this.lightMode = false,
  });

  // Icon peke yake (kwenye top bar ndogo, app icon)
  const BizPawaLogo.iconOnly({
    super.key,
    this.iconSize = 32,
  })  : fontSize = 0,
        letterSpacing = 0,
        gap = 0,
        showText = false,
        lightMode = false;

  // Kubwa — kwa splash screen
  const BizPawaLogo.splash({super.key})
      : fontSize = 34,
        iconSize = 72,
        letterSpacing = 2,
        gap = 16,
        showText = true,
        lightMode = false;

  // Medium — kwa login/welcome
  const BizPawaLogo.medium({super.key, this.lightMode = true})
      : fontSize = 26,
        iconSize = 44,
        letterSpacing = 1.5,
        gap = 12,
        showText = true;

  // Ndogo — kwa top bar
  const BizPawaLogo.small({super.key})
      : fontSize = 13,
        iconSize = 28,
        letterSpacing = 2,
        gap = 8,
        showText = true,
        lightMode = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ===== LOGO ICON =====
        Image.asset(
          'assets/logo.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),

        // ===== TEXT =====
        if (showText) ...[
          SizedBox(width: gap),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'BIZ',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: lightMode
                        ? const Color(0xFF1B2E6B)   // navy kwenye bg nyeupe
                        : Colors.white,              // white kwenye bg navy/dark
                    letterSpacing: letterSpacing,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: 'PAWA',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF5A623), // orange/gold daima
                    letterSpacing: letterSpacing,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}