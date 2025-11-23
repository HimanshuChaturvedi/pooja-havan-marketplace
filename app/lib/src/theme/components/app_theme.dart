import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.scaffold,
    colorScheme: ColorScheme.light(
      primary: AppColors.saffron,
      secondary: AppColors.gold,
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTextStyles.title,
      bodyMedium: AppTextStyles.subtitle,
    ),
    useMaterial3: true,
  );
}
