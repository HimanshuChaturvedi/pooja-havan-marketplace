import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/features/temple/data/temple_repository_provider.dart';
import 'package:app/src/features/temple/data/temple_data.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/booking/application/booking_session.dart';

class TempleSelectionPage extends ConsumerStatefulWidget {
  final String city;
  const TempleSelectionPage({super.key, required this.city});

  @override
  ConsumerState<TempleSelectionPage> createState() => _TempleSelectionPageState();
}

class _TempleSelectionPageState extends ConsumerState<TempleSelectionPage> {
  String? _selectedTempleId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templesAsync = ref.watch(templesInCityProvider(widget.city));
    final citiesAsync = ref.watch(citiesProvider);
    
    final cityName = citiesAsync.when(
      data: (cities) {
        final match = cities.where((c) => c.id == widget.city);
        return match.isNotEmpty ? match.first.name : widget.city;
      },
      loading: () => '...',
      error: (_, __) => widget.city,
    );
    return AppScaffold(
      title: 'Select Temple',
      body: Column(
        children: [
          // Search bar
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
                  hintText: 'Search temples in $cityName...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.saffron),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: AppColors.softGrey, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: templesAsync.when(
              data: (temples) {
                final filtered = temples.where((t) =>
                  _searchQuery.isEmpty ||
                  t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.templeType.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, color: AppColors.softGrey.withOpacity(0.3), size: 48),
                        SizedBox(height: 12),
                        Text('No temples found', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final temple = filtered[index];
                    final isSelected = _selectedTempleId == temple.id;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTempleId = temple.id),
                        child: PrimaryCard(
                          padding: EdgeInsets.all(20),
                          color: isSelected ? AppColors.saffron.withOpacity(0.06) : null,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.saffron.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.account_balance_rounded, color: AppColors.saffron, size: 24),
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      temple.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkCharcoal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${temple.templeType} • ${temple.address}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.softGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: AppColors.saffron, size: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.saffron),
              ),
              error: (err, stack) => Center(
                child: Text('Error loading temples: $err'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: templesAsync.when(
          data: (temples) => PrimaryButton(
            label: 'Continue →',
                onTap: _selectedTempleId != null
                    ? () {
                        final selected = temples.firstWhere((t) => t.id == _selectedTempleId);
                        final current = BookingSession.current;
                        if (current != null) {
                          current.templeName = selected.name;
                          current.templeId = selected.id;
                        }
                        context.push('/temple-ritual?temple=${Uri.encodeComponent(selected.name)}&city=${widget.city}');
                      }
                    : null,
          ),
          loading: () => PrimaryButton(label: 'Loading...', onTap: null),
          error: (_, __) => PrimaryButton(label: 'Error', onTap: null),
        ),
      ),
    );
  }
}
