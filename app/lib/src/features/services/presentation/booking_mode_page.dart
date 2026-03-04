import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';

class BookingModePage extends StatefulWidget {
  static const routeName = '/booking-mode';
  const BookingModePage({super.key});

  @override
  State<BookingModePage> createState() => _BookingModePageState();
}

class _BookingModePageState extends State<BookingModePage> with SingleTickerProviderStateMixin {
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

  void _onModeSelected(BookingType type) {
    context.push('/location-selection?type=${type.name}');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Booking Mode',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _FadeSlide(
              controller: _animController,
              delay: 0,
              child: Text(
                "Kahan karwani hai Pooja?",
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _FadeSlide(
              controller: _animController,
              delay: 200,
              child: Text(
                "Select the sacred location to proceed",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ModeCard(
                        title: "At Home",
                        subtitle: "Sacred ritual at your residence",
                        icon: Icons.home_rounded,
                        controller: _animController,
                        delay: 400,
                        onTap: () => _onModeSelected(BookingType.home),
                      ),
                      const SizedBox(height: 24),
                      _ModeCard(
                        title: "At Temple",
                        subtitle: "Sacred ritual at a Temple",
                        icon: Icons.temple_hindu_rounded,
                        controller: _animController,
                        delay: 600,
                        onTap: () => _onModeSelected(BookingType.temple),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AnimationController controller;
  final int delay;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.controller,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _FadeSlide(
      controller: controller,
      delay: delay,
      child: GestureDetector(
        onTap: onTap,
        child: PrimaryCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.saffron),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final int delay;
  final Widget child;

  const _FadeSlide({required this.controller, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final start = (delay / 1200).clamp(0, 1.0).toDouble();
        final end = ((delay + 400) / 1200).clamp(0, 1.0).toDouble();
        final val = CurvedAnimation(parent: controller, curve: Interval(start, end, curve: Curves.easeOut)).value;
        return Opacity(
          opacity: val,
          child: Transform.translate(offset: Offset(0, 20 * (1 - val)), child: child),
        );
      },
    );
  }
}
