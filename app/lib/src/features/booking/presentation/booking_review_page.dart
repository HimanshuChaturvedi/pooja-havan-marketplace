import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/booking_session.dart';
import '../domain/booking_draft.dart';
import 'booking_step1_page.dart';
import 'booking_step2_page.dart';

class BookingReviewPage extends ConsumerWidget {
  final String panditName;

  const BookingReviewPage({super.key, required this.panditName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = BookingSession.current;
    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('No booking found')),
      );
    }

    final date = ref.watch(selectedDateProvider);
    final time = ref.watch(selectedTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Confirm'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pandit: $panditName'),
            const SizedBox(height: 8),
            Text('Date: ${date != null ? _formatDate(date) : '-'}'),
            Text('Time: ${time ?? '-'}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // 🔑 Booking enters payment stage
                  BookingSession.status = BookingStatus.paymentPending;
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
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
