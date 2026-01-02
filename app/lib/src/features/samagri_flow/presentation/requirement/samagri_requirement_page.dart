import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';

class SamagriRequirementPage extends StatelessWidget {
  const SamagriRequirementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Samagri Requirement'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Do you want us to arrange samagri?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ YES — ARRANGE SAMAGRI
            _optionCard(
              title: 'Yes, arrange samagri',
              subtitle:
                  'You can select required samagri items',
              onTap: () {
                // 🔑 Booking flow decision
                BookingSession.samagriDecisionTaken = true;

                // 🔑 Go to Samagri selection (NOT summary)
                context.push('/samagri-list');
              },
            ),

            const SizedBox(height: 16),

            // ✅ NO — USER ARRANGES SAMAGRI
            _optionCard(
              title: 'No, I will arrange myself',
              subtitle:
                  'Proceed without samagri',
              onTap: () {
                BookingSession.samagriDecisionTaken = false;

                // 🔑 Directly to Booking Summary
                context.push('/home-summary');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
