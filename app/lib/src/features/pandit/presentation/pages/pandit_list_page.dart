import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class PanditListPage extends StatelessWidget {
  final String templeName;

  const PanditListPage({
    super.key,
    required this.templeName,
  });

  // Temporary static pandit list (later DB)
  List<Map<String, String>> get pandits => [
        {
          'name': 'Pandit Ram Sharma',
          'experience': '15 years',
        },
        {
          'name': 'Pandit Anil Mishra',
          'experience': '10 years',
        },
        {
          'name': 'Pandit Suresh Tiwari',
          'experience': '20 years',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pandits at $templeName',
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: pandits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final p = pandits[index];

          return GestureDetector(
            onTap: () {
              context.push('/pandit-details', extra: p['name']);
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
                    child: const Icon(Icons.person, color: AppColors.saffron, size: 28),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['name']!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Experience: ${p['experience']}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.saffron,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.saffron, size: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
