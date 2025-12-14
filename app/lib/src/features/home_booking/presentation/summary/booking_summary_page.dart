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
        body: Center(
          child: Text('No booking data found'),
        ),
      );
    }

    const int poojaCost = 2100;
    const int samagriCost = 900;

    final int totalAmount =
        poojaCost + (booking.samagriRequired ? samagriCost : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ADDRESS (HOME) OR TEMPLE (TEMPLE FLOW)
            _sectionTitle(
              booking.bookingType == BookingType.home
                  ? 'Address'
                  : 'Temple',
            ),
            _infoTile(
              booking.bookingType == BookingType.home
                  ? '${booking.address ?? ''}\n${booking.city}'
                  : '${booking.templeName ?? 'Selected Temple'}\n${booking.city}',
            ),

            const SizedBox(height: 16),

            // DATE & TIME
            _sectionTitle('Date & Time'),
            _infoTile(
              '${booking.selectedDate?.day}/${booking.selectedDate?.month}/${booking.selectedDate?.year}'
              ' at ${booking.selectedTime}',
            ),

            // PANDIT (ONLY FOR TEMPLE FLOW)
            if (booking.panditName != null) ...[
              const SizedBox(height: 16),
              _sectionTitle('Pandit'),
              _infoTile(booking.panditName!),
            ],

            const SizedBox(height: 16),

            // SAMAGRI
            _sectionTitle('Samagri'),
            _infoTile(
              booking.samagriRequired
                  ? booking.samagriItems.isNotEmpty
                      ? booking.samagriItems.join(', ')
                      : 'Standard pooja samagri will be arranged'
                  : 'I already have Samagri',
            ),

            const SizedBox(height: 16),

            // PRICE BREAKDOWN
            _sectionTitle('Price Breakdown'),
            _priceRow('Pooja Charges', poojaCost),
            if (booking.samagriRequired)
              _priceRow('Samagri Charges', samagriCost),
            const Divider(),
            _priceRow(
              'Total Amount',
              totalAmount,
              isBold: true,
            ),

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

  // ---------- UI HELPERS ----------

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

  Widget _priceRow(
    String label,
    int amount, {
    bool isBold = false,
  }) {
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
