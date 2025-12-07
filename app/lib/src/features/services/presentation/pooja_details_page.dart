// lib/src/features/services/presentation/pooja_details_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

class PoojaDetailsPage extends StatelessWidget {
  static const routeName = '/service';

  final String poojaName;
  final String poojaSlug;

  const PoojaDetailsPage({
    super.key,
    required this.poojaName,
    required this.poojaSlug,
  });

  @override
  Widget build(BuildContext context) {
    final details = _poojaDetails[poojaSlug];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
  elevation: 0,
  backgroundColor: AppColors.saffron,
  centerTitle: true,
  title: Text(
    poojaName,
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------ CARD ------------------------------
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: AppColors.primaryGold, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          poojaName,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    details?['description'] ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _infoRow(
                    icon: Icons.timelapse,
                    title: "Duration",
                    value: details?['duration'] ?? '',
                  ),

                  const SizedBox(height: 12),

                  _infoRow(
                    icon: Icons.check_circle,
                    title: "Samagri Required",
                    value: details?['samagri'] ?? '',
                  ),

                  const SizedBox(height: 12),

                  _infoRow(
                    icon: Icons.currency_rupee,
                    title: "Dakshina / Charges",
                    value: "As per location & pandit availability",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ------------------------- Proceed Button -------------------------
            GestureDetector(
              onTap: () {
                context.push('/location/$poojaSlug/${Uri.encodeComponent(poojaName)}');

              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Proceed to Location Selection",
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------- Info Row Widget ---------------------------
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$title: ",
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// STATIC POOJA DETAILS
// ----------------------------------------------------------------------

final Map<String, Map<String, String>> _poojaDetails = {
  'mundan': {
    'description':
        'Mundan Sanskar is an important Hindu ritual performed for children. It purifies the child and blesses them with long life and prosperity.',
    'duration': '45 – 60 minutes',
    'samagri': 'Havan Samagri, Kalash, Flowers, Ghee, Rice, Coconut',
  },
  'grih_pravesh': {
    'description':
        'Performed before entering a new home. This ritual brings peace, positivity, and divine blessings to the household.',
    'duration': '1.5 – 2 hours',
    'samagri': 'Kalash, Mango Leaves, Ghee, Havan Samagri, Flowers',
  },
  'havan': {
    'description':
        'A sacred fire ritual performed to purify surroundings and invite positive energy. Suitable for all auspicious events.',
    'duration': '60 – 90 minutes',
    'samagri': 'Havan Kund, Samagri, Ghee, Camphor, Cotton Wicks',
  },
  'katha': {
    'description':
        'A devotional ritual performed to express gratitude and seek blessings. Suitable for all auspicious occasions.',
    'duration': '2 – 3 hours',
    'samagri': 'Fruits, Panchamrit, Flowers, Katha Book, Prasad Items',
  },
  'marriage': {
    'description':
        'Marriage rituals include essential sacred rites performed for the couple as per tradition.',
    'duration': 'As per ritual requirements',
    'samagri': 'Kalash, Flowers, Coconut, Mangal Sutra, Pooja Samagri',
  },
};
