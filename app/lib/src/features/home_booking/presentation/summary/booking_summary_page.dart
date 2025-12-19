import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';

class BookingSummaryPage extends StatelessWidget {
  const BookingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = BookingSession.current;

    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('No booking data found')),
      );
    }

    const int poojaCost = 2100;
    const int samagriItemCost = 300;

    // 🔒 Aggregate samagri items
    final Map<String, int> samagriCount = {};
    for (final item in booking.samagriItems) {
      samagriCount[item] = (samagriCount[item] ?? 0) + 1;
    }

    final int samagriCost =
        booking.samagriRequired ? samagriCount.length * samagriItemCost : 0;

    final int totalAmount = poojaCost + samagriCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔥 SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(
                    booking.bookingType == BookingType.home
                        ? 'Address'
                        : 'Temple',
                  ),
                  _infoTile(
                    booking.bookingType == BookingType.home
                        ? '${booking.address}\n${booking.city}'
                        : '${booking.templeName}\n${booking.city}',
                  ),

                  const SizedBox(height: 16),

                  _sectionTitle('Date & Time'),
                  _infoTile(
                    '${booking.selectedDate?.day}/${booking.selectedDate?.month}/${booking.selectedDate?.year}'
                    ' at ${booking.selectedTime}',
                  ),

                  if (booking.panditName != null) ...[
                    const SizedBox(height: 16),
                    _sectionTitle('Pandit'),
                    _infoTile(booking.panditName!),
                  ],

                  const SizedBox(height: 16),

                  _sectionTitle('Samagri'),

                  if (!booking.samagriRequired)
                    _infoTile('Samagri will be arranged by the user')
                  else
                    _samagriList(samagriCount, samagriItemCost),

                  const SizedBox(height: 20),

                  _sectionTitle('Price Breakdown'),
                  _priceRow('Pooja Charges', poojaCost),
                  if (booking.samagriRequired)
                    _priceRow('Samagri Charges', samagriCost),
                  const Divider(),
                  _priceRow('Total Amount', totalAmount, isBold: true),

                  const SizedBox(height: 80), // space for button
                ],
              ),
            ),
          ),

          // 🔒 FIXED BOTTOM CTA (NO OVERFLOW)
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/payment');
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _samagriList(Map<String, int> items, int costPerItem) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${entry.key} × ${entry.value}'),
                Text('₹${entry.value * costPerItem}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _priceRow(String label, int amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
