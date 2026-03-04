import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';

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

    return AppScaffold(
      title: 'Book a Pooja',
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: AppColors.darkCharcoal),
          onPressed: () => context.go('/landing'),
        )
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Select a sacred ritual to proceed',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            ...List.generate(rituals.length, (index) {
              final ritual = rituals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StaggeredFade(
                  controller: _animController,
                  delay: 300 + (index * 80),
                  child: GestureDetector(
                    onTap: () {
                      final current = BookingSession.current;
                      if (current != null) {
                        current.ritualName = ritual['name']!;
                      } else {
                        BookingSession.current = BookingDraft(
                          bookingType: entryType == 'temple' ? BookingType.temple : BookingType.home,
                          ritualName: ritual['name']!,
                          city: '',
                        );
                      }
                      context.push('/service/${ritual['slug']}/${Uri.encodeComponent(ritual['name']!)}');
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
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              color: AppColors.saffron,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              ritual['name']!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColors.darkCharcoal,
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
                  ),
                ),
              );
            }),
          ],
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
