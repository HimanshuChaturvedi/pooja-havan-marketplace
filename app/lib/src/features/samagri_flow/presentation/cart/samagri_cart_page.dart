import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../state/samagri_cart_notifier.dart';

class SamagriCartPage extends ConsumerWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(samagriCartProvider);
    final hasItems = cart.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samagri Cart'),
        centerTitle: true,
      ),
      body: hasItems
          ? ListView(
              padding: const EdgeInsets.all(12),
              children: cart.items.entries.map((entry) {
                final item = entry.key;
                final qty = entry.value;

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('₹${item.price} × $qty'),
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
            )
          : const Center(
              child: Text('No items in cart'),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: hasItems
                ? () {
                    final booking = BookingSession.current;

                    if (booking != null) {
                      // 🔑 SYNC CART → BOOKING SESSION (THIS WAS MISSING)
                      booking.samagriRequired = true;
                      booking.samagriItems.clear();

                      for (final entry in cart.items.entries) {
                        for (int i = 0; i < entry.value; i++) {
                          booking.samagriItems.add(entry.key.name);
                        }
                      }
                    }

                    context.push('/home-summary');
                  }
                : null,
            child: Text(
              'Continue • ₹${cart.totalAmount.toStringAsFixed(0)}',
            ),
          ),
        ),
      ),
    );
  }
}
