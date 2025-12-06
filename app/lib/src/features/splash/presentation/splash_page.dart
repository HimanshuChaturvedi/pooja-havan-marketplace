import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/landing/presentation/landing_page.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // FIXED: remove problematic CurvedAnimation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scale = Tween(begin: 0.9, end: 1.05).animate(_controller);

    // 5 second delay so you can see errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          context.go(LandingPage.routeName);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.saffron,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Diya Icon
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.saffronLight,
                      AppColors.saffronDark,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 95,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                "Shubh Pooja",
                style: AppTextStyles.title.copyWith(color: Colors.white),
              ),

              const SizedBox(height: 8),

              Text(
                "Trusted pandits • Samagri delivered",
                style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
