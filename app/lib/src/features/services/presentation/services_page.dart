import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../data/ritual_repository.dart';
import '../data/ritual_repository_provider.dart';

class ServicesPage extends ConsumerStatefulWidget {
  static const routeName = '/services';
  const ServicesPage({super.key});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'All', 'Sanskar', 'Shanti', 'Havan', 'Griha', 'Festival',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final entryType = uri.queryParameters['type'];
    final ritualsAsync = ref.watch(ritualsProvider);

    return AppScaffold(
      title: 'Book a Pooja',
      body: Column(
        children: [
          // 🔍 STICKY SEARCH BAR
          Container(
            color: AppColors.warmIvory,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search rituals...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.softGrey.withOpacity(0.5),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.saffron),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.softGrey, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // 🏷️ CATEGORY CHIPS
          Container(
            color: AppColors.warmIvory,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.saffron : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.saffron : Colors.black12,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.darkCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 📋 RESULTS LIST
          Expanded(
            child: ritualsAsync.when(
              data: (rituals) {
                final filtered = rituals.where((r) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      r.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' ||
                      r.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, color: AppColors.softGrey.withOpacity(0.3), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No rituals found',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ritual = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          final current = ref.read(bookingSessionProvider).current;
                          if (current != null) {
                            final updated = current.copyWith(
                              ritualName: ritual.name,
                              ritualId: ritual.id,
                            );
                            ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
                          } else {
                            final draft = BookingDraft(
                              bookingType: entryType == 'temple' ? BookingType.temple : BookingType.home,
                              ritualName: ritual.name,
                              ritualId: ritual.id,
                              city: '',
                            );
                            ref.read(bookingSessionProvider.notifier).updateBookingDraft(draft);
                          }
                          context.push('/service/${ritual.id}/${Uri.encodeComponent(ritual.name)}');
                        },
                        child: PrimaryCard(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.saffron.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.saffron,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ritual.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: AppColors.darkCharcoal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.saffron.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ritual.category,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.saffron,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.saffron,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: 8,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ShimmerCard(height: 90),
                ),
              ),
              error: (err, stack) => Center(
                child: Text('Error loading rituals: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
