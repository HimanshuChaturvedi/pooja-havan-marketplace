import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class TempleRitualPage extends StatefulWidget {
  final String temple;
  final String city;
  const TempleRitualPage({super.key, required this.temple, required this.city});

  @override
  State<TempleRitualPage> createState() => _TempleRitualPageState();
}

class _TempleRitualPageState extends State<TempleRitualPage> {
  String? _selectedRitual;

  static const List<Map<String, String>> _rituals = [
    {'name': 'Rudrabhishek', 'duration': '~90 min', 'price': '₹2,100'},
    {'name': 'Ganesh Pooja', 'duration': '~60 min', 'price': '₹1,500'},
    {'name': 'Satyanarayan Katha', 'duration': '~120 min', 'price': '₹2,500'},
    {'name': 'Sundarkand Path', 'duration': '~90 min', 'price': '₹1,800'},
    {'name': 'Mahamrityunjaya Jaap', 'duration': '~45 min', 'price': '₹1,100'},
    {'name': 'Navgrah Shanti', 'duration': '~60 min', 'price': '₹2,000'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select Ritual',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Rituals',
              style: AppTextStyles.title.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'at ${widget.temple}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
            ),
            const SizedBox(height: 24),
            ...List.generate(_rituals.length, (index) {
              final ritual = _rituals[index];
              final isSelected = _selectedRitual == ritual['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRitual = ritual['name']),
                  child: PrimaryCard(
                    padding: const EdgeInsets.all(20),
                    color: isSelected ? AppColors.saffron.withOpacity(0.06) : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department_rounded, color: AppColors.saffron, size: 24),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ritual['name']!,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ritual['duration']} • ${ritual['price']}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.softGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.saffron, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          label: 'Continue →',
          onTap: _selectedRitual != null
              ? () => context.push(
                    '/temple-date?temple=${Uri.encodeComponent(widget.temple)}&city=${widget.city}&ritual=${Uri.encodeComponent(_selectedRitual!)}',
                  )
              : null,
        ),
      ),
    );
  }
}
