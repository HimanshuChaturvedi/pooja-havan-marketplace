import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

class ChoiceCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppColors.saffron.withOpacity(0.15), AppColors.saffron.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.06),
            border: Border.all(
              color: isSelected ? AppColors.saffron : Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.saffron.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18,
                        color: isSelected ? AppColors.maroon : AppColors.maroon.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.maroon.withOpacity(isSelected ? 0.9 : 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.maroon,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
