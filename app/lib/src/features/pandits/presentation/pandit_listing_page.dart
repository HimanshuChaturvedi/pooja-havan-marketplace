// lib/src/features/pandits/presentation/pandit_listing_page.dart
// Full production-ready Pandit Listing Screen
// Clean Architecture + Riverpod + GoRouter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ROUTE CONSTANT
const String kRoutePanditList = '/pandits/:slug';

// Pandit Model
class PanditInfo {
  final String name;
  final String experience;
  final double rating;
  final List<String> specializations;

  const PanditInfo({
    required this.name,
    required this.experience,
    required this.rating,
    required this.specializations,
  });
}

// Dummy data (later replaced by Supabase)
final List<PanditInfo> panditList = [
  PanditInfo(
    name: "Pandit Vishal Sharma",
    experience: "8 years experience",
    rating: 4.7,
    specializations: ["Grih Shanti", "Navgrah Shanti"],
  ),
  PanditInfo(
    name: "Pandit Raghav Shastri",
    experience: "12 years experience",
    rating: 4.8,
    specializations: ["Satyanarayan", "Maha Mrityunjay"],
  ),
  PanditInfo(
    name: "Pandit Mohan Tiwari",
    experience: "6 years experience",
    rating: 4.5,
    specializations: ["Grih Pravesh", "Havan"],
  ),
];

class PanditListingPage extends ConsumerWidget {
  final String poojaSlug;

  const PanditListingPage({
    super.key,
    required this.poojaSlug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Available Pandits"),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: panditList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final pandit = panditList[index];

          return _PanditCard(
            pandit: pandit,
            onTap: () {
              // Navigate to Booking Flow (step 1)
              context.push('/booking/${pandit.name}');
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------
// Pandit Card UI
// -----------------------------------------
class _PanditCard extends StatelessWidget {
  final PanditInfo pandit;
  final VoidCallback onTap;

  const _PanditCard({
    required this.pandit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Icon(Icons.person, size: 32, color: theme.colorScheme.primary),
              ),

              const SizedBox(width: 16),

              // Name + Experience + Specializations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pandit.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(pandit.experience,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 6),
                    Text(
                      pandit.specializations.join(" • "),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Rating
              Column(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    pandit.rating.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
