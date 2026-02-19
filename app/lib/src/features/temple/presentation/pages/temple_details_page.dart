import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';

class TempleDetailsPage extends StatefulWidget {
  const TempleDetailsPage({super.key});

  @override
  State<TempleDetailsPage> createState() => _TempleDetailsPageState();
}

class _TempleDetailsPageState extends State<TempleDetailsPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

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
    final booking = BookingSession.current;
    final templeName = booking?.templeName ?? 'Selected Temple';
    final city = booking?.city ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          templeName,
          style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.midnight, AppColors.midnight.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Text(
                  templeName,
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.gold, fontSize: 28),
                ),
              ),
              const SizedBox(height: 8),
              _StaggeredFade(
                controller: _animController,
                delay: 200,
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.saffron, size: 18),
                    const SizedBox(width: 8),
                    Text(city, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream.withOpacity(0.6))),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _StaggeredFade(
                controller: _animController,
                delay: 400,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Temple',
                        style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This is a renowned temple where traditional Vedic poojas and havans are performed daily by experienced pandits in an authentic spiritual environment.',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8), height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _StaggeredFade(
                controller: _animController,
                delay: 600,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.gold, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Experience the divine energy directly from this sacred location.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream.withOpacity(0.9)),
                        ),
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
              context.push('/pandit-selection');
            },
            child: Text(
              'Continue Booking →',
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
