// lib/src/features/temple/presentation/pages/temple_list_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/shared/widgets/primary_button.dart';

class TempleListPage extends StatelessWidget {
  final String city;
  const TempleListPage({super.key, required this.city});

  List<Map<String, String>> sampleTemplesFor(String city) {
    if (city.toLowerCase().contains('haridwar')) {
      return [
        {'name': 'Har Ki Pauri', 'type': 'ghat'},
        {'name': 'Mansa Devi Temple', 'type': 'temple'},
        {'name': 'Chandi Devi Temple', 'type': 'temple'},
      ];
    } else if (city.toLowerCase().contains('varanasi') || city.toLowerCase().contains('banaras')) {
      return [
        {'name': 'Dashashwamedh Ghat', 'type': 'ghat'},
        {'name': 'Kashi Vishwanath', 'type': 'temple'},
      ];
    } else {
      return [
        {'name': '$city Main Temple', 'type': 'temple'},
        {'name': '$city Famous Ghat', 'type': 'ghat'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final temples = sampleTemplesFor(city);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: AppColors.saffron,
        centerTitle: true,
        title: Text(
          'Temples & Ghats in $city',
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        // ⭐ Global HOME button
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/landing'),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: temples.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = temples[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          t['type'] == 'ghat' ? Icons.water : Icons.account_balance,
                          color: AppColors.saffron,
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            t['name'] ?? '',
                            style: AppTextStyles.title.copyWith(fontSize: 16),
                          ),
                        ),

                        // ⭐ FIXED — Correct Navigation
                        PrimaryButton(
                          text: 'View Pandits',
                          onPressed: () {
                            final encoded = Uri.encodeComponent(t['name']!);
                            context.push('/pandits/$encoded');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
