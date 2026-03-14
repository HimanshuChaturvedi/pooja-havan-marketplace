import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_session_notifier.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_item.dart';
import 'package:app/src/features/samagri_flow/presentation/list/widgets/samagri_item_card.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart'
    as session;
import 'package:app/src/core/widgets/design_system.dart';
import '../../data/samagri_repository_provider.dart';

class SamagriListPage extends ConsumerStatefulWidget {
  const SamagriListPage({super.key});

  @override
  ConsumerState<SamagriListPage> createState() => _SamagriListPageState();
}

class _SamagriListPageState extends ConsumerState<SamagriListPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(samagriCartProvider);
    final samagriAsync = ref.watch(samagriItemsProvider);
    
    final hasItems = cart.items.isNotEmpty;
    final total = cart.totalAmount;

    return AppScaffold(
      title: 'Shop',
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
                  hintText: 'Search samagri...',
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

          // 📋 RESULTS AREA
          Expanded(
            child: samagriAsync.when(
              data: (items) {
                // Get unique categories
                final categories = ['All', ...items.map((e) => e.categoryId).toSet().toList()];
                
                final filtered = items.where((item) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      item.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' ||
                      item.categoryId == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                return Column(
                  children: [
                    // 🏷️ CATEGORY CHIPS
                    Container(
                      color: AppColors.warmIvory,
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                      child: SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
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

                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, color: AppColors.softGrey.withOpacity(0.3), size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No items found',
                                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final qty = cart.items[item] ?? 0;
                                return SamagriItemCard(
                                  name: item.name,
                                  price: item.price.toInt(),
                                  quantity: qty,
                                  onAdd: () {
                                    ref.read(samagriCartProvider.notifier).addItem(item);
                                  },
                                  onRemove: () {
                                    ref.read(samagriCartProvider.notifier).removeItem(item);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.saffron),
              ),
              error: (err, stack) => Center(
                child: Text('Error loading samagri: $err'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: PrimaryButton(
            label: hasItems ? 'Continue • ₹$total' : 'Select items',
            onTap: hasItems ? () {
              // Convert cart to SamagriItem list for the session
              final sessionItems = cart.items.entries.map((e) =>
                session.SamagriItem(
                  itemId: e.key.id,
                  name: e.key.name,
                  unitPrice: e.key.price.toInt(),
                  quantity: e.value,
                ),
              ).toList();
              
              // ✅ Use Riverpod instead of static legacy field
              // 🚀 v6.9: Detect if this is a sub-flow of a Pooja booking
              final inBookingFlow = ref.read(bookingSessionProvider).current != null;
              
              ref.read(samagriSessionProvider.notifier).createFromCart(
                items: sessionItems,
                isPartOfBooking: inBookingFlow, 
              );
              
              context.push('/samagri-summary');
            } : null,
            loading: false,
          ),
        ),
      ),
    );
  }
}
