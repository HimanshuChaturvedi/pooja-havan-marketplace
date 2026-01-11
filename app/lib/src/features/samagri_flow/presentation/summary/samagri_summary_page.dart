import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../application/samagri_session.dart';
import '../../../booking/application/booking_session.dart';

class SamagriSummaryPage extends StatelessWidget {
  const SamagriSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final samagri = SamagriSession.current;
    final isBookingFlow = BookingSession.current != null;

    if (samagri == null) {
      return const Scaffold(
        body: Center(child: Text('No samagri data')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Samagri Summary')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...samagri.items.map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.name} × ${i.quantity}'),
                        Text('₹${i.lineTotal}'),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${samagri.totalAmount}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    isBookingFlow
                        ? '/samagri-success'
                        : '/payment',
                  );
                },
                child: const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
