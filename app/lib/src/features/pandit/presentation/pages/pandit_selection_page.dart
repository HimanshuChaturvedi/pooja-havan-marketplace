import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/core/supabase/supabase_client.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/pandit/state/pandit_selection_provider.dart';
import '../../../../core/utils/ritual_slug_mapper.dart';
import '../../../pandit_onboarding/domain/pandit_profile.dart';

class PanditSelectionPage extends ConsumerStatefulWidget {
  final String templeName;

  const PanditSelectionPage({
    super.key,
    required this.templeName,
  });

  @override
  ConsumerState<PanditSelectionPage> createState() => _PanditSelectionPageState();
}

class _PanditSelectionPageState extends ConsumerState<PanditSelectionPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  
  // Filtering States
  String _selectedLanguage = 'All';
  String _selectedExperience = 'All';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select Pandit',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 50,
              child: Text(
                'Choose a Divine Guide',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 6),
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                widget.templeName.isNotEmpty
                    ? 'Available pandits for ${widget.templeName}'
                    : 'Available authentic pandits for your pooja',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🎛️ HORIZONTAL FILTER PILLS
            _StaggeredFade(
              controller: _animController,
              delay: 150,
              child: _buildFiltersBar(),
            ),

            const SizedBox(height: 24),

            _PanditList(
              animController: _animController,
              selectedLanguage: _selectedLanguage,
              selectedExperience: _selectedExperience,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text('Language: ', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.darkCharcoal)),
              const SizedBox(width: 8),
              ...['All', 'Sanskrit', 'Hindi', 'English'].map((lang) {
                final isSel = _selectedLanguage == lang;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(lang, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : AppColors.darkCharcoal)),
                    selected: isSel,
                    selectedColor: AppColors.saffron,
                    backgroundColor: Colors.grey.shade100,
                    onSelected: (val) {
                      if (val) setState(() => _selectedLanguage = lang);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Experience Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text('Experience: ', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.darkCharcoal)),
              const SizedBox(width: 8),
              ...['All', '5+ Years', '10+ Years'].map((exp) {
                final isSel = _selectedExperience == exp;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(exp, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : AppColors.darkCharcoal)),
                    selected: isSel,
                    selectedColor: AppColors.saffron,
                    backgroundColor: Colors.grey.shade100,
                    onSelected: (val) {
                      if (val) setState(() => _selectedExperience = exp);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanditList extends ConsumerWidget {
  final AnimationController animController;
  final String selectedLanguage;
  final String selectedExperience;

  const _PanditList({
    required this.animController,
    required this.selectedLanguage,
    required this.selectedExperience,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingSessionProvider).current;
    final city = booking?.city ?? '';
    
    final ritualSlug = RitualSlugMapper.getSlug(
      id: booking?.ritualId,
      name: booking?.ritualName,
    );
    
    final panditsAsync = ref.watch(panditsByRitualProvider((ritualSlug: ritualSlug, city: city)));

    return panditsAsync.when(
      data: (pandits) {
        if (pandits.isEmpty) {
          return _EmptyPanditState(animController: animController);
        }

        // Apply Client-Side Filter with Mock Data
        final filteredPandits = pandits.where((pandit) {
          // Generate deterministic mocks based on hashCode
          final hash = pandit.id.hashCode;
          final List<String> langs = hash % 3 == 0 
              ? ['Hindi', 'Sanskrit']
              : hash % 3 == 1 
                  ? ['Hindi', 'Sanskrit', 'English']
                  : ['Hindi'];

          // Experience filter check
          if (selectedExperience == '5+ Years' && pandit.experienceYears < 5) return false;
          if (selectedExperience == '10+ Years' && pandit.experienceYears < 10) return false;

          // Language filter check
          if (selectedLanguage != 'All' && !langs.contains(selectedLanguage)) return false;

          return true;
        }).toList();

        if (filteredPandits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'No Pandits match your filter criteria.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
            ),
          );
        }

        return Column(
          children: List.generate(filteredPandits.length, (index) {
            final pandit = filteredPandits[index];
            
            // Deterministic mocks for card visuals
            final hash = pandit.id.hashCode;
            // rating: null — no real rating data from DB yet; fake values removed
            final int pujasCount = 20 + (hash % 35);
            final List<String> langs = hash % 3 == 0 
                ? ['Hindi', 'Sanskrit']
                : hash % 3 == 1 
                    ? ['Hindi', 'Sanskrit', 'English']
                    : ['Hindi'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StaggeredFade(
                controller: animController,
                delay: 200 + (index * 100),
                child: _PanditCard(
                  name: '${pandit.firstName} ${pandit.lastName}',
                  experience: '${pandit.experienceYears} Years Exp',
                  profileImageUrl: pandit.profileImageUrl,
                  rating: null,
                  pujasCount: pujasCount,
                  languages: langs,
                  onTap: () {
                    final current = ref.read(bookingSessionProvider).current;
                    if (current != null) {
                      ref.read(bookingSessionProvider.notifier).updateBookingDraft(
                        current.copyWith(
                          panditName: '${pandit.firstName} ${pandit.lastName}',
                          panditId: pandit.id,
                        ),
                      );
                    }
                    context.push('/home-date-time');
                  },
                ),
              ),
            );
          }),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

class _EmptyPanditState extends ConsumerWidget {
  final AnimationController animController;
  const _EmptyPanditState({required this.animController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StaggeredFade(
      controller: animController,
      delay: 200,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline_rounded, size: 64, color: AppColors.saffron),
              ),
              const SizedBox(height: 24),
              Text(
                'No Pandits Available',
                style: AppTextStyles.title.copyWith(fontSize: 20, color: AppColors.darkCharcoal),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'We currently don\'t have verified Pandits for this ritual in your area. Be the first to join us!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Register as a Pandit',
                onTap: () => context.push('/pandit-onboarding'),
              ),
              const SizedBox(height: 24),
              const _DiagnosticInfo(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagnosticInfo extends ConsumerWidget {
  const _DiagnosticInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingSessionProvider).current;
    final city = booking?.city ?? '';
    final ritualSlug = RitualSlugMapper.getSlug(
      id: booking?.ritualId,
      name: booking?.ritualName,
    );

    return FutureBuilder<List<dynamic>>(
      future: supabase.from('pandit_profiles').select('''
        id,
        first_name,
        last_name,
        verification_status,
        pandit_service_areas(city),
        pandit_specializations(ritual_slug)
      '''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.saffron));
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Diagnostic Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }

        final profiles = snapshot.data ?? [];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔍 Diagnostic Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkCharcoal),
              ),
              const SizedBox(height: 12),
              Text('• Booking City: "$city"'),
              Text('• Booking Ritual Slug: "$ritualSlug"'),
              const SizedBox(height: 16),
              const Text(
                'Registered Pandits in DB:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (profiles.isEmpty)
                const Text('No Pandit profiles found in database.', style: TextStyle(fontStyle: FontStyle.italic))
              else
                ...profiles.map((p) {
                  final name = '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
                  final status = p['verification_status'] ?? 'Unknown';
                  final serviceAreas = (p['pandit_service_areas'] as List?)
                      ?.map((e) => e['city'] as String)
                      .toList() ?? [];
                  final specializations = (p['pandit_specializations'] as List?)
                      ?.map((e) => e['ritual_slug'] as String)
                      .toList() ?? [];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Status: $status', style: TextStyle(color: status == 'VERIFIED' ? Colors.green : Colors.orange, fontWeight: FontWeight.w600)),
                        Text('Service Areas: ${serviceAreas.isEmpty ? 'None' : serviceAreas.join(', ')}'),
                        Text('Specializations: ${specializations.isEmpty ? 'None' : specializations.join(', ')}'),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _PanditCard extends StatelessWidget {
  final String name;
  final String experience;
  final String? profileImageUrl;
  final double? rating;
  final int pujasCount;
  final List<String> languages;
  final VoidCallback onTap;

  const _PanditCard({
    required this.name,
    required this.experience,
    this.profileImageUrl,
    this.rating,
    required this.pujasCount,
    required this.languages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.saffron.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.saffron.withOpacity(0.08),
                backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                child: profileImageUrl == null 
                  ? const Icon(Icons.person, color: AppColors.saffron, size: 30)
                  : null,
              ),
            ),
            const SizedBox(width: 16),
            // Pandit Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Rating & Completed Pujas
                  Row(
                    children: [
                      if (rating != null) ...[
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${rating!.toStringAsFixed(1)} ',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '($pujasCount Pujas)',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey),
                        ),
                      ] else
                        Text(
                          'No ratings yet',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.softGrey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Languages & Exp badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Experience badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          experience,
                          style: const TextStyle(color: AppColors.saffron, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Languages
                      ...languages.map((l) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        child: Text(
                          l,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffron),
            ),
          ],
        ),
      ),
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
        final start = (delay / 1000).clamp(0, 1.0).toDouble();
        final end = ((delay + 400) / 1000).clamp(0, 1.0).toDouble();
        
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ).value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - opacity)),
            child: child,
          ),
        );
      },
    );
  }
}
