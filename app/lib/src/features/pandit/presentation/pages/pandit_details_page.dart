import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/core/widgets/design_system.dart';

class PanditDetailsPage extends StatefulWidget {
  final String panditName;
  const PanditDetailsPage({super.key, required this.panditName});

  @override
  State<PanditDetailsPage> createState() => _PanditDetailsPageState();
}

class _PanditDetailsPageState extends State<PanditDetailsPage> with SingleTickerProviderStateMixin {
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
                    _infoSection(title: 'Experience', value: '12+ years of experience in Vedic rituals'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                    _infoSection(title: 'Specialization', value: 'Grih Pravesh, Havan, Satyanarayan Katha, Marriage Rituals'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                    _infoSection(title: 'Languages', value: 'Hindi, Sanskrit'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                    _infoSection(title: 'Education', value: 'Shastri from Kashi Vidyapeeth'),
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
            BookingSession.current?.panditName = widget.panditName;
            context.push('/home-date-time');
          },
        ),
      ),
    );
  }

  Widget _infoSection({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: AppTextStyles.title.copyWith(
            color: AppColors.saffron, 
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value, 
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkCharcoal, 
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
