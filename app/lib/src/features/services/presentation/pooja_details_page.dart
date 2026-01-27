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
            _detailsCard(details),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: () {
                context.push(
                  '/location/$poojaSlug/${Uri.encodeComponent(poojaName)}',
                );
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

  Widget _detailsCard(Map<String, String>? details) {
    return Container(
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
          Text(
            details?['description'] ?? '',
            style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
          ),
          const SizedBox(height: 18),
          _infoRow(Icons.timelapse, "Duration", details?['duration'] ?? ''),
          const SizedBox(height: 12),
          _infoRow(Icons.check_circle, "Samagri Required", details?['samagri'] ?? ''),
          const SizedBox(height: 12),
          _infoRow(
            Icons.currency_rupee,
            "Dakshina / Charges",
            "As per location & pandit availability",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
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
// 🔒 FINAL DETAILS MAP – ALIGNED WITH SERVICES PAGE
// ----------------------------------------------------------------------

final Map<String, Map<String, String>> _poojaDetails = {
  'grih_pravesh': {
    'description':
        'Performed before entering a new home to invite peace, prosperity, and divine blessings.',
    'duration': '1.5 – 2 hours',
    'samagri': 'Kalash, Mango Leaves, Ghee, Havan Samagri, Flowers',
  },
  'satyanarayan_katha': {
    'description':
        'A sacred katha performed to express gratitude and seek prosperity and family harmony.',
    'duration': '2 – 3 hours',
    'samagri': 'Fruits, Panchamrit, Flowers, Katha Book, Prasad Items',
  },
  'lakshmi_ganesh': {
    'description':
        'Performed for wealth, success, and auspicious beginnings in home or business.',
    'duration': '60 – 90 minutes',
    'samagri': 'Flowers, Diya, Ghee, Sweets, Pooja Samagri',
  },
  'havan_navgrah': {
    'description':
        'A fire ritual for grah shanti, positivity, and removal of negative influences.',
    'duration': '60 – 90 minutes',
    'samagri': 'Havan Kund, Samagri, Ghee, Camphor, Cotton Wicks',
  },
  'mundan': {
    'description':
        'A child’s first haircut ceremony performed for health, longevity, and purification.',
    'duration': '45 – 60 minutes',
    'samagri': 'Havan Samagri, Kalash, Flowers, Ghee, Rice, Coconut',
  },
  'naamkaran': {
    'description':
        'Naming ceremony performed for newborns as per Hindu traditions.',
    'duration': '45 – 60 minutes',
    'samagri': 'Kalash, Flowers, Rice, Panchamrit, Pooja Samagri',
  },
  'rudrabhishek': {
    'description':
        'A sacred abhishek of Lord Shiva performed for peace, health, and success.',
    'duration': '60 – 90 minutes',
    'samagri': 'Milk, Water, Bilva Patra, Flowers, Rudraksha',
  },
  'pitru_shanti': {
    'description':
        'Performed to seek blessings of ancestors and resolve ancestral issues.',
    'duration': '1.5 – 2 hours',
    'samagri': 'Til, Kush, Rice, Ghee, Pinda Samagri',
  },
  'vastu_shanti': {
    'description':
        'A ritual to remove vastu dosh and bring harmony to living or working spaces.',
    'duration': '1.5 – 2 hours',
    'samagri': 'Kalash, Havan Samagri, Flowers, Rice, Ghee',
  },
  'office_opening': {
    'description':
        'Performed before starting business operations to ensure success and growth.',
    'duration': '45 – 60 minutes',
    'samagri': 'Flowers, Diya, Coconut, Sweets, Pooja Samagri',
  },
};
