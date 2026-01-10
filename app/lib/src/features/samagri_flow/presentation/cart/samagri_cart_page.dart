import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/samagri_session.dart'
    as session; // 👈 IMPORTANT: alias
import '../../state/samagri_cart_notifier.dart';
import '../../state/samagri_item.dart'
    as cart; // 👈 IMPORTANT: alias
import '../../../booking/application/booking_session.dart';

class SamagriCartPage extends ConsumerWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(samagriCartProvider);
    final items = cartState.items.entries.toList();
    final bool hasItems = items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samagri Cart'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            // 🔑 Back always to Select Samagri
            context.go('/samagri-list');
          },
        ),
      ),
      body: hasItems
          ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entry = items[index];
                final cart.SamagriItem item = entry.key;
                final int qty = entry.value;

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
                              .read(
                                  samagriCartProvider.notifier)
                              .removeItem(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          ref
                              .read(
                                  samagriCartProvider.notifier)
                              .addItem(item);
                        },
                      ),
                    ],
                  ),
                );
              },
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
                    final bool isBookingFlow =
                        BookingSession.current != null;

                    // ✅ MAP CART ITEMS → SESSION ITEMS (CORRECT TYPE)
                    final List<session.SamagriItem>
                        sessionItems =
                        items.map((entry) {
                      final cart.SamagriItem item =
                          entry.key;
                      final int qty = entry.value;

                      return session.SamagriItem(
                        itemId: item.id,
                        name: item.name,
                        unitPrice:
                            item.price.round(),
                        quantity: qty,
                      );
                    }).toList();

                    // ✅ Create Samagri session
                    session.SamagriSession.createFromCart(
                      items: sessionItems,
                      isPartOfBooking: isBookingFlow,
                    );

                    // 🔑 Navigation UNCHANGED
                    if (isBookingFlow) {
                      context.go('/home-summary');
                    } else {
                      context.push('/samagri-summary');
                    }
                  }
                : null,
            child: Text(
              'Continue • ₹${cartState.totalAmount.round()}',
            ),
          ),
        ),
      ),
    );
  }
}
