import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';

class PanditDetailsPage extends StatelessWidget {
  final String panditName;

  const PanditDetailsPage({
    super.key,
    required this.panditName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pandit Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAME
            Text(
              panditName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // RATING
            Row(
              children: const [
                Icon(Icons.star, color: Colors.orange, size: 20),
                SizedBox(width: 4),
                Text('4.8 (120 reviews)'),
              ],
            ),

            const SizedBox(height: 20),

            _infoSection(
              title: 'Experience',
              value: '12+ years of experience in Vedic rituals',
            ),

            _infoSection(
              title: 'Specialization',
              value:
                  'Grih Pravesh, Havan, Satyanarayan Katha, Marriage Rituals',
            ),

            _infoSection(
              title: 'Languages',
              value: 'Hindi, Sanskrit',
            ),

            _infoSection(
              title: 'Education',
              value: 'Shastri from Kashi Vidyapeeth',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // 🔑 SAVE SELECTED PANDIT
                  BookingSession.current?.panditName = panditName;

                  // 🔑 CONTINUE FLOW
                  context.push('/home-date-time');
                },
                child: const Text('Select Pandit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
