import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class LocationPage extends ConsumerStatefulWidget {
  final String ritualSlug;
  final String ritualName;

  const LocationPage({
    super.key,
    required this.ritualSlug,
    required this.ritualName,
  });

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  static const String _pilotCity = 'Ghaziabad';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      title: 'Location Selection',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                "Preparing ritual for ${widget.ritualName}",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 📍 PILOT NOTICE
            _StaggeredFade(
              controller: _animController,
              delay: 300,
              child: PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.saffron, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Special Pilot Service',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.darkCharcoal, 
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bharat Pooja Setu services are currently being piloted exclusively in Ghaziabad for the highest quality experience.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkCharcoal.withOpacity(0.8), 
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            _StaggeredFade(
              controller: _animController,
              delay: 500,
              child: Text(
                'Current City',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.darkCharcoal, 
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _StaggeredFade(
              controller: _animController,
              delay: 700,
              child: PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.saffron, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _pilotCity,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uttar Pradesh, India',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.softGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Continue to Booking →',
          onTap: () {
            final draft = BookingDraft(
              bookingType: BookingType.home,
              ritualName: widget.ritualName,
              ritualId: widget.ritualSlug,
              city: _pilotCity,
            );
            ref.read(bookingSessionProvider.notifier).updateBookingDraft(draft);
            context.push('/at-home-or-temple');
          },
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
        final start = (delay / 1200).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1200).clamp(0, 1.0).toDouble();
        
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
