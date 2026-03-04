import 'package:flutter/material.dart';
import 'spirit_particles.dart';
import '../../theme/components/app_colors.dart';

class DivineBackground extends StatelessWidget {
  final Widget child;
  final bool showParticles;
  final String? bgImagePath;

  const DivineBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.bgImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. DEEP INDIGO DEPTHS GRADIENT
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.bgGradient,
          ),
        ),

        // 2. CENTRAL SACRED GLOW (Mandala Aura)
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.2,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.roseGold.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 3. GLOWING LOTUS MANDALA WATERMARK
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.08,
            child: Icon(
              Icons.spa_rounded, // Central lotus symbol
              size: 500,
              color: AppColors.champagneGold,
            ),
          ),
        ),

        // 4. TOP AURORA (Rose Gold Glow)
        Positioned(
          top: -200,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.mysticalPurple.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 5. FLOATING GOLD PARTICLES
        if (showParticles)
          Positioned.fill(
            child: SpiritParticles(
              color: AppColors.champagneGold.withOpacity(0.6),
            ),
          ),

        // 6. CONTENT LAYER
        child,
      ],
    );
  }
}
