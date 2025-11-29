import 'dart:math';

import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/shared/widgets/primary_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _gradientController;
  late final AnimationController _circlesController;
  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();

    // Gradient animator (slow)
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Circles animator (drift)
    _circlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Icon scale / pulse
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _circlesController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  // Helper to compute drifting offset for circles
  Offset _driftOffset(double baseX, double baseY, double radius, double t) {
    // t from 0..1
    final dx = sin(2 * pi * t + baseX) * radius * 0.35;
    final dy = cos(2 * pi * t + baseY) * radius * 0.22;
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _gradientController,
          _circlesController,
          _iconController,
        ]),
        builder: (context, _) {
          // Gradient lerp value
          final gval = _gradientController.value;
          // circle time
          final t = _circlesController.value;

          // dynamic gradient colors (saffron + gold tint feel if your AppColors set accordingly)
          final colorA =
              Color.lerp(
                const Color(0xFFFBE9D7),
                AppColors.saffron ?? const Color(0xFFFFC107),
                gval,
              ) ??
              AppColors.mint;
          final colorB =
              Color.lerp(
                const Color(0xFFFFF3E0),
                AppColors.saffronDark ?? const Color(0xFFFFA000),
                1 - gval,
              ) ??
              AppColors.mintAccent;

          return Stack(
            children: [
              // Animated background gradient
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorA, colorB],
                    begin: Alignment(-0.8 + gval, -0.6),
                    end: Alignment(0.8 - gval, 0.6),
                  ),
                ),
              ),

              // floating circles - positions based on screen size and t
              // Circle 1 (top-left large)
              Positioned(
                left: -80 + _driftOffset(0.2, 0.1, 40, t).dx,
                top: -60 + _driftOffset(0.3, 0.2, 40, t).dy,
                child: _GlowingCircle(
                  diameter: min(size.width, size.height) * 0.45,
                  color: (AppColors.saffron ?? const Color(0xFFFFC107))
                      .withOpacity(0.12),
                ),
              ),

              // Circle 2 (top-right medium)
              Positioned(
                right: -60 + _driftOffset(1.5, 0.7, 28, t).dx,
                top: 60 + _driftOffset(1.0, 0.5, 28, t).dy,
                child: _GlowingCircle(
                  diameter: min(size.width, size.height) * 0.33,
                  color: (AppColors.saffron ?? const Color(0xFFFFC107))
                      .withOpacity(0.08),
                ),
              ),

              // Circle 3 (bottom-left small)
              Positioned(
                left: 40 + _driftOffset(2.2, 1.1, 18, t).dx,
                bottom: -40 + _driftOffset(0.5, 0.9, 18, t).dy,
                child: _GlowingCircle(
                  diameter: min(size.width, size.height) * 0.20,
                  color: (AppColors.saffronDark ?? const Color(0xFFFFA000))
                      .withOpacity(0.10),
                ),
              ),

              // Content column
              SafeArea(
                child: Column(
                  children: [
                    // top visual area
                    SizedBox(
                      height: size.height * 0.44,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Diya/Icon
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.94, end: 1.06)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _iconController,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                              child: Opacity(
                                opacity: 0.98,
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        (AppColors.saffron ??
                                                const Color(0xFFFFC107))
                                            .withOpacity(0.95),
                                        (AppColors.saffronDark ??
                                                const Color(0xFFFFA000))
                                            .withOpacity(0.85),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (AppColors.saffronDark ??
                                                    const Color(0xFFFFA000))
                                                .withOpacity(0.28),
                                        blurRadius: 28,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 84,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // small subtitle under icon
                            Text(
                              'Shubh Pooja',
                              style: AppTextStyles.title.copyWith(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trusted pandits • Samagri delivered • Hassle-free',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // bottom card area with controls
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Book services near you',
                              style: AppTextStyles.title.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Select an option to begin — location-first flow will follow next.',
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: 18),
                            PrimaryButton(
                              text: 'Book Pooja',
                              onPressed: () {
                                // placeholder - wire later to actual route
                              },
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              text: 'Buy Samagri',
                              onPressed: () {},
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              text: 'Nearby Pooja Services',
                              onPressed: () {},
                            ),
                            const Spacer(),
                            // small footer link row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Change theme: ',
                                  style: AppTextStyles.subtitle,
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    // we will implement theme switching later
                                  },
                                  child: Text(
                                    'Saffron • Gold',
                                    style: AppTextStyles.subtitle.copyWith(
                                      color:
                                          AppColors.saffronDark ??
                                          Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== helper widget ====================
class _GlowingCircle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _GlowingCircle({
    required this.diameter,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
