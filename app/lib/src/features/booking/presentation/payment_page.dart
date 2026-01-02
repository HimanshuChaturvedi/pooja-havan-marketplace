import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/booking_session.dart';
import '../../samagri_flow/application/samagri_session.dart';
import '../../samagri_flow/state/samagri_cart_notifier.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  bool canPayNow() {
    // ✅ BOOKING FLOW (Samagri ho ya na ho)
    if (BookingSession.current != null) {
      return BookingSession.status ==
          BookingStatus.paymentPending;
    }

    // ✅ STANDALONE SAMAGRI FLOW
    final samagri = SamagriSession.current;
    if (samagri == null) return false;

    if (samagri.addressText == null ||
        samagri.addressText!.trim().isEmpty) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samagri = SamagriSession.current;
    final booking = BookingSession.current;

    final amount =
        samagri != null ? samagri.totalAmount : 3000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Amount',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _amountTile('Total Payable', amount),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canPayNow()
                    ? () async {
                        await Future.delayed(
                            const Duration(seconds: 1));

                        // BOOKING PAYMENT SUCCESS
                        if (booking != null) {
                          BookingSession.status =
                              BookingStatus.confirmed;
                          context.go('/booking-success');
                          return;
                        }

                        // STANDALONE SAMAGRI PAYMENT
                        if (samagri != null) {
                          SamagriSession.markPaid();
                          SamagriSession.clear();
                          ref
                              .read(
                                  samagriCartProvider
                                      .notifier)
                              .clearCart();

                          context.go('/landing');
                        }
                      }
                    : null,
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountTile(String label, int amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹$amount',
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
