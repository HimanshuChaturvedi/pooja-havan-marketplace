import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final seed = AppColors.saffron;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: AppColors.saffron,
      secondary: AppColors.gold,
      background: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.saffron,
        foregroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16),
    ),
  );
}
