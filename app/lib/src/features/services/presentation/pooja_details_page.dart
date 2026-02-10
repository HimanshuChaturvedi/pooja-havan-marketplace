import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

class PoojaDetailsPage extends StatelessWidget {
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
        backgroundColor: AppColors.saffron,
        centerTitle: true,
        title: Text(
          poojaName,
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
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
              child: details == null
                  ? const Text(
                      'Details will be updated soon.',
                      style: TextStyle(fontSize: 16),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details['description']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _infoRow(
                          icon: Icons.timelapse,
                          title: 'Duration',
                          value: details['duration']!,
                        ),
                        const SizedBox(height: 12),

                        _infoRow(
                          icon: Icons.check_circle,
                          title: 'Samagri Required',
                          value: details['samagri']!,
                        ),
                        const SizedBox(height: 12),

                        _infoRow(
                          icon: Icons.currency_rupee,
                          title: 'Pandit Ji Fees (Indicative)',
                          value: details['fees']!,
                        ),

                        const SizedBox(height: 8),
                        Text(
                          '*Final dakshina may vary based on city & pandit availability',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
            ),

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
                    'Proceed to Location Selection',
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
              text: '$title: ',
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
// FINAL POOJA DETAILS — EXACT MATCH WITH ServicesPage (+ Ekadashi Added)
// ----------------------------------------------------------------------

final Map<String, Map<String, String>> _poojaDetails = {
  'grih_pravesh': {
    'description':
        'Griha Pravesh Pooja is performed before entering a new home to bring peace, prosperity and positive energy.',
    'duration': '90 – 120 minutes',
    'samagri': 'Kalash, Ghee, Havan Samagri, Flowers',
    'fees': '₹1,500 – ₹2,500',
  },
  'satyanarayan_katha': {
    'description':
        'Satyanarayan Katha is performed to seek blessings for harmony, prosperity and well-being of the family.',
    'duration': '2 – 3 hours',
    'samagri': 'Katha Book, Panchamrit, Fruits, Flowers',
    'fees': '₹1,500 – ₹2,500',
  },
  'lakshmi_ganesh': {
    'description':
        'Lakshmi Ganesh Pooja is performed for wealth, success and removal of obstacles, especially on auspicious occasions.',
    'duration': '60 – 90 minutes',
    'samagri': 'Ganesh & Lakshmi Pooja Samagri, Sweets, Flowers',
    'fees': '₹1,500 – ₹2,500',
  },
  'havan_navgrah': {
    'description':
        'Havan and Navgraha Shanti Pooja are performed to purify the environment and balance planetary influences.',
    'duration': '90 – 120 minutes',
    'samagri': 'Havan Kund, Navgraha Samagri, Ghee',
    'fees': '₹1,500 – ₹2,500',
  },
  'mundan': {
    'description':
        'Mundan Sanskar is a child purification ritual performed for good health and long life.',
    'duration': '45 – 60 minutes',
    'samagri': 'Havan Samagri, Coconut, Flowers',
    'fees': '₹1,500 – ₹2,500',
  },
  'naamkaran': {
    'description':
        'Naamkaran Sanskar is the naming ceremony performed for newborns as per Hindu tradition.',
    'duration': '45 – 60 minutes',
    'samagri': 'Kalash, Rice, Flowers',
    'fees': '₹1,500 – ₹2,500',
  },
  'rudrabhishek': {
    'description':
        'Rudrabhishek is a sacred Shiva Pooja performed to seek health, peace and spiritual growth.',
    'duration': '60 – 90 minutes',
    'samagri': 'Shiv Pooja Samagri, Milk, Bel Patra',
    'fees': '₹1,500 – ₹2,500',
  },
  'pitru_shanti': {
    'description':
        'Pitru Shanti Pooja is performed to seek blessings of ancestors and remove ancestral obstacles.',
    'duration': '90 – 120 minutes',
    'samagri': 'Pitru Pooja Samagri, Til, Rice',
    'fees': '₹1,500 – ₹2,500',
  },
  'vastu_shanti': {
    'description':
        'Vastu Shanti Pooja is performed to correct Vastu doshas and bring harmony to home or workplace.',
    'duration': '90 – 120 minutes',
    'samagri': 'Vastu Pooja Samagri, Havan Items',
    'fees': '₹1,500 – ₹2,500',
  },
  'office_opening': {
    'description':
        'Office or Shop Opening Pooja is performed before starting a new business venture.',
    'duration': '60 – 90 minutes',
    'samagri': 'Ganesh Pooja Samagri, Kalash, Flowers',
    'fees': '₹1,500 – ₹2,500',
  },
  'ekadashi_udyapan': {
    'description':
        'Ekadashi Udyapan is performed after completion of Ekadashi vrat to conclude the observance as per rituals.',
    'duration': '90 – 120 minutes',
    'samagri': 'Vishnu Pooja Samagri, Tulsi, Panchamrit',
    'fees': '₹1,500 – ₹2,500',
  },
};
