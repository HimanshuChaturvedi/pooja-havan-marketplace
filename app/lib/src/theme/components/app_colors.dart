import 'package:flutter/material.dart';

class AppColors {
  // 🕊️ MODERN IVORY PREMIUM PALETTE (REFINED)
  static const warmIvory       = Color(0xFFFAF7F2); // Page Background
  static const darkCharcoal    = Color(0xFF1C1C1E); // Primary Text
  static const softGrey        = Color(0xFF6B6B6B); // Secondary Text
  
  // ACCENTS
  static const saffron         = Color(0xFFF4A300); // REFINED SAFFRON
  static const saffronSecondary = Color(0xFFFFB422); // Brighter saffron for gradients
  static const deepPlum        = Color(0xFF4A2E6F); // Secondary Accent
  
  // STATUS
  static const softGreen       = Color(0xFF4CAF50);
  static const softRed         = Color(0xFFE57373);
  static const champagneGold   = Color(0xFFF5D193); 

  // GRADIENTS
  static const saffronGradient = LinearGradient(
    colors: [Color(0xFFF4A300), Color(0xFFFFB422)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const plumGradient = LinearGradient(
    colors: [Color(0xFF4A2E6F), Color(0xFF6A4C93)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ✨ CARD SYSTEM — REFINED (Minimal)
  static Color glassBackground = Colors.white.withOpacity(0.9); 
  static Color cardSaffronBorder = const Color(0xFFF4A300).withOpacity(0.12); // 10-15% Opacity
  static Color cardSaffronShadow = const Color(0xFFF4A300).withOpacity(0.08); // Low opacity glow
  static const glassBorder     = Color(0xFFE0E0E0);
  static Color glassShadow     = Colors.black.withOpacity(0.05);

  // LEGACY COMPATIBILITY
  static const deepIndigo      = warmIvory; 
  static const mysticalPurple  = deepPlum;
  static const cosmicViolet    = darkCharcoal;
  static const bgGradient      = LinearGradient(colors: [warmIvory, Color(0xFFFDFCFB)]);
  static const goldGradient    = saffronGradient;
  static const purpleGradient  = plumGradient;
  
  static const white           = Colors.white;
  static const white70         = Colors.white70;
  static const roseGold        = Color(0xFFE49B9B);
  static const maroon          = deepPlum; 
  static const deepSaffron     = saffron;
  static const cream           = warmIvory;
  static const midnight        = darkCharcoal;
  static const purple          = deepPlum;
  static const dawnOrange      = saffron;
  static const gold            = Color(0xFFFFD700);
  
  static const textDark        = darkCharcoal; 
  static const primaryGold     = saffron;
  static const backgroundLight = warmIvory;
  static const saffronLight    = saffronSecondary;
  static const saffronDark     = saffron;
}
