import 'package:flutter/material.dart';
import '../../theme/components/app_colors.dart';
import 'spirit_particles.dart';

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
        // 🌅 1. BASE SAFFRON DAWN GRADIENT
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.bgGradient,
          ),
        ),

        // 🌅 2. DEPTH VIGNETTE (Focus Center)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  AppColors.maroon.withOpacity(0.15),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // 🏵️ 3. SUBTLE WATERMARK DEVOTIONAL IMAGE
        if (bgImagePath != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.22, // Slightly more visible
              child: Image.asset(
                bgImagePath!,
                fit: BoxFit.cover,
                color: AppColors.saffron.withOpacity(0.2),
                colorBlendMode: BlendMode.softLight, // Soft light for better texture integration
              ),
            ),
          ),

        // ✨ 4. SPIRIT PARTICLES (DIVINE LIGHT)
        if (showParticles)
          const Positioned.fill(
            child: SpiritParticles(color: AppColors.gold),
          ),

        // 📱 5. CONTENT LAYER
        child,
      ],
    );
  }
}
