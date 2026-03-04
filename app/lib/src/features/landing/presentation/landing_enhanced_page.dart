import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

const String kRouteLanding = '/landing';

final selectedLocationProvider = StateProvider<String?>((ref) => null);

class LandingEnhancedPage extends ConsumerWidget {
  const LandingEnhancedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.watch(selectedLocationProvider);

    return AppScaffold(
      showAppBar: true,
      centerTitle: false,
      title: 'Namaste',
      actions: [
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.person_outline, color: AppColors.darkCharcoal),
          onPressed: () => context.push('/profile'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationBar(context, ref, selectedLocation),
            const SizedBox(height: 32),
            Text(
              'How can we help today?',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.darkCharcoal,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),

            // Primary action grid
            _PrimaryActionGrid(onActionTap: (action) {
              switch (action) {
                case _LandingAction.bookPooja:
                  context.push('/services');
                  break;
                case _LandingAction.buySamagri:
                  context.push('/samagri');
                  break;
                case _LandingAction.havanAtTemple:
                  context.push('/location-selection?type=temple');
                  break;
                case _LandingAction.explore:
                  context.push('/explore');
                  break;
              }
            }),

            const SizedBox(height: 32),

            // Popular rituals
            Text(
              'Popular rituals', 
              style: AppTextStyles.title.copyWith(
                fontSize: 18, 
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _popularRituals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _popularRituals[index];
                  return _RitualCard(
                    title: item.title, 
                    subtitle: item.subtitle, 
                    onTap: () {
                      context.push('/service/${item.slug}/${Uri.encodeComponent(item.title)}');
                    }
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Recommended for you', 
              style: AppTextStyles.title.copyWith(
                fontSize: 18, 
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _RecommendedTile(onTap: () => context.push('/services')),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, WidgetRef ref, String? selectedLocation) {
    return PrimaryCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/location-selection?type=home'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, size: 24, color: AppColors.saffron),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLocation ?? 'Select Location', 
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose city or detect location', 
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.softGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffron),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LandingAction { bookPooja, buySamagri, havanAtTemple, explore }

class _PrimaryActionGrid extends StatelessWidget {
  final void Function(_LandingAction) onActionTap;
  const _PrimaryActionGrid({Key? key, required this.onActionTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 420;
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _ActionTile(
          title: 'Book a Pooja', 
          icon: Icons.home_repair_service_rounded, 
          onTap: () => onActionTap(_LandingAction.bookPooja),
        ),
        _ActionTile(
          title: 'Buy Samagri', 
          icon: Icons.shopping_basket_rounded, 
          onTap: () => onActionTap(_LandingAction.buySamagri),
        ),
        _ActionTile(
          title: 'Havan at Temple', 
          icon: Icons.temple_hindu_rounded, 
          onTap: () => onActionTap(_LandingAction.havanAtTemple),
        ),
        _ActionTile(
          title: 'Explore Services', 
          icon: Icons.search_rounded, 
          onTap: () => onActionTap(_LandingAction.explore),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionTile({Key? key, required this.title, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: AppColors.saffron),
            ),
            const Spacer(),
            Text(
              title, 
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RitualCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RitualCard({Key? key, required this.title, required this.subtitle, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        width: 190,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title, 
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle, 
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.softGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  final VoidCallback onTap;
  const _RecommendedTile({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.saffron.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppColors.saffron),
        ),
        title: Text(
          'Pandit — Vishal Sharma',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkCharcoal,
          ),
        ),
        subtitle: Text(
          'Grih Pooja • 8 years experience',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.softGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffron),
      ),
    );
  }
}

class _RitualItem { final String title; final String subtitle; final String slug; const _RitualItem(this.title, this.subtitle, this.slug); }

const List<_RitualItem> _popularRituals = [
  _RitualItem('Grih Shanti', 'House peace ritual', 'grih_pravesh'),
  _RitualItem('Mundan', 'Child head-shaving ceremony', 'mundan'),
  _RitualItem('Rudrabhishek', 'Ancient Shiva ritual', 'rudrabhishek'),
];
