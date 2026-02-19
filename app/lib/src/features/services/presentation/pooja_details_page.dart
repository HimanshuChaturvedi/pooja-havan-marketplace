import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class PoojaDetailsPage extends StatefulWidget {
  final String poojaName;
  final String poojaSlug;

  const PoojaDetailsPage({
    super.key,
    required this.poojaName,
    required this.poojaSlug,
  });

  @override
  State<PoojaDetailsPage> createState() => _PoojaDetailsPageState();
}

class _PoojaDetailsPageState extends State<PoojaDetailsPage> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final details = _poojaDetails[widget.poojaSlug];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.poojaName,
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go('/landing'),
          )
        ],
      ),
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: DivineGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: details == null
                      ? const Text('Details will be updated soon.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pooja Overview',
                              style: AppTextStyles.title.copyWith(
                                fontSize: 18,
                                color: AppColors.maroon,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              details['description']!,
                              style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              if (details != null)
                _StaggeredFade(
                  controller: _animController,
                  delay: 300,
                  child: DivineGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _infoRow(
                          icon: Icons.timer_outlined,
                          title: 'Duration',
                          value: details['duration']!,
                        ),
                        const Divider(height: 32, color: Colors.black12),
                        _infoRow(
                          icon: Icons.inventory_2_outlined,
                          title: 'Samagri',
                          value: details['samagri']!,
                        ),
                        const Divider(height: 32, color: Colors.black12),
                        _infoRow(
                          icon: Icons.payments_outlined,
                          title: 'Dakshina',
                          value: details['fees']!,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _StaggeredFade(
                controller: _animController,
                delay: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '*Final dakshina may vary based on city & pandit availability',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.maroon.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              shadowColor: AppColors.saffron.withOpacity(0.4),
            ),
            onPressed: () {
              context.push(
                '/location/${widget.poojaSlug}/${Uri.encodeComponent(widget.poojaName)}',
              );
            },
            child: Text(
              'Select Location →',
              style: AppTextStyles.button.copyWith(fontSize: 18, color: Colors.white),
            ),
          ),
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
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.saffron.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.deepSaffron, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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
