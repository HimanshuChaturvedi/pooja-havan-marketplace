import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/pandit/state/pandit_selection_provider.dart';
import '../../../../core/utils/ritual_slug_mapper.dart';
import '../../../pandit_onboarding/domain/pandit_profile.dart';

class PanditSelectionPage extends ConsumerStatefulWidget {
  final String templeName;

  const PanditSelectionPage({
    super.key,
    required this.templeName,
  });

  @override
  ConsumerState<PanditSelectionPage> createState() => _PanditSelectionPageState();
}

class _PanditSelectionPageState extends ConsumerState<PanditSelectionPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select Pandit',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Choose a Divine Guide',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _StaggeredFade(
              controller: _animController,
              delay: 200,
              child: Text(
                widget.templeName.isNotEmpty
                    ? 'Available pandits for ${widget.templeName}'
                    : 'Available authentic pandits for your pooja',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 32),

            _PanditList(animController: _animController),
          ],
        ),
      ),
    );
  }
}

class _PanditList extends ConsumerWidget {
  final AnimationController animController;
  const _PanditList({required this.animController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingSessionProvider).current;
    final city = booking?.city ?? '';
    
    final ritualSlug = RitualSlugMapper.getSlug(
      id: booking?.ritualId,
      name: booking?.ritualName,
    );
    
    debugPrint('DEBUG: Selection Search -> RitualSlug: $ritualSlug, City: $city');
    
    final panditsAsync = ref.watch(panditsByRitualProvider((ritualSlug: ritualSlug, city: city)));

    return panditsAsync.when(
      data: (pandits) {
        if (pandits.isEmpty) {
          return _EmptyPanditState(animController: animController);
        }

        return Column(
          children: List.generate(pandits.length, (index) {
            final pandit = pandits[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StaggeredFade(
                controller: animController,
                delay: 400 + (index * 150),
                child: _PanditCard(
                  name: '${pandit.firstName} ${pandit.lastName}',
                  experience: '${pandit.experienceYears}+ years experience',
                  profileImageUrl: pandit.profileImageUrl,
                  onTap: () {
                    // Update session with selected pandit
                    final current = ref.read(bookingSessionProvider).current;
                    if (current != null) {
                      ref.read(bookingSessionProvider.notifier).updateBookingDraft(
                        current.copyWith(
                          panditName: '${pandit.firstName} ${pandit.lastName}',
                          panditId: pandit.id,
                        ),
                      );
                    }
                    context.push('/home-date-time');
                  },
                ),
              ),
            );
          }),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

class _EmptyPanditState extends StatelessWidget {
  final AnimationController animController;
  const _EmptyPanditState({required this.animController});

  @override
  Widget build(BuildContext context) {
    return _StaggeredFade(
      controller: animController,
      delay: 400,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded, size: 64, color: AppColors.saffron),
            ),
            const SizedBox(height: 24),
            Text(
              'No Pandits Available',
              style: AppTextStyles.title.copyWith(fontSize: 20, color: AppColors.darkCharcoal),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We currently don\'t have verified Pandits for this ritual in your area. Be the first to join us!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Register as a Pandit',
              onTap: () => context.push('/pandit-onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanditCard extends StatelessWidget {
  final String name;
  final String experience;
  final String? profileImageUrl;
  final VoidCallback onTap;

  const _PanditCard({
    required this.name,
    required this.experience,
    this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.saffron.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.saffron.withOpacity(0.08),
                backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                child: profileImageUrl == null 
                  ? const Icon(Icons.person, color: AppColors.saffron, size: 28)
                  : null,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    experience,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.saffron,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffron),
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

  const _StaggeredFade({required this.controller, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final start = (delay / 1500).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1500).clamp(0, 1.0).toDouble();
        
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
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
