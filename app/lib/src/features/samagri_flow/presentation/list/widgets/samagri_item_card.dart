import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class SamagriItemCard extends StatelessWidget {
  final String name;
  final int price;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const SamagriItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return DivineGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.maroon,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹$price",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.deepSaffron,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _CounterButton(icon: Icons.remove, onTap: quantity > 0 ? onRemove : null),
              SizedBox(
                width: 40,
                child: Text(
                  quantity.toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _CounterButton(icon: Icons.add, onTap: onAdd),
            ],
          )
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.saffron.withOpacity(onTap == null ? 0.05 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.saffron.withOpacity(onTap == null ? 0.1 : 0.2),
            ),
          ),
          child: Icon(icon, color: onTap == null ? Colors.grey.withOpacity(0.3) : AppColors.maroon, size: 20),
        ),
      ),
    );
  }
}
