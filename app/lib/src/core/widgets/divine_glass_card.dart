import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/components/app_colors.dart';

class DivineGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double blur;
  final double borderRadius;

  const DivineGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.blur = 15.0, // Increased for deeper glass look
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          // Subtle Inner Glow
          BoxShadow(
            color: AppColors.champagneGold.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.glassBackground, // frosting
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: AppColors.glassBorder, // Rose/Champagne gold thin border
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // Content
                  child,

                  // ✨ SPECULAR GLOSS OVERLAY (Diagonal Highlight) - Now on top
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.15), // Slightly increased glint
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
