import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

import '../../booking/application/booking_session.dart';
import '../../booking/domain/booking_draft.dart';

class ServicesPage extends StatelessWidget {
  static const routeName = '/services';

  const ServicesPage({super.key});

  // 🔒 WEST UP – FINAL 10 POOJA (PILOT READY)
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
      ];

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final entryType = uri.queryParameters['type']; // home | temple | null

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.saffron,
        centerTitle: true,
        title: Text(
          'Book a Pooja',
          style: AppTextStyles.title.copyWith(
            color: AppColors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/landing'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a pooja to proceed',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textDark,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),

            ...rituals.map((ritual) {
              return _RitualCard(
                title: ritual['name']!,
                onTap: () {
                  BookingSession.current = BookingDraft(
                    bookingType: entryType == 'temple'
                        ? BookingType.temple
                        : BookingType.home,
                    ritualName: ritual['name']!,
                    city: '',
                  );

                  context.push(
                    '/service/${ritual['slug']}/${Uri.encodeComponent(ritual['name']!)}',
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RitualCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RitualCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: AppColors.primaryGold,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
