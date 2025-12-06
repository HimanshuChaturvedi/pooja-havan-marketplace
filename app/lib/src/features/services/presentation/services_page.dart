// lib/src/features/services/presentation/services_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

class ServicesPage extends StatelessWidget {
  static const routeName = '/services';

  const ServicesPage({super.key});

  // Default 6 services (label and a slug used in routing)
  static final List<_ServiceItem> defaultServices = [
    _ServiceItem('Mundan Ceremony', 'mundan', 'assets/icons/baby_face.png'),
    _ServiceItem('Grih Pravesh', 'grih_pravesh', 'assets/icons/key.png'),
    _ServiceItem('Havan / Homam', 'havan', 'assets/icons/havan_sticks.png'),
    _ServiceItem('Satyanarayan Katha', 'katha', 'assets/icons/bell.png'),
    _ServiceItem('Marriage Rituals', 'marriage', 'assets/icons/lotus.png'),
    _ServiceItem('More Services', 'more', 'assets/icons/search.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 480 ? 420.0 : screenWidth;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
  elevation: 0,
  backgroundColor: AppColors.saffron,
  title: Text(
    'Service Categories',
    style: AppTextStyles.title.copyWith(
      color: AppColors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  centerTitle: true,
  iconTheme: const IconThemeData(color: Colors.white),
),

      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // subtitle
                Text(
  'Choose a ritual to proceed',
  style: AppTextStyles.subtitle.copyWith(
    color: AppColors.textDark,
    fontSize: 15,
  ),
),

                const SizedBox(height: 18),

                Expanded(
                  child: ListView.separated(
                    itemCount: defaultServices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = defaultServices[index];
                      return _ServiceTile(
                        title: item.title,
                        iconPath: item.icon,
                        onTap: () {
                          if (item.slug == 'more') {
                            // open full searchable list as a modal
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const _MoreServicesSheet(),
                            );
                          } else {
                            // navigate to location selection for the selected service
                            // using existing route: /location/:service
                            final encoded = Uri.encodeComponent(item.slug);
                            context.push('/location/$encoded');
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 52,
              width: 52,
              child: Image.asset(iconPath, fit: BoxFit.contain, color: AppColors.primaryGold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 28,
              width: 28,
              child: Image.asset('assets/icons/arrow_right.png'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreServicesSheet extends StatefulWidget {
  const _MoreServicesSheet({super.key});

  @override
  State<_MoreServicesSheet> createState() => _MoreServicesSheetState();
}

class _MoreServicesSheetState extends State<_MoreServicesSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  // Example full services catalog (expandable later from Supabase)
  final List<String> _allServices = [
    'Mundan Ceremony',
    'Grih Pravesh',
    'Havan / Homam',
    'Satyanarayan Katha',
    'Marriage Rituals',
    'Navagraha Pooja',
    'Maha Mrityunjay',
    'Ganesh Pooja',
    'Lakshmi Pooja',
    'Sunderkand Paath',
    'Shraddh / Tarpan',
    'Annaprashan',
    'Naamkaran (Naming)',
    'Satyanarayan Katha Extended',
    'Vastu Shanti',
    'Brahmin Havan',
    'Custom Ritual (Request)',
  ];

  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allServices);
    _ctrl.addListener(_onSearch);
    // focus the field when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onSearch() {
    final q = _ctrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(_allServices);
      } else {
        _filtered = _allServices.where((s) => s.toLowerCase().contains(q)).toList();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onSearch);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // modal height as 80% of screen
    final height = MediaQuery.of(context).size.height * 0.82;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          children: [
            // drag handle
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),

            // header
            Row(
              children: [
                Expanded(
                  child: Text('All Services', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textDark)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            const SizedBox(height: 8),

            // search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.03), blurRadius: 6, offset: const Offset(0,2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black45),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      decoration: const InputDecoration(
                        hintText: 'Search services (e.g. Mundan, Havan, Katha)',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // results
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Text('No matching services', style: AppTextStyles.subtitle))
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final s = _filtered[index];
                        return InkWell(
                          onTap: () {
                            // If user chooses a service here, proceed to /location/:service
                            final slug = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
                            final encoded = Uri.encodeComponent(slug);
                            Navigator.of(context).pop(); // close sheet
                            context.push('/location/$encoded');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.play_circle_outline, size: 20, color: Colors.black45),
                                const SizedBox(width: 12),
                                Expanded(child: Text(s, style: AppTextStyles.bodyMedium)),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: _filtered.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final String slug;
  final String icon;
  const _ServiceItem(this.title, this.slug, this.icon);
}
