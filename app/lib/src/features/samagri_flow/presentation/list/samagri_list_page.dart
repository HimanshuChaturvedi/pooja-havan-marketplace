import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_item.dart';
import 'package:app/src/features/samagri_flow/presentation/list/widgets/samagri_item_card.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart'
    as session;
import 'package:app/src/core/widgets/design_system.dart';

class SamagriListPage extends ConsumerStatefulWidget {
  const SamagriListPage({super.key});

  @override
  ConsumerState<SamagriListPage> createState() => _SamagriListPageState();
}

class _SamagriListPageState extends ConsumerState<SamagriListPage> {
  final List<SamagriItem> _items = const [
    SamagriItem(id: 'havan_samagri', name: 'Havan Samagri', price: 500, categoryId: 'daily'),
    SamagriItem(id: 'ghee', name: 'Ghee', price: 300, categoryId: 'daily'),
    SamagriItem(id: 'agarbatti', name: 'Agarbatti', price: 100, categoryId: 'daily'),
    SamagriItem(id: 'dhoop', name: 'Dhoop', price: 150, categoryId: 'daily'),
    SamagriItem(id: 'diya', name: 'Diya', price: 80, categoryId: 'daily'),
    SamagriItem(id: 'phool', name: 'Phool', price: 120, categoryId: 'daily'),
    SamagriItem(id: 'kapur', name: 'Kapur', price: 60, categoryId: 'daily'),
    SamagriItem(id: 'chawal', name: 'Chawal (Akshat)', price: 70, categoryId: 'daily'),
    SamagriItem(id: 'kumkum', name: 'Kumkum / Roli', price: 50, categoryId: 'daily'),
    SamagriItem(id: 'supari', name: 'Supari', price: 60, categoryId: 'daily'),
    SamagriItem(id: 'nariyal', name: 'Nariyal (Coconut)', price: 90, categoryId: 'daily'),
    SamagriItem(id: 'samidha', name: 'Samidha (Havan Lakdi)', price: 200, categoryId: 'daily'),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(samagriCartProvider);
    final hasItems = cart.items.isNotEmpty;
    final total = cart.totalAmount;

    return AppScaffold(
      title: 'Shop',
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(title: 'Sacred Items for Daily Use'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82, 
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _items[index];
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
                childCount: _items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: hasItems ? 'Continue • ₹$total' : 'Select items',
          onTap: hasItems ? () {
            // Convert cart state to SamagriSession before navigating
            final sessionItems = cart.items.entries.map((e) =>
              session.SamagriItem(
                itemId: e.key.id,
                name: e.key.name,
                unitPrice: e.key.price.toInt(),
                quantity: e.value,
              ),
            ).toList();
            session.SamagriSession.createFromCart(items: sessionItems);
            context.push('/samagri-summary');
          } : null,
          loading: false,
        ),
      ),
    );
  }
}
