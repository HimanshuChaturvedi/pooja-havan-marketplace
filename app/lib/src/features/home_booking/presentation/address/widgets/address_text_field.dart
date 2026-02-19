import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

class AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const AddressTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon.withOpacity(0.35)),
        filled: true,
        fillColor: AppColors.saffron.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.saffron.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.deepSaffron, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
