import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/samagri_session.dart';
import '../../state/samagri_cart_notifier.dart';
import '../../../booking/application/booking_session.dart';

class SamagriCartPage extends ConsumerWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(samagriCartProvider);
    final items = cart.items.entries.toList();
    final bool hasItems = items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samagri Cart'),
        centerTitle: true,
      ),
      body: hasItems
          ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entry = items[index];
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
              },
            )
          : const Center(child: Text('No items in cart')),

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

                    // ✅ Create Samagri session
                    SamagriSession.createFromCart(
                      items: items.map((entry) {
                        final item = entry.key;
                        final qty = entry.value;
                        return SamagriItem(
                          itemId: item.id,
                          name: item.name,
                          unitPrice: item.price.round(),
                          quantity: qty,
                        );
                      }).toList(),
                      isPartOfBooking: isBookingFlow,
                    );

                    // 🔥 CRITICAL FIX
                    if (isBookingFlow) {
                      // 👉 Booking flow NEVER goes to Samagri Summary
                      context.go('/home-summary');
                    } else {
                      // 👉 Standalone Buy Samagri
                      context.push('/samagri-summary');
                    }
                  }
                : null,
            child: Text(
              'Continue • ₹${cart.totalAmount.round()}',
            ),
          ),
        ),
      ),
    );
  }
}
