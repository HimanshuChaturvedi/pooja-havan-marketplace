import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';

class TempleDetailsPage extends StatelessWidget {
  const TempleDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = BookingSession.current;

    final templeName = booking?.templeName ?? 'Selected Temple';
    final city = booking?.city ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(templeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/landing'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              templeName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              city,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),

            const Text(
              'About Temple',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a renowned temple where traditional '
              'Vedic poojas and havans are performed daily by '
              'experienced pandits.',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/temple-date-time');
                },
                child: const Text('Continue Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
