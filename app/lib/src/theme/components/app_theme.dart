import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final seed = AppColors.saffron;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light, // Force Light Mode for Bright Divine theme
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.saffron,
      secondary: AppColors.gold,
      surface: AppColors.cream, // Changed from midnight for Light Theme
      onSurface: AppColors.maroon, // Changed from white for visibility
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: AppColors.maroon, // Changed from white
      displayColor: AppColors.maroon, // Changed from white
    ),
    scaffoldBackgroundColor: AppColors.cream, // Changed from midnight
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.saffron,
        foregroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );
}
