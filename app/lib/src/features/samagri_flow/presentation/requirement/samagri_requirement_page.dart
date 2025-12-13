import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        title: const Text('Samagri Requirement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Would you like us to arrange the pooja samagri for you?',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            SamagriOptionCard(
              title: 'Yes, arrange Samagri',
              isSelected: selectedChoice == SamagriChoice.yes,
              onTap: () {
                setState(() {
                  selectedChoice = SamagriChoice.yes;
                });
              },
            ),

            const SizedBox(height: 16),

            SamagriOptionCard(
              title: 'No, I already have Samagri',
              isSelected: selectedChoice == SamagriChoice.no,
              onTap: () {
                setState(() {
                  selectedChoice = SamagriChoice.no;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedChoice == null
                    ? null
                    : () {
                        if (selectedChoice == SamagriChoice.yes) {
                          // Go to Samagri module (next step)
                          context.push('/samagri-list');
                        } else {
                          // Skip Samagri
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
