import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import '../../state/samagri_cart_notifier.dart';
import '../../state/samagri_item.dart';
import 'widgets/samagri_item_card.dart';
import 'package:app/src/core/widgets/divine_background.dart';

class SamagriListPage extends ConsumerStatefulWidget {
  const SamagriListPage({super.key});

  @override
  ConsumerState<SamagriListPage> createState() =>
      _SamagriListPageState();
}

class _SamagriListPageState
    extends ConsumerState<SamagriListPage> {
  // 🔒 MOST USED / DAILY USE SAMAGRI (PILOT READY)
  final List<SamagriItem> _items = const [
    SamagriItem(
      id: 'havan_samagri',
      name: 'Havan Samagri',
      price: 500,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'ghee',
      name: 'Ghee',
      price: 300,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'agarbatti',
      name: 'Agarbatti',
      price: 100,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'dhoop',
      name: 'Dhoop',
      price: 150,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'diya',
      name: 'Diya',
      price: 80,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'phool',
      name: 'Phool',
      price: 120,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'kapur',
      name: 'Kapur',
      price: 60,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'chawal',
      name: 'Chawal (Akshat)',
      price: 70,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'kumkum',
      name: 'Kumkum / Roli',
      price: 50,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'supari',
      name: 'Supari',
      price: 60,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'nariyal',
      name: 'Nariyal (Coconut)',
      price: 90,
      categoryId: 'daily',
    ),
    SamagriItem(
      id: 'samidha',
      name: 'Samidha (Havan Lakdi)',
      price: 200,
      categoryId: 'daily',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(samagriCartProvider);
    final hasItems = cart.items.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Select Samagri',
          style: AppTextStyles.title.copyWith(fontSize: 22, color: AppColors.maroon),
        ),
        leading: BackButton(
          color: AppColors.maroon,
          onPressed: () => context.go('/landing'),
        ),
      ),
      body: DivineBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          children: [
            // 🔒 SECTION HEADER
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 4),
              child: Text(
                'Sacred Items for Daily Use',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            ..._items.map((item) {
              // ✅ Get quantity from global cart state
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
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.dawnOrange.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.saffron,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: hasItems
              ? () {
                  // ✅ Flow is already updated in sync, just navigate
                  context.go('/samagri-cart');
                }
              : null,
          child: Text(
            'Continue to Cart →',
            style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
