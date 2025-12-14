import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';
import 'widgets/samagri_option_card.dart';

enum SamagriChoice { yes, no }

class SamagriRequirementPage extends StatefulWidget {
  const SamagriRequirementPage({super.key});

  @override
  State<SamagriRequirementPage> createState() =>
      _SamagriRequirementPageState();
}

class _SamagriRequirementPageState extends State<SamagriRequirementPage> {
  SamagriChoice? selectedChoice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Samagri Requirement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Would you like us to arrange the pooja samagri?',
            ),
            const SizedBox(height: 24),

            SamagriOptionCard(
              title: 'Yes, arrange Samagri',
              isSelected: selectedChoice == SamagriChoice.yes,
              onTap: () => setState(() {
                selectedChoice = SamagriChoice.yes;
              }),
            ),

            const SizedBox(height: 16),

            SamagriOptionCard(
              title: 'No, I already have Samagri',
              isSelected: selectedChoice == SamagriChoice.no,
              onTap: () => setState(() {
                selectedChoice = SamagriChoice.no;
              }),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedChoice == null
                    ? null
                    : () {
                        if (selectedChoice == SamagriChoice.yes) {
                          BookingSession.current?.samagriRequired = true;
                          BookingSession.current?.samagriItems.clear();
                          context.push('/samagri-list');
                        } else {
                          BookingSession.current?.samagriRequired = false;

                          if (BookingSession.current?.bookingType ==
                              BookingType.temple) {
                            context.push('/pandit-selection');
                          } else {
                            context.push('/home-summary');
                          }
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
