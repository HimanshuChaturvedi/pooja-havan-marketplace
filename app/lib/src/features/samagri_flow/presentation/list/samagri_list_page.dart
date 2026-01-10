import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/samagri_cart_notifier.dart';
import '../../state/samagri_item.dart';
import 'widgets/samagri_item_card.dart';

class SamagriListPage extends ConsumerStatefulWidget {
  const SamagriListPage({super.key});

  @override
  ConsumerState<SamagriListPage> createState() =>
      _SamagriListPageState();
}

class _SamagriListPageState
    extends ConsumerState<SamagriListPage> {
  final Map<SamagriItem, int> samagri = {
    const SamagriItem(
      id: 'havan',
      name: 'Havan Samagri',
      price: 500,
      categoryId: 'basic',
    ): 0,
    const SamagriItem(
      id: 'ghee',
      name: 'Ghee',
      price: 300,
      categoryId: 'basic',
    ): 0,
    const SamagriItem(
      id: 'dhoop',
      name: 'Dhoop',
      price: 150,
      categoryId: 'basic',
    ): 0,
    const SamagriItem(
      id: 'agarbatti',
      name: 'Agarbatti',
      price: 100,
      categoryId: 'basic',
    ): 0,
    const SamagriItem(
      id: 'kumkum',
      name: 'Kumkum',
      price: 50,
      categoryId: 'basic',
    ): 0,
  };

  bool get hasItems => samagri.values.any((qty) => qty > 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Samagri'),
        leading: BackButton(
          onPressed: () {
            // 🔑 Buy Samagri → Back goes to Landing
            context.go('/landing');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: samagri.entries.map((entry) {
          final item = entry.key;
          final qty = entry.value;

          return SamagriItemCard(
            name: item.name,
            quantity: qty,
            onAdd: () {
              setState(() {
                samagri[item] = qty + 1;
              });
            },
            onRemove: () {
              setState(() {
                samagri[item] = qty > 0 ? qty - 1 : 0;
              });
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: hasItems
              ? () {
                  // RESET CART FIRST
                  ref
                      .read(samagriCartProvider.notifier)
                      .clearCart();

                  // PUSH SELECTED ITEMS INTO CART
                  samagri.forEach((item, qty) {
                    for (int i = 0; i < qty; i++) {
                      ref
                          .read(
                              samagriCartProvider.notifier)
                          .addItem(item);
                    }
                  });

                  context.go('/samagri-cart');
                }
              : null,
          child: const Text('View Cart'),
        ),
      ),
    );
  }
}
