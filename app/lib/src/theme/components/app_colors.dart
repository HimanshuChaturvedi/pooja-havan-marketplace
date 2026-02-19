import 'package:flutter/material.dart';

class AppColors {
  // ✨ OPTION 2: SAFFRON DAWN (BRIGHT DIVINE)
  static const saffron = Color(0xFFFF9933);   // Radiant Saffron
  static const gold = Color(0xFFFFD700);      // Pure Gold
  static const yellow = Color(0xFFFFF176);    // Sunlight Yellow
  
  static const dawnOrange = Color(0xFFFFCC80); // Soft Dawn Orange
  static const dawnYellow = Color(0xFFFFF9C4); // Pale Morning Sun
  
  // DAKSHINA RED (High Contrast Text)
  static const maroon = Color(0xFF800000);    // Deep Maroon
  static const deepSaffron = Color(0xFFE65100); // Burnt Orange for body text
  
  static const cream = Color(0xFFFFFDE7);     // Divine Cream
  static const white = Colors.white;
 
  // GRADIENTS
  static const bgGradient = LinearGradient(
    colors: [dawnOrange, dawnYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
 
  static const saffronGradient = LinearGradient(
    colors: [saffron, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
 
  // ✨ 3D GLASSMORPHISM V2 (High Depth)
  static Color glassBackground = Colors.white.withOpacity(0.12); // Much thinner for v2
  static Color glassBorder = Colors.white.withOpacity(0.6); // Increased from 0.4
  static Color glassShadow = Colors.black.withOpacity(0.2); 
  static Color glassShine = Colors.white.withOpacity(0.6); // For specular highlights
 
  // LEGACY COMPATIBILITY
  static const midnight = Color(0xFF1A1A2E); 
  static const purple = Color(0xFF4A148C);
  static const textDark = maroon;
  static const primaryGold = deepSaffron;
  
  static const backgroundLight = dawnYellow;
  static const saffronLight = dawnOrange;
  static const saffronDark = saffron;
  static const goldGradient = saffronGradient;
}
