import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';

class TempleListPage extends StatefulWidget {
  final String city;
  const TempleListPage({super.key, required this.city});

  @override
  State<TempleListPage> createState() => _TempleListPageState();
}

class _TempleListPageState extends State<TempleListPage> with SingleTickerProviderStateMixin {
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
    final temples = _sampleTemplesFor(widget.city);

    return AppScaffold(
      title: 'Temples in ${widget.city}',
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: temples.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "Select a sacred location for your prayers",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.softGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }
          final t = temples[index - 1];
          final templeName = t['name'] ?? 'Selected Temple';

          return _StaggeredFade(
            controller: _animController,
            delay: 200 + (index * 150),
            child: GestureDetector(
              onTap: () {
                BookingSession.current?.bookingType = BookingType.temple;
                BookingSession.current?.templeName = templeName;
                BookingSession.current?.city = widget.city;
                context.push('/temple-details');
              },
              child: PrimaryCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        t['type'] == 'ghat' ? Icons.water : Icons.temple_hindu_rounded, 
                        color: AppColors.saffron, 
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            templeName, 
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800, 
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t['type']!.toUpperCase(), 
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.saffron, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.saffron, size: 14),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _sampleTemplesFor(String city) {
    final c = city.toLowerCase();
    if (c.contains('haridwar')) {
      return [
        {'name': 'Har Ki Pauri', 'type': 'ghat'},
        {'name': 'Mansa Devi Temple', 'type': 'temple'},
        {'name': 'Chandi Devi Temple', 'type': 'temple'},
      ];
    }
    return [
      {'name': '$city Main Temple', 'type': 'temple'},
      {'name': '$city Famous Ghat', 'type': 'ghat'},
    ];
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
