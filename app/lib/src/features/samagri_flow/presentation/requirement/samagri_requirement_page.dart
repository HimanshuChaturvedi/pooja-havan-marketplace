import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import 'widgets/samagri_option_card.dart';

enum SamagriChoice { yes, no }

class SamagriRequirementPage extends StatefulWidget {
  const SamagriRequirementPage({super.key});

  @override
  State<SamagriRequirementPage> createState() =>
      _SamagriRequirementPageState();
}

class _SamagriRequirementPageState extends State<SamagriRequirementPage> {
  SamagriChoice? choice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Samagri Requirement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SamagriOptionCard(
              title: 'Yes, arrange Samagri',
              isSelected: choice == SamagriChoice.yes,
              onTap: () => setState(() => choice = SamagriChoice.yes),
            ),
            const SizedBox(height: 16),
            SamagriOptionCard(
              title: 'No, I already have Samagri',
              isSelected: choice == SamagriChoice.no,
              onTap: () => setState(() => choice = SamagriChoice.no),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: choice == null
                    ? null
                    : () {
                        BookingSession.current!.samagriRequired =
                            choice == SamagriChoice.yes;

                        if (choice == SamagriChoice.yes) {
                          // 🔑 GO TO SAMAGRI LIST
                          context.push('/samagri-list');
                        } else {
                          // 🔑 SKIP → SUMMARY
                          context.push('/home-summary');
                        }
                      },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
