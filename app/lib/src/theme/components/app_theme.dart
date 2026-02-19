import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final seed = AppColors.saffron;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.saffron,
      secondary: AppColors.gold,
      surface: AppColors.midnight,
      onSurface: AppColors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.midnight,
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
