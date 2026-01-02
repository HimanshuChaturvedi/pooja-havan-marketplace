import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../application/samagri_session.dart';

class SamagriSummaryPage extends StatelessWidget {
  const SamagriSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SamagriSession.current;

    if (session == null) {
      return const Scaffold(
        body: Center(
          child: Text('No Samagri order found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samagri Summary'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // -----------------------------
          // ITEMS LIST
          // -----------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Items'),
                const SizedBox(height: 8),

                ...session.items.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle:
                        Text('₹${item.unitPrice} × ${item.quantity}'),
                    trailing: Text(
                      '₹${item.lineTotal}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                _sectionTitle('Vendor'),
                _infoTile(session.vendorLabel),

                const SizedBox(height: 16),

                _sectionTitle('Total'),
                _priceRow('Total Amount', session.totalAmount),
              ],
            ),
          ),

          // -----------------------------
          // CONTINUE → ADDRESS
          // -----------------------------
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // 🔑 Next step is ADDRESS (not payment)
                  context.push('/samagri-address');
                },
                child: const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // UI HELPERS
  // -----------------------------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text),
    );
  }

  Widget _priceRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '₹$amount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
