import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // PREMIUM SERIF FOR HEADINGS (Spiritual & Elegant)
  static TextStyle get titleLarge => GoogleFonts.philosopher(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: AppColors.maroon,
        letterSpacing: 0.5,
      );

  static TextStyle get title => GoogleFonts.philosopher(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.maroon,
      );

  static TextStyle get subtitle => GoogleFonts.yantramanav(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.deepSaffron,
      );

  // MODERN SANS FOR BODY (Optimized for Readability)
  static TextStyle get bodyLarge => GoogleFonts.yantramanav(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.maroon.withOpacity(0.9),
      );

  static TextStyle get bodyMedium => GoogleFonts.yantramanav(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.maroon.withOpacity(0.85),
      );

  static TextStyle get bodySmall => GoogleFonts.yantramanav(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.deepSaffron.withOpacity(0.9),
      );

  static TextStyle get button => GoogleFonts.yantramanav(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      );
}
