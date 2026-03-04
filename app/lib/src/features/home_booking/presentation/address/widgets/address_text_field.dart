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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Address',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.darkCharcoal, 
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 4,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            // Border is handled by theme, but we can override if needed for specific aesthetic
          ),
        ),
      ],
    );
  }
}
