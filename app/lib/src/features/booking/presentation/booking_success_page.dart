import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                size: 72, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Your booking is confirmed',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/landing'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
