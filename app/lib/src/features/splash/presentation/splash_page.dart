import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _haloController;
  late final Animation<double> _scale;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _haloScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOut),
    );

    _haloOpacity = Tween<double>(begin: 0.1, end: 0.3).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    // Navigate to landing after 3.5 seconds for a more relaxed premium feel
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) context.go('/landing');
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.warmIvory,
              AppColors.warmIvory.withOpacity(0.9),
              const Color(0xFFF5E6D3), // Slightly deeper warm tone for edges
            ],
          ),
        ),
        child: Stack(
          children: [
            // ✨ DIVINE BACKGROUND ORNAMENT (Subtle)
            Positioned(
              top: -100,
              left: -100,
              child: Opacity(
                opacity: 0.03,
                child: Icon(Icons.wb_sunny_outlined, size: 400, color: AppColors.saffron),
              ),
            ),
            
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔆 DIVINE PULSING HALO
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _haloController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _haloScale.value,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.saffron.withOpacity(_haloOpacity.value),
                                    AppColors.saffron.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // 🕉️ CENTRAL LOGO
                      ScaleTransition(
                        scale: _scale,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.saffron.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded, // Replace with actual logo asset if available
                            size: 90,
                            color: AppColors.saffron,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),

                  // 📜 PREMIUM TITLE
                  _StaggeredFade(
                    delay: 400,
                    controller: _mainController,
                    child: Column(
                      children: [
                        Text(
                          "Bharat Pooja Setu",
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.darkCharcoal,
                            fontSize: 38,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.saffron,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ✨ SUBTLE TAGLINE
                  _StaggeredFade(
                    delay: 800,
                    controller: _mainController,
                    child: Text(
                      "Connecting Bharat with Dharma",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.softGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                  
                  // 🔄 LOADING INDICATOR
                  _StaggeredFade(
                    delay: 1200,
                    controller: _mainController,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.saffron),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredFade extends StatelessWidget {
  final AnimationController controller;
  final int delay;
  final Widget child;

  const _StaggeredFade({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final start = (delay / 2000).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 2000).clamp(0, 1.0).toDouble();
        
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ).value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
    );
  }
}
