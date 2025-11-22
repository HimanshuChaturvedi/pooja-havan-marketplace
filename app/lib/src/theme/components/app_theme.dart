import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.scaffold,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.mint,
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTextStyles.title,
      bodyMedium: AppTextStyles.subtitle,
    ),
    useMaterial3: true,
  );
}
