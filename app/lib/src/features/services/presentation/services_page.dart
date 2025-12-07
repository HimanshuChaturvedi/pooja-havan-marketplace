import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

class ServicesPage extends StatelessWidget {

  static const routeName = '/services';

  const ServicesPage({super.key});

  // Ritual list
  List<Map<String, String>> get rituals => [
        {'name': 'Mundan Ceremony', 'slug': 'mundan'},
        {'name': 'Grih Pravesh Pooja', 'slug': 'grih_pravesh'},
        {'name': 'Havan / Homam', 'slug': 'havan'},
        {'name': 'Katha', 'slug': 'katha'},
        {'name': 'Marriage Rituals', 'slug': 'marriage'},
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
  elevation: 0,
  backgroundColor: AppColors.saffron,
  centerTitle: true,
  title: Text(
    'Service Categories',
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
              'Choose a ritual to proceed',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textDark,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 16),

            // Ritual List
            ...rituals.map((ritual) {
              return _RitualCard(
                title: ritual['name']!,
                slug: ritual['slug']!,
                onTap: () {
                  final slug = ritual['slug']!;
                  final name = ritual['name']!;

                  /// FIXED ROUTING
                  context.push(
                    '/service/$slug/${Uri.encodeComponent(name)}',
                  );
                },
              );
            }),

            const SizedBox(height: 10),

            // More Services
            _RitualCard(
              title: "More Services",
              slug: "more",
              onTap: () {
                context.push(
                  '/service/more/${Uri.encodeComponent("More Services")}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Card UI
class _RitualCard extends StatelessWidget {
  final String title;
  final String slug;
  final VoidCallback onTap;

  const _RitualCard({
    required this.title,
    required this.slug,
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
            Icon(Icons.local_fire_department,
                color: AppColors.primaryGold, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
