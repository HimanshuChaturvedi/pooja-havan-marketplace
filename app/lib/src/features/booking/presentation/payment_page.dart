import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../samagri_flow/application/samagri_session.dart';
import '../../samagri_flow/state/samagri_cart_notifier.dart';




class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 DEMO MODE — STATIC AMOUNT
    const int totalAmount = 3000;

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _amountTile('Total Payable', totalAmount),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  // 🔒 MOCK PAYMENT DELAY
                  await Future.delayed(const Duration(seconds: 1));

                  // ✅ MARK + CLEAR SAMAGRI SESSION
                  SamagriSession.markPaid();
                  SamagriSession.clear();

                  // ✅ CLEAR SAMAGRI CART
                  ref.read(samagriCartProvider.notifier).clearCart();

                  // ✅ RESET NAVIGATION STACK
                  context.go('/landing');
                },
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹$amount',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
