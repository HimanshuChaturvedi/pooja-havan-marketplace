import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';
import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class LocationPage extends StatefulWidget {
  final String ritualSlug;
  final String ritualName;

  const LocationPage({
    super.key,
    required this.ritualSlug,
    required this.ritualName,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Text(
                  "Preparing ritual for ${widget.ritualName}",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.deepSaffron),
                ),
              ),

              const SizedBox(height: 32),

              // 📍 PILOT NOTICE (GLASS STYLE)
              _StaggeredFade(
                controller: _animController,
                delay: 300,
                child: DivineGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.deepSaffron, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Special Pilot Service',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bharat Pooja Setu services are currently being piloted exclusively in Ghaziabad for the highest quality experience.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon.withOpacity(0.8), height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              _StaggeredFade(
                controller: _animController,
                delay: 500,
                child: Text(
                  'Current Location',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),

              _StaggeredFade(
                controller: _animController,
                delay: 700,
                child: DivineGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.deepSaffron, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pilotCity,
                            style: AppTextStyles.title.copyWith(fontSize: 20),
                          ),
                          Text(
                            'Uttar Pradesh, India',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.deepSaffron.withOpacity(0.6)),
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.midnight.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: AppColors.saffron.withOpacity(0.5),
            ),
            onPressed: () {
              BookingSession.current = BookingDraft(
                bookingType: BookingType.home,
                ritualName: widget.ritualName,
                city: _pilotCity,
              );
              context.push('/at-home-or-temple');
            },
            child: Text(
              'Continue to Booking →',
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
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
