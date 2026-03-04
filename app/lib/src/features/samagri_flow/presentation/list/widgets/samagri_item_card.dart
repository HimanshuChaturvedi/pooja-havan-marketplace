import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

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
    return PrimaryCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.saffron.withOpacity(0.5),
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹$price",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  _CounterButton(icon: Icons.remove, onTap: quantity > 0 ? onRemove : null),
                  SizedBox(
                    width: 24,
                    child: Text(
                      quantity.toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.darkCharcoal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _CounterButton(icon: Icons.add, onTap: onAdd),
                ],
              ),
            ],
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.saffron.withOpacity(onTap == null ? 0.02 : 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: onTap == null ? AppColors.softGrey.withOpacity(0.3) : AppColors.darkCharcoal,
          size: 16,
        ),
      ),
    );
  }
}
