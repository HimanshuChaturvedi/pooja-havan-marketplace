import 'package:flutter/material.dart';

class AppColors {
  // 🌕 Main brand colors (you selected saffron+gold theme)
  static const Color saffron = Color(0xFFF4A300);
  static const Color saffronLight = Color(0xFFFFC766);
  static const Color saffronDark = Color(0xFFCC8400);

  static const Color gold = Color(0xFFFFE08A);
  static const Color goldLight = Color(0xFFFFF4C2);

  // 🪔 Background neutrals
  static const Color white = Colors.white;
  static const Color bg = Color(0xFFFDF8F3);

  // 🌿 Light Mint tones (for soft modern gradients)
  static const Color mint = Color(0xFFDFFFEA); // very soft mint
  static const Color mintAccent = Color(0xFFB5F2D3); // nice light accent

  // 🔥 Additional soft colors used by circles/background
  static Color circleSoft(double opacity) => Colors.white.withOpacity(opacity);
}
