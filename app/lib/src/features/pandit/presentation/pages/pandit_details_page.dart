import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';
import '../../../booking/application/booking_session.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Pandit Details',
          style: AppTextStyles.title.copyWith(color: AppColors.maroon, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 120),
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
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.saffron, width: 2)),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.saffron.withOpacity(0.12),
                        child: const Icon(Icons.person, size: 50, color: AppColors.deepSaffron),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.panditName, style: AppTextStyles.titleLarge.copyWith(fontSize: 26)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.saffron, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 (120 reviews)',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.deepSaffron),
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
                child: DivineGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _infoSection(title: 'Experience', value: '12+ years of experience in Vedic rituals'),
                      const Divider(color: Colors.black12, height: 32),
                      _infoSection(title: 'Specialization', value: 'Grih Pravesh, Havan, Satyanarayan Katha, Marriage Rituals'),
                      const Divider(color: Colors.black12, height: 32),
                      _infoSection(title: 'Languages', value: 'Hindi, Sanskrit'),
                      const Divider(color: Colors.black12, height: 32),
                      _infoSection(title: 'Education', value: 'Shastri from Kashi Vidyapeeth'),
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
              BookingSession.current?.panditName = widget.panditName;
              context.push('/home-date-time');
            },
            child: Text(
              'Select ${widget.panditName} →',
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoSection({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title.copyWith(color: AppColors.deepSaffron, fontSize: 16)),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon.withOpacity(0.8), height: 1.4)),
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
