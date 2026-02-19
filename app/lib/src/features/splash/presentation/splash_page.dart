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
  late final AnimationController _pulseController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _mainController.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/landing');
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2 + (0.2 * _pulseController.value),
                colors: [
                  AppColors.dawnYellow,
                  AppColors.saffronLight,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Diya Icon
              ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.saffron.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 5,
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [AppColors.dawnYellow, AppColors.saffron.withOpacity(0.4)],
                    ),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 110,
                    color: AppColors.maroon,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ✅ MODERN PREMIUM TITLE
              _StaggeredFade(
                delay: 500,
                controller: _mainController,
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                  child: Text(
                    "Bharat Pooja Setu",
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.maroon,
                      fontSize: 36,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ SUBTLE TAGLINE
              _StaggeredFade(
                delay: 1000,
                controller: _mainController,
                child: Text(
                  "Connecting Bharat with Dharma",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.deepSaffron,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 80),
              
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepSaffron),
              ),
            ],
          ),
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
          curve: Interval(start, end, curve: Curves.easeIn),
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
