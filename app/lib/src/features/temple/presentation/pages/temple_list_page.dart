import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Temples in ${widget.city}',
          style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 20),
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
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          itemCount: temples.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Select a sacred location for your prayers",
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream.withOpacity(0.6)),
                  ),
                ),
              );
            }
            final t = temples[index - 1];
            final templeName = t['name'] ?? 'Selected Temple';

            return _StaggeredFade(
              controller: _animController,
              delay: 200 + (index * 150),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(t['type'] == 'ghat' ? Icons.water : Icons.account_balance, color: AppColors.saffron, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(templeName, style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(t['type']!.toUpperCase(), style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold.withOpacity(0.7), letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron.withOpacity(0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        BookingSession.current?.bookingType = BookingType.temple;
                        BookingSession.current?.templeName = templeName;
                        BookingSession.current?.city = widget.city;
                        context.push('/temple-details');
                      },
                      child: const Text('View →', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
