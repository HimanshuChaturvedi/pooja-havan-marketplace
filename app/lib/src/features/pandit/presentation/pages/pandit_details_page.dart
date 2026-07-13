import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/core/widgets/design_system.dart';

import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';

class PanditDetailsPage extends ConsumerStatefulWidget {
  final String panditName;
  const PanditDetailsPage({super.key, required this.panditName});

  @override
  ConsumerState<PanditDetailsPage> createState() => _PanditDetailsPageState();
}

class _PanditDetailsPageState extends ConsumerState<PanditDetailsPage> with SingleTickerProviderStateMixin {
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
      title: 'Pandit Details',
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: AppColors.darkCharcoal),
          onPressed: () {
            ref.read(mainNavigationProvider.notifier).state = 0;
            context.go('/home');
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.darkCharcoal),
          onPressed: () {
            ref.read(mainNavigationProvider.notifier).state = 3;
            context.go('/home');
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      border: Border.all(color: AppColors.saffron.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.saffron.withOpacity(0.08),
                      child: const Icon(Icons.person, size: 50, color: AppColors.saffron),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.panditName, 
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.saffron, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '4.8 (120 reviews)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.saffron,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            _StaggeredFade(
              controller: _animController,
              delay: 400,
              child: PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const _InfoSection(
                      title: 'Experience',
                      value: '12+ years of experience in Vedic rituals',
                    ),
                    const _Divider(),
                    const _InfoSection(
                      title: 'Specialization',
                      value: 'Grih Pravesh, Havan, Satyanarayan Katha, Marriage Rituals',
                    ),
                    const _Divider(),
                    const _InfoSection(
                      title: 'Languages',
                      value: 'Hindi, Sanskrit',
                    ),
                    const _Divider(),
                    const _InfoSection(
                      title: 'Education',
                      value: 'Shastri from Kashi Vidyapeeth',
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
          label: 'Select ${widget.panditName} →',
          onTap: () {
            final current = ref.read(bookingSessionProvider).current;
            if (current != null) {
              final updated = current.copyWith(panditName: widget.panditName);
              ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
            }
            context.push('/home-date-time');
          },
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String value;
  const _InfoSection({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: AppColors.saffron,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkCharcoal,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: Colors.black12, height: 1),
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
