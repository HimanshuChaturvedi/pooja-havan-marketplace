// lib/src/features/pandit/presentation/pages/pandit_list_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';

class PanditListPage extends StatelessWidget {
  final String templeName;

  const PanditListPage({
    super.key,
    required this.templeName,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pandits = [
      {"name": "Pandit Ram Sharma", "experience": "12 years experience"},
      {"name": "Pandit Suresh Trivedi", "experience": "18 years experience"},
      {"name": "Pandit Mohan Joshi", "experience": "9 years experience"},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
  backgroundColor: AppColors.saffron,
  centerTitle: true,
  title: Text(
    "Pandits at $templeName",
    style: AppTextStyles.title.copyWith(
      color: AppColors.white,
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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pandits.length,
        itemBuilder: (context, i) {
          final p = pandits[i];

          return Container(
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
                Icon(Icons.person, size: 36, color: AppColors.primaryGold),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FIXED: Using titleLarge instead of titleMedium
                      Text(
                        p["name"]!,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        p["experience"]!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
