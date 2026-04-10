import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/home_booking/presentation/widgets/banner_carousel.dart';
import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/features/location/state/location_provider.dart';
import 'package:app/src/features/landing/state/recommendations_provider.dart';
import 'dart:async';
import 'package:app/src/features/pandit_onboarding/domain/pandit_profile.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';
import 'package:app/src/features/samagri_vendor/data/vendor_repository.dart';
import 'package:app/src/features/pandit_onboarding/data/pandit_repository_provider.dart';

const String kRouteLanding = '/landing';

// REMOVED: selectedLocationProvider (Moved to features/location/state/location_provider.dart)

class LandingEnhancedPage extends ConsumerWidget {
  const LandingEnhancedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(currentLocationProvider);
    final recommendationsAsync = ref.watch(recommendationsProvider);

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
            _buildLocationBar(context, ref, locationState),
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
                  ref.read(mainNavigationProvider.notifier).state = 2; // Shop tab
                  ref.read(bookingSessionProvider.notifier).reset();
                  ref.read(samagriSessionProvider.notifier).clear();
                  ref.read(samagriCartProvider.notifier).clearCart();
                  break;
                case _LandingAction.havanAtTemple:
                  context.push('/location-selection?type=temple');
                  break;
                case _LandingAction.explore:
                  context.push('/explore-services');
                  break;
              }
            }),

            const SizedBox(height: 32),
            // Dynamic Partner Banner Carousel
            Consumer(builder: (context, ref, _) {
              final user = ref.watch(supabaseUserProvider).value;
              final isAnon = user == null || user.isAnonymous;
              
              final panditProfileAsync = isAnon ? const AsyncData(null) : ref.watch(panditProfileFutureProvider(user.id));
              final vendorProfileAsync = isAnon ? const AsyncData(null) : ref.watch(vendorProfileFutureProvider);

              return panditProfileAsync.when(
                data: (pandit) => vendorProfileAsync.when(
                  data: (vendor) {
                    final List<Widget> banners = [];
                    if (pandit == null) banners.add(const _PanditRegistrationBanner());
                    if (vendor == null) banners.add(const _VendorRegistrationBanner());
                    
                    if (banners.isEmpty) return const SizedBox.shrink();
                    return _PartnerBannerCarousel(banners: banners);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            }),
            const SizedBox(height: 32),
            const BannerCarousel(),
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

            recommendationsAsync.when(
              data: (pandits) => pandits.isEmpty 
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No verified pandits found in ${locationState.city} yet.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pandits.length > 5 ? 5 : pandits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pandit = pandits[index];
                      return _RecommendedTile(
                        pandit: pandit,
                        onTap: () {
                          // 1. Pre-populate booking session with this Pandit
                          final currentDraft = ref.read(bookingSessionProvider).current ?? BookingDraft(
                            bookingType: BookingType.home,
                            ritualName: '',
                            city: locationState.city,
                          );
                          
                          final updatedDraft = currentDraft.copyWith(
                            panditId: pandit.id,
                            panditName: '${pandit.firstName} ${pandit.lastName}',
                            city: locationState.city,
                            area: locationState.area,
                          );
                          
                          ref.read(bookingSessionProvider.notifier).updateBookingDraft(updatedDraft);
                          
                          // 2. Navigate to services to pick a ritual
                          context.push('/services');
                        },
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
              error: (err, stack) => Text('Error loading recommendations: $err'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, WidgetRef ref, LocationState locationState) {
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
                      locationState.city, 
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locationState.area ?? 'Choose city or detect location', 
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
  final PanditProfile pandit;
  final VoidCallback onTap;
  const _RecommendedTile({Key? key, required this.pandit, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.saffron.withOpacity(0.08),
            shape: BoxShape.circle,
            image: pandit.profileImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(pandit.profileImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: pandit.profileImageUrl == null
              ? const Icon(Icons.person, color: AppColors.saffron)
              : null,
        ),
        title: Text(
          'Pandit — ${pandit.firstName} ${pandit.lastName}',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.darkCharcoal,
          ),
        ),
        subtitle: Text(
          '${pandit.ritualSlugs.isNotEmpty ? pandit.ritualSlugs.join(" • ") : "Certified Pandit"} • ${pandit.experienceYears} years experience',
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

class _PartnerBannerCarousel extends StatefulWidget {
  final List<Widget> banners;
  const _PartnerBannerCarousel({required this.banners});

  @override
  State<_PartnerBannerCarousel> createState() => _PartnerBannerCarouselState();
}

class _PartnerBannerCarouselState extends State<_PartnerBannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    if (widget.banners.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    if (widget.banners.length == 1) return widget.banners.first;

    return Column(
      children: [
        SizedBox(
          height: 220, // Adjusted height to prevent clipping
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: widget.banners[index],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 20 : 6,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _currentPage == index 
                    ? AppColors.saffron 
                    : AppColors.saffron.withOpacity(0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanditRegistrationBanner extends StatelessWidget {
  const _PanditRegistrationBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pandit-onboarding'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AppColors.saffron,
              AppColors.saffronSecondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PARTNER WITH US',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Are you a Pandit?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join our divine community and grow your reach.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Register Now →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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

class _RitualItem { final String title; final String subtitle; final String slug; const _RitualItem(this.title, this.subtitle, this.slug); }

const List<_RitualItem> _popularRituals = [
  _RitualItem('Grih Shanti', 'House peace ritual', 'grih_pravesh'),
  _RitualItem('Mundan', 'Child head-shaving ceremony', 'mundan'),
  _RitualItem('Rudrabhishek', 'Ancient Shiva ritual', 'rudrabhishek'),
];

class _VendorRegistrationBanner extends StatelessWidget {
  const _VendorRegistrationBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vendor-registration'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFB300), // Amber
              Color(0xFFF57C00), // Orange
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SHOP PARTNER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sacred Samagri Shop?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Partner with us to satisfy ritual requirements in your locality.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Register Shop →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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
