import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
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
  late final AnimationController _floatController;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 🔒 SESSION BOUNDARY RESET
    BookingSession.reset();
    SamagriSession.current = null;
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 500.0 : screenWidth;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      body: DivineBackground(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),

                  // ✅ FIXED TITLE (REMOVED SHADERMASK FOR RELIABILITY)
                  _StaggeredFade(
                    controller: _mainController,
                    delay: 0,
                    child: Text(
                      "Bharat Pooja Setu",
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 36,
                        color: AppColors.champagneGold, // Solid contrast
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          Shadow(
                            color: AppColors.roseGold.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _StaggeredFade(
                    controller: _mainController,
                    delay: 200,
                    child: Text(
                      "Connecting Bharat with Dharma",
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.roseGold.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2.0,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🏷️ GLOWING PILOT BADGE
                  _StaggeredFade(
                    controller: _mainController,
                    delay: 400,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.roseGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.roseGold.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.roseGold.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 16, color: AppColors.champagneGold),
                          const SizedBox(width: 8),
                          Text(
                            "Pilot active in Ghaziabad",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.champagneGold,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 55),

                  // 💠 HYPER-PREMIUM 2x2 GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 0.78, 
                      children: [
                        _MenuTile(
                          imagePath: 'assets/images/pooja_ganesha.png',
                          label: "Book a Pooja",
                          subtitle: "Home or Temple",
                          delay: 600,
                          mainController: _mainController,
                          floatAnimation: _floatController,
                          onTap: () => context.push('/booking-mode'),
                        ),
                        _MenuTile(
                          imagePath: 'assets/images/samagri_thali.png',
                          label: "Buy Samagri",
                          subtitle: "Sacred items",
                          delay: 750,
                          mainController: _mainController,
                          floatAnimation: _floatController,
                          onTap: () => context.go('/samagri-list'),
                        ),
                        _MenuTile(
                          imagePath: 'assets/images/explore_divine.png',
                          label: "Explore",
                          subtitle: "All offerings",
                          delay: 900,
                          mainController: _mainController,
                          floatAnimation: _floatController,
                          onTap: () => context.push('/explore-services'),
                        ),
                        _MenuTile(
                          imagePath: 'assets/images/activity_scroll.png',
                          label: "My Activity",
                          subtitle: "Past bookings",
                          delay: 1050,
                          mainController: _mainController,
                          floatAnimation: _floatController,
                          onTap: () => context.push('/my-activity'),
                        ),
                      ],
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

class _MenuTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final String subtitle;
  final int delay;
  final AnimationController mainController;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;

  const _MenuTile({
    required this.imagePath,
    required this.label,
    required this.subtitle,
    required this.delay,
    required this.mainController,
    required this.floatAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _StaggeredFade(
      controller: mainController,
      delay: delay,
      child: AnimatedBuilder(
        animation: floatAnimation,
        builder: (context, child) {
          final floatOffset = 8 * (floatAnimation.value - 0.5) * 2; 
          
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: DivineGlassCard(
              onTap: onTap,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✨ ASSET WITH BLOOM AURA
                    Expanded(
                      flex: 7,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radiant Glow behind asset
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.champagneGold.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // High-Fidelity Image (Blending fix for checkerboard)
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              AppColors.deepIndigo.withOpacity(0.1), // Subtle tint
                              BlendMode.multiply,
                            ),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, _, __) => Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.champagneGold,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Label
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Philosopher',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Flexible(
                      flex: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.roseGold.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _CustomBottomNav({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.deepIndigo.withOpacity(0.6),
              border: Border.all(
                color: AppColors.champagneGold.withOpacity(0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  isActive: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: "Bookings",
                  isActive: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _NavItem(
                  icon: Icons.shop_two_rounded,
                  label: "Shop",
                  isActive: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  isActive: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.champagneGold : Colors.white.withOpacity(0.3),
              shadows: isActive ? [
                Shadow(color: AppColors.champagneGold.withOpacity(0.5), blurRadius: 10)
              ] : null,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.champagneGold : Colors.white.withOpacity(0.4),
                fontWeight: isActive ? FontWeight.w800 : FontWeight.normal,
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
        final start = (delay / 1500).clamp(0.0, 1.0);
        final end = ((delay + 700) / 1500).clamp(0.0, 1.0);
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ).value;
        
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - opacity)),
            child: child,
          ),
        );
      },
    );
  }
}
