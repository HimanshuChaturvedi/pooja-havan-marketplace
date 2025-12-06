// lib/src/features/landing/landing_enhanced.dart
// Full production-ready Flutter file for the Enhanced Landing Page
// Dependencies (already in project):
//  - flutter_riverpod
//  - go_router
//  - AppTheme, AppColors, AppTextStyles exist in core/theme

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- Route name constant ---
const String kRouteLanding = '/landing';

// --- Simple Riverpod provider for currently selected city/location ---
final selectedLocationProvider = StateProvider<String?>((ref) => null);

class LandingEnhancedPage extends ConsumerWidget {
  const LandingEnhancedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: false,
        title: const Text('Namaste', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationBar(context, ref, selectedLocation),
              const SizedBox(height: 18),
              const Text(
                'How can we help today?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),

              // Primary action grid
              _PrimaryActionGrid(onActionTap: (action) {
                switch (action) {
                  case _LandingAction.bookPooja:
                    context.push('/services');
                    break;
                  case _LandingAction.buySamagri:
                    context.push('/samagri');
                    break;
                  case _LandingAction.havanAtTemple:
                    context.push('/temple_booking');
                    break;
                  case _LandingAction.explore:
                    context.push('/explore');
                    break;
                }
              }),

              const SizedBox(height: 18),

              // Quick searches / suggested rituals
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Popular rituals', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularRituals.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = _popularRituals[index];
                          return _RitualCard(title: item.title, subtitle: item.subtitle, onTap: () {
                            context.push('/services/${item.slug}');
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Recommended for you', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.separated(
                        itemCount: 3,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _RecommendedTile(onTap: () => context.push('/services')),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom CTA: quick book
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/booking/quick'),
        label: const Text('Quick Book'),
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, WidgetRef ref, String? selectedLocation) {
    return InkWell(
      onTap: () async {
        // navigate to location selection page; it should update selectedLocationProvider
        context.push('/location');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedLocation ?? 'Select location', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Choose city or detect current location', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Detect current location',
              onPressed: () {
                // trigger location detect flow; implement actual service in core/services
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detecting current location...')));
              },
              icon: const Icon(Icons.my_location_outlined),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- Small supporting widgets & data structures -----------------
enum _LandingAction { bookPooja, buySamagri, havanAtTemple, explore }

class _PrimaryActionGrid extends StatelessWidget {
  final void Function(_LandingAction) onActionTap;
  const _PrimaryActionGrid({Key? key, required this.onActionTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 420;
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _ActionTile(title: 'Book a Pooja', icon: Icons.home_repair_service, onTap: () => onActionTap(_LandingAction.bookPooja)),
        _ActionTile(title: 'Buy Samagri', icon: Icons.shopping_bag_outlined, onTap: () => onActionTap(_LandingAction.buySamagri)),
        _ActionTile(title: 'Havan at Temple', icon: Icons.temple_hindu, onTap: () => onActionTap(_LandingAction.havanAtTemple)),
        _ActionTile(title: 'Explore Services', icon: Icons.search, onTap: () => onActionTap(_LandingAction.explore)),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionTile({Key? key, required this.title, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RitualCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RitualCard({Key? key, required this.title, required this.subtitle, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container()),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  final VoidCallback onTap;
  const _RecommendedTile({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: const Text('Pandit — Vishal Sharma'),
      subtitle: const Text('Grih Pooja • 8 years experience'),
      trailing: ElevatedButton(onPressed: onTap, child: const Text('Book')),
    );
  }
}

class _RitualItem { final String title; final String subtitle; final String slug; const _RitualItem(this.title, this.subtitle, this.slug); }

const List<_RitualItem> _popularRituals = [
  _RitualItem('Grih Shanti', 'House peace ritual', 'grih-shanti'),
  _RitualItem('Mundan', 'Child head-shaving ceremony', 'mundan'),
  _RitualItem('Maha Mrityunjay', 'Ancient mantra', 'maha-mrityunjay'),
];
