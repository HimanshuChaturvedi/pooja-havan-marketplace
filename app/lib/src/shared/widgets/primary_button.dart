import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 8, // ⭐ 3D effect
          shadowColor: AppColors.primary.withOpacity(0.4), // ⭐ glow shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // ⭐ round edges
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
