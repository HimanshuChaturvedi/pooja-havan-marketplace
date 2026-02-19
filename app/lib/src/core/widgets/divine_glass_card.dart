import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/components/app_colors.dart';

class DivineGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showShine;

  const DivineGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.showShine = true,
  });

  @override
  State<DivineGlassCard> createState() => _DivineGlassCardState();
}

class _DivineGlassCardState extends State<DivineGlassCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.showShine) {
      _shineController.repeat();
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          // 🌚 AMBIENT OCCLUSION (SOFT)
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          // 🌚 DROP SHADOW (SHARP)
          BoxShadow(
            color: AppColors.maroon.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          // 💡 INNER GLOW / HIGHLIGHT (TOP)
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, -1),
            // inset: true, // Requires customized flutter or just simulated below
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Stack(
                children: [
                  // 💎 GLASS SURFACE WITH INNER SHINE GRADIENT
                  Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: AppColors.glassBorder, // V2 is more visible
                        width: 1.2,
                      ),
                    ),
                    child: widget.child,
                  ),

                  // ✨ SPECULAR HIGHLIGHT (SHINY TOP-LEFT EDGE)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.45), width: 1.8),
                            left: BorderSide(color: Colors.white.withOpacity(0.45), width: 1.8),
                            bottom: const BorderSide(color: Colors.transparent),
                            right: const BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ✨ ANIMATED SHINE EFFECT
                  if (widget.showShine)
                    IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: FractionallySizedBox(
                              widthFactor: 0.25,
                              alignment: Alignment(
                                -3.0 + (_shineController.value * 6),
                                0,
                              ),
                              child: Transform.rotate(
                                angle: 0.6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
