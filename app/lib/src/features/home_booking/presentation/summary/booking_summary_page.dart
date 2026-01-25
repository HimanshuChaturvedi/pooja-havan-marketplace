import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';
import '../../../samagri_flow/application/samagri_session.dart';

class BookingSummaryPage extends StatelessWidget {
  const BookingSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔒 MARK FLOW AS BOOKING (CRITICAL FIX)
    BookingSession.activeFlow = ActiveFlow.booking;

    final booking = BookingSession.current;

    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('No booking data found')),
      );
    }

    const int poojaCost = 2100;

    final bool samagriRequired =
        BookingSession.samagriDecisionTaken;

    final samagriSession = SamagriSession.current;

    final int samagriCost =
        samagriRequired && samagriSession != null
            ? samagriSession.totalAmount
            : 0;

    final int totalAmount = poojaCost + samagriCost;

    return WillPopScope(
      onWillPop: () async {
        // 🔒 EXITING BOOKING FLOW
        BookingSession.reset();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Summary'),
          centerTitle: true,
          leading: const BackButton(),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      booking.bookingType ==
                              BookingType.home
                          ? 'Address'
                          : 'Temple',
                    ),
                    _infoTile(
                      booking.bookingType ==
                              BookingType.home
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
                    if (!samagriRequired)
                      _infoTile(
                        'Samagri will be arranged by the user',
                      )
                    else if (samagriSession == null ||
                        samagriSession.items.isEmpty)
                      _infoTile(
                        'Samagri will be arranged by us',
                      )
                    else
                      _samagriList(samagriSession),

                    const SizedBox(height: 20),

                    _sectionTitle('Price Breakdown'),
                    _priceRow('Pooja Charges', poojaCost),
                    if (samagriRequired)
                      _priceRow(
                          'Samagri Charges', samagriCost),
                    const Divider(),
                    _priceRow(
                        'Total Amount', totalAmount,
                        isBold: true),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    BookingSession.status =
                        BookingStatus.paymentPending;
                    context.push('/payment');
                  },
                  child:
                      const Text('Proceed to Payment'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helpers unchanged …
  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _infoTile(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      );

  Widget _samagriList(SamagriSession session) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Samagri will be arranged by us',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...session.items.map((item) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${item.name} × ${item.quantity}'),
                  Text('₹${item.unitPrice * item.quantity}'),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    int amount, {
    bool isBold = false,
  }) =>
      Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            Text(
              '₹$amount',
              style: TextStyle(
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
}
