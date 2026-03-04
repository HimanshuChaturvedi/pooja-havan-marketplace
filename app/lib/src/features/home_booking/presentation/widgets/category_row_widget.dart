import 'package:flutter/material.dart';
import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';

class CategoryRowWidget extends StatelessWidget {
  const CategoryRowWidget({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Grih Pravesh', 'icon': Icons.home_work_outlined},
    {'name': 'Satyanarayan', 'icon': Icons.auto_awesome_outlined},
    {'name': 'Rudrabhishek', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Marriage Pooja', 'icon': Icons.favorite_outline},
    {'name': 'Havan', 'icon': Icons.local_fire_department_outlined},
    {'name': 'Pitru Dosh', 'icon': Icons.people_outline},
    {'name': 'Temple Pooja', 'icon': Icons.temple_hindu_outlined},
    {'name': 'Samagri Only', 'icon': Icons.shopping_basket_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return GestureDetector(
            onTap: () {
              // Navigation hook placeholder
            },
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: AppColors.champagneGold.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      cat['icon'],
                      size: 28,
                      color: AppColors.champagneGold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
