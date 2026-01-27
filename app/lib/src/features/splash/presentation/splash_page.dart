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

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 🔒 1 sec locked
    );

    _scale = Tween(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(LandingPage.routeName);
      }
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

              // ✅ UPDATED APP NAME
              Text(
                "Bharat Pooja Setu",
                style:
                    AppTextStyles.title.copyWith(color: Colors.white),
              ),

              const SizedBox(height: 8),

              // ✅ UPDATED TAGLINE
              Text(
                "Connecting Bharat with Dharma",
                style: AppTextStyles.subtitle
                    .copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
