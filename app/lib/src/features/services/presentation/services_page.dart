import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

import '../../booking/application/booking_session.dart';
import '../../booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class ServicesPage extends StatefulWidget {
  static const routeName = '/services';
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
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

  // 🔒 WEST UP – FINAL 11 POOJA (PILOT READY)
  List<Map<String, String>> get rituals => const [
        {'name': 'Griha Pravesh Pooja', 'slug': 'grih_pravesh'},
        {'name': 'Satyanarayan Katha', 'slug': 'satyanarayan_katha'},
        {'name': 'Lakshmi Ganesh Pooja', 'slug': 'lakshmi_ganesh'},
        {'name': 'Havan / Navgrah Shanti Pooja', 'slug': 'havan_navgrah'},
        {'name': 'Mundan Sanskar', 'slug': 'mundan'},
        {'name': 'Naamkaran Sanskar', 'slug': 'naamkaran'},
        {'name': 'Rudrabhishek (Shiv Pooja)', 'slug': 'rudrabhishek'},
        {'name': 'Pitru Shanti Pooja', 'slug': 'pitru_shanti'},
        {'name': 'Vastu Shanti Pooja', 'slug': 'vastu_shanti'},
        {'name': 'Office / Shop Opening Pooja', 'slug': 'office_opening'},
        {'name': 'Ekadashi Udyapan', 'slug': 'ekadashi_udyapan'},
      ];

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final entryType = uri.queryParameters['type']; // home | temple | null

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.12), // Subtle glass base
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          'Book a Pooja',
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/landing'),
          )
        ],
      ),
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
                  'Select a sacred ritual to proceed',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.deepSaffron),
                ),
              ),
              const SizedBox(height: 24),

              ...List.generate(rituals.length, (index) {
                final ritual = rituals[index];
                return _StaggeredFade(
                  controller: _animController,
                  delay: 300 + (index * 100),
                  child: DivineGlassCard(
                    onTap: () {
                      BookingSession.current = BookingDraft(
                        bookingType: entryType == 'temple' ? BookingType.temple : BookingType.home,
                        ritualName: ritual['name']!,
                        city: '',
                      );
                      context.push('/service/${ritual['slug']}/${Uri.encodeComponent(ritual['name']!)}');
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.deepSaffron,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            ritual['name']!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: AppColors.maroon,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.saffron,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
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
