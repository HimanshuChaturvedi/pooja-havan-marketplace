import 'dart:math';
import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/shared/widgets/primary_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _sine(double t, double phase, double amplitude) {
    return sin((t + phase) * 2 * pi) * amplitude;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            // Top animated banner
            Expanded(
              flex: 2,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final t = _animController.value;
                  return Stack(
                    children: [
                      // base gradient
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFE7CC), Color(0xFFFFF6E6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                      // moving big saffron orb (soft)
                      Positioned(
                        left: -60 + _sine(t, 0.0, 30),
                        top: -20 + _sine(t, 0.2, 18),
                        child: _glowCircle(
                          280,
                          AppColors.saffron.withOpacity(0.12),
                        ),
                      ),

                      // moving golden orb
                      Positioned(
                        right: -80 + _sine(t, 0.5, 24),
                        top: 40 + _sine(t, 0.8, 18),
                        child: _glowCircle(
                          200,
                          AppColors.gold.withOpacity(0.12),
                        ),
                      ),

                      // smaller accent
                      Positioned(
                        left: mq.size.width * 0.25 + _sine(t, 0.9, 20),
                        bottom: 20 + _sine(t, 0.3, 12),
                        child: _glowCircle(
                          110,
                          AppColors.saffron.withOpacity(0.14),
                        ),
                      ),

                      // Center decorative motif (simple mandala-like using Icon for now)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Optionally replace Icon with an asset or uploaded image.
                            const Icon(
                              Icons.star,
                              size: 88,
                              color: Color(0xFFFBF3E6),
                            ),
                            const SizedBox(height: 12),
                            // small subtitle in banner
                            Text(
                              'Shubh Pooja',
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.saffronDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22.0,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    // Headline & subtitle with a subtle fade-in using AnimatedOpacity
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        // slow fade using controller value
                        double alpha = (0.6 + 0.4 * _animController.value);
                        return Opacity(
                          opacity: alpha.clamp(0.0, 1.0),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Book Pooja & Havan Easily',
                            style: AppTextStyles.title,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Find trusted pandits, buy samagri and complete your rituals with confidence.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Buttons — each has a small staggered scale using Transform.scale
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final base =
                            1.0 + 0.02 * sin(_animController.value * 2 * pi);
                        return Column(
                          children: [
                            Transform.scale(
                              scale: base,
                              child: PrimaryButton(
                                text: 'Book Pooja',
                                onPressed: () {
                                  // TODO: navigate to booking
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            Transform.scale(
                              scale: base * 0.996,
                              child: PrimaryButton(
                                text: 'Book Havan',
                                onPressed: () {
                                  // TODO: navigate to havan booking
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            Transform.scale(
                              scale: base * 0.992,
                              child: PrimaryButton(
                                text: 'Explore Services',
                                onPressed: () {
                                  // TODO: navigate to services listing
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
    );
  }
}
