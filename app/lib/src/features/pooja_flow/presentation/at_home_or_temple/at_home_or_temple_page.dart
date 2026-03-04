import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'widgets/choice_card.dart';

enum PoojaLocationType { home, temple }

class AtHomeOrTemplePage extends StatefulWidget {
  final String city;
  final String ritualSlug;
  final String ritualName;

  const AtHomeOrTemplePage({
    super.key,
    required this.city,
    required this.ritualSlug,
    required this.ritualName,
  });

  @override
  State<AtHomeOrTemplePage> createState() => _AtHomeOrTemplePageState();
}

class _AtHomeOrTemplePageState extends State<AtHomeOrTemplePage> with SingleTickerProviderStateMixin {
  PoojaLocationType? selectedType;
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
    return AppScaffold(
      title: 'Location Preference',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Where would you like to perform the ritual?',
                style: AppTextStyles.title.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _StaggeredFade(
              controller: _animController,
              delay: 200,
              child: Text(
                'Choose the sacred setting that suits you best.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 48),

            _StaggeredFade(
              controller: _animController,
              delay: 400,
              child: ChoiceCard(
                title: 'At Home',
                description: 'Pandit will visit your home with sacred items to perform the pooja.',
                isSelected: selectedType == PoojaLocationType.home,
                onTap: () {
                  setState(() {
                    selectedType = PoojaLocationType.home;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            _StaggeredFade(
              controller: _animController,
              delay: 600,
              child: ChoiceCard(
                title: 'At Temple',
                description: 'Perform the pooja at a nearby or selected temple of your choice.',
                isSelected: selectedType == PoojaLocationType.temple,
                onTap: () {
                  setState(() {
                    selectedType = PoojaLocationType.temple;
                  });
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Continue →',
          onTap: selectedType == null
              ? null
              : () {
                  if (BookingSession.current == null) return;

                  if (selectedType == PoojaLocationType.home) {
                    BookingSession.current!.bookingType = BookingType.home;
                    context.push('/home-address');
                  } else {
                    BookingSession.current!.bookingType = BookingType.temple;
                    final city = Uri.encodeComponent(widget.city);
                    context.push('/temples/$city');
                  }
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
