import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../services/presentation/services_page.dart';

class LandingPage extends StatelessWidget {
  static const routeName = '/landing';

  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 480 ? 420.0 : screenWidth;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 70),

              Text(
                "Shubh Pooja",
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryGold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                "Divine Rituals, Modern Convenience",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  childAspectRatio: 0.85,
                  children: [
                    // Book a Pooja
                    _LandingCard(
                      iconAsset: "assets/icons/bell.png",
                      label: "Book a Pooja",
                      onTap: () =>
                          context.go(ServicesPage.routeName),
                    ),

                    // Buy Samagri
                    _LandingCard(
                      iconAsset: "assets/icons/samagri_box.png",
                      label: "Buy Samagri",
                      onTap: () => context.go('/samagri-list'),
                    ),

                    // Havan at Temple
                    _LandingCard(
                      iconAsset: "assets/icons/temple.png",
                      label: "Havan at Temple",
                      onTap: () => context.go('/temples/Delhi'),
                    ),

                    // Explore Services
                    _LandingCard(
                      iconAsset: "assets/icons/lotus.png",
                      label: "Explore Services",
                      onTap: () =>
                          context.push('/explore-services'),
                    ),

                    // My Activity (NO ASSET – SAFE)
                    _LandingCard(
                      iconAsset: null,
                      label: "My Activity",
                      onTap: () => context.go('/my-activity'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingCard extends StatelessWidget {
  final String? iconAsset;
  final String label;
  final VoidCallback onTap;

  const _LandingCard({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconAsset != null
                ? Image.asset(
                    iconAsset!,
                    height: 48,
                    width: 48,
                    color: AppColors.primaryGold,
                  )
                : const Icon(
                    Icons.history,
                    size: 48,
                    color: AppColors.primaryGold,
                  ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
