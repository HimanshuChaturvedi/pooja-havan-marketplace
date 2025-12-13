import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingSummaryPage extends StatelessWidget {
  const BookingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // STATIC DATA FOR NOW (will come from state / backend later)
    const String city = 'Haridwar';
    const String address =
        'House No 21, Near Ganga Ghat, Haridwar';
    const String date = '15/01/2025';
    const String time = '7:30 AM';
    const bool samagriIncluded = true;

    const int poojaCost = 2100;
    const int samagriCost = 900;
    final int total =
        poojaCost + (samagriIncluded ? samagriCost : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Address'),
            _infoTile('$address\n$city'),

            const SizedBox(height: 16),

            _sectionTitle('Date & Time'),
            _infoTile('$date at $time'),

            const SizedBox(height: 16),

            _sectionTitle('Samagri'),
            _infoTile(
              samagriIncluded
                  ? 'Samagri will be arranged'
                  : 'I already have Samagri',
            ),

            const SizedBox(height: 16),

            _sectionTitle('Price Breakdown'),
            _priceRow('Pooja Charges', poojaCost),
            if (samagriIncluded)
              _priceRow('Samagri Charges', samagriCost),
            const Divider(),
            _priceRow('Total Amount', total, isBold: true),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/payment');
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoTile(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }

  Widget _priceRow(String label, int amount,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
