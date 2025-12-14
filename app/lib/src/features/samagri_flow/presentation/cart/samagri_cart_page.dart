import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/samagri_cart_notifier.dart';

class SamagriCartPage extends ConsumerWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(samagriCartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samagri Cart'),
      ),

      body: cart.items.isEmpty
          ? const Center(
              child: Text('No items in cart'),
            )
          : ListView(
              children: cart.items.entries.map((entry) {
                final item = entry.key;
                final qty = entry.value;

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('₹${item.price} x $qty'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          ref
                              .read(samagriCartProvider.notifier)
                              .removeItem(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          ref
                              .read(samagriCartProvider.notifier)
                              .addItem(item);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: cart.items.isEmpty
              ? null
              : () {
                  context.go('/samagri/requirement');
                },
          child: Text(
            'Proceed • ₹${cart.totalAmount.toStringAsFixed(0)}',
          ),
        ),
      ),
    );
  }
}
