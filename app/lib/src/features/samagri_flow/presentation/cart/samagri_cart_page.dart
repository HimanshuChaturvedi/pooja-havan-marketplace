import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/samagri_session.dart';
import '../../state/samagri_cart_notifier.dart';
import '../../state/samagri_item.dart' as CatalogItem;
import '../../../booking/application/booking_session.dart';

class SamagriCartPage extends ConsumerWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(samagriCartProvider);
    final items = cart.items.entries.toList();
    final hasItems = items.isNotEmpty;
    final isBookingFlow = BookingSession.current != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Samagri Cart')),
      body: hasItems
          ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final entry = items[index];
                final CatalogItem.SamagriItem item = entry.key;
                final qty = entry.value;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.name} × $qty'),
                    Text('₹${item.price * qty}'),
                  ],
                );
              },
            )
          : const Center(child: Text('No items in cart')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: hasItems
                  ? () {
                      SamagriSession.createFromCart(
                        items: items.map((e) {
                          final CatalogItem.SamagriItem i = e.key;
                          return SamagriItem(
                            itemId: i.id,
                            name: i.name,
                            unitPrice: i.price.round(),
                            quantity: e.value,
                          );
                        }).toList(),
                        isPartOfBooking: isBookingFlow,
                      );

                      context.push(
                        isBookingFlow
                            ? '/samagri-summary'
                            : '/samagri-address',
                      );
                    }
                  : null,
              child: Text(
                'Continue • ₹${cart.totalAmount.round()}',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
