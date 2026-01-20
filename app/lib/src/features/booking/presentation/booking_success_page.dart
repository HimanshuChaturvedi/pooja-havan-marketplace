import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../logs/transaction_log.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/utils/app_identity.dart';
import '../application/booking_session.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key});

  String _shortUserId(String rawId) {
    final tail =
        rawId.length >= 4 ? rawId.substring(rawId.length - 4) : rawId;
    return 'SP-USER-$tail';
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingSession.current;

    return FutureBuilder<String>(
      future: AppIdentity.userId,
      builder: (context, snapshot) {
        final rawUserId =
            snapshot.hasData ? snapshot.data! : '0000';
        final displayUserId = _shortUserId(rawUserId);

        if (booking != null &&
            snapshot.connectionState ==
                ConnectionState.done) {
          // 🔑 STABLE BOOKING TXN ID (USER / WHATSAPP)
          BookingSession.transactionId ??=
              'BKG-${DateTime.now().millisecondsSinceEpoch}';

          // 🔑 INTERNAL UNIQUE LOG ID (DEDUP ONLY)
          final uniqueLogId =
              '${BookingSession.transactionId}-${DateTime.now().millisecondsSinceEpoch}';

          TransactionLogService.append(
            TransactionLogEntry(
              id: uniqueLogId, // internal
              type: TransactionType.booking,
              title: booking.ritualName,
              amount: 3000,
              status: TransactionStatus.completed,
              createdAt: DateTime.now(),
              userLabel: displayUserId,

              // ✅ THIS IS THE KEY FIX
              bookingId: BookingSession.transactionId,

              bookedForDate: booking.selectedDate,
              bookedForTime: booking.selectedTime,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Booking Confirmed'),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 72,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Your booking is confirmed',
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 24),

                // 📲 WHATSAPP → PANDIT
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text(
                    'Send booking details to Pandit',
                  ),
                  onPressed: booking == null
                      ? null
                      : () {
                          WhatsAppHelper.openChat(
                            message:
                                'Namaste Pandit ji,\n\n'
                                'A pooja has been booked via Shubh Pooja App.\n\n'
                                'User ID: $displayUserId\n'
                                'Transaction ID: ${BookingSession.transactionId}\n\n'
                                'Ritual: ${booking.ritualName}\n'
                                'Pandit: ${booking.panditName ?? 'Not assigned'}\n'
                                'Date & Time: '
                                '${booking.selectedDate?.day}/${booking.selectedDate?.month}/${booking.selectedDate?.year} '
                                '${booking.selectedTime ?? ''}\n'
                                'Address: ${booking.address ?? 'NA'}\n\n'
                                'Please confirm availability.\n\n'
                                '— Shubh Pooja App',
                          );
                        },
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => context.go('/landing'),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
