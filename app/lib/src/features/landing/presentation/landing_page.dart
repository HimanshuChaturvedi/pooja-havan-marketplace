import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../services/presentation/services_page.dart';
import '../../../features/booking/application/booking_session.dart';
import '../../samagri_flow/application/samagri_session.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class LandingPage extends StatefulWidget {
  static const routeName = '/landing';

  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  
  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // 🔒 SESSION BOUNDARY RESET (LOCKED)
    BookingSession.reset();
    SamagriSession.current = null;
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 480 ? 420.0 : screenWidth;

    return Scaffold(
      body: DivineBackground(
        // Subtle background image integration (Ram Mandir/Spirituality feeling)
        bgImagePath: 'assets/images/temple_bg_soft.png', 
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),

                  // ✅ PREMIUM TITLE (SAFFRON DAWN STYLE)
                  _StaggeredFade(
                    controller: _mainController,
                    delay: 0,
                    child: Text(
                      "Bharat Pooja Setu",
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 34,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: AppColors.saffron.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _StaggeredFade(
                    controller: _mainController,
                    delay: 200,
                    child: Text(
                      "Connecting Bharat with Dharma",
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.maroon,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🏷️ PREMIUM PILOT BADGE
                  _StaggeredFade(
                    controller: _mainController,
                    delay: 400,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
                      ),
                      child: Text(
                        "Pilot active in Ghaziabad",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.maroon,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 💠 3D GLASS GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _StaggeredFade(
                          controller: _mainController,
                          delay: 600,
                          child: _MenuRow(
                            icon: Icons.auto_awesome_outlined,
                            label: "Book a Pooja",
                            onTap: () => context.go(ServicesPage.routeName),
                          ),
                        ),
                        _StaggeredFade(
                          controller: _mainController,
                          delay: 750,
                          child: _MenuRow(
                            icon: Icons.shopping_basket_outlined,
                            label: "Buy Samagri",
                            onTap: () => context.go('/samagri-list'),
                          ),
                        ),
                         _StaggeredFade(
                          controller: _mainController,
                          delay: 900,
                          child: _MenuRow(
                            icon: Icons.temple_hindu_outlined,
                            label: "Havan at Temple",
                            onTap: () => context.go('/temples/Delhi'),
                          ),
                        ),
                        _StaggeredFade(
                          controller: _mainController,
                          delay: 1050,
                          child: _MenuRow(
                            icon: Icons.explore_outlined,
                            label: "Explore Services",
                            onTap: () => context.push('/explore-services'),
                          ),
                        ),
                        _StaggeredFade(
                          controller: _mainController,
                          delay: 1200,
                          child: _MenuRow(
                            icon: Icons.history_edu_outlined,
                            label: "My Activity",
                            onTap: () => context.push('/my-activity'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DivineGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.saffron.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: AppColors.deepSaffron,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.saffron,
          ),
        ],
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
        final start = delay / 1500;
        final end = (delay + 600) / 1500;
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start.clamp(0, 1), end.clamp(0, 1), curve: Curves.easeOut),
        ).value;
        
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - opacity)),
            child: child,
          ),
        );
      },
    );
  }
}
