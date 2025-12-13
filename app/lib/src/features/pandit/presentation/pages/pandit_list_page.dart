import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: AppColors.saffron,
        centerTitle: true,
        title: Text(
          'Pandits at $templeName',
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/landing'),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: pandits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = pandits[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 30, color: Colors.deepOrange),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['name']!,
                          style: AppTextStyles.title.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Experience: ${p['experience']}',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  ),

                  PrimaryButton(
                    text: 'Select',
                    onPressed: () {
                      // NEXT STEP (later): Booking / Schedule page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pandit selected')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
