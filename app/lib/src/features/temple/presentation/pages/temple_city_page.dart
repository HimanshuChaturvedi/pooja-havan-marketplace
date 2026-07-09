import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../../data/temple_repository_provider.dart';
import '../../../../features/booking/state/booking_session_notifier.dart';
import '../../../../features/booking/domain/booking_draft.dart';

class TempleCityPage extends ConsumerStatefulWidget {
  const TempleCityPage({super.key});

  @override
  ConsumerState<TempleCityPage> createState() => _TempleCityPageState();
}

class _TempleCityPageState extends ConsumerState<TempleCityPage> {
  String? _selectedCityId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);

    return AppScaffold(
      title: 'Select City',
      body: Column(
        children: [
          // 🔍 STICKY SEARCH
          Container(
            color: AppColors.warmIvory,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search cities...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey.withOpacity(0.5)),
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

          // CITY LIST
          Expanded(
            child: citiesAsync.when(
              data: (cities) {
                final filtered = cities.where((c) =>
                  c.supportsTempleBooking &&
                  (_searchQuery.isEmpty || c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                ).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, color: AppColors.softGrey.withOpacity(0.3), size: 48),
                        const SizedBox(height: 12),
                        Text('No cities found', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final city = filtered[index];
                    final isSelected = _selectedCityId == city.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCityId = city.id);
                          final current = ref.read(bookingSessionProvider).current;
                          if (current != null) {
                            final updated = current.copyWith(
                              city: city.name,
                              cityId: city.id,
                            );
                            ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
                          } else {
                            // Initiating a temple booking draft if none exists
                            final draft = BookingDraft(
                              bookingType: BookingType.temple,
                              city: city.name,
                              cityId: city.id,
                              ritualName: '',
                            );
                            ref.read(bookingSessionProvider.notifier).updateBookingDraft(draft);
                          }
                        },
                        child: PrimaryCard(
                          padding: const EdgeInsets.all(20),
                          color: isSelected ? AppColors.saffron.withOpacity(0.06) : null,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.saffron.withOpacity(0.15)
                                      : AppColors.saffron.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_city_rounded, color: AppColors.saffron, size: 24),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Available for Temple Bookings',
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
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.saffron),
              ),
              error: (err, stack) => Center(
                child: Text('Error loading cities: $err'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          label: 'Continue →',
          onTap: _selectedCityId != null
              ? () => context.push('/temple-select?city=$_selectedCityId')
              : null,
        ),
      ),
    );
  }
}
