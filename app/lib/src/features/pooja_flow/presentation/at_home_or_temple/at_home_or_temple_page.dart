import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/choice_card.dart';

enum PoojaLocationType { home, temple }

class AtHomeOrTemplePage extends StatefulWidget {
  final String city;
  final String ritualSlug;
  final String ritualName;

  const AtHomeOrTemplePage({
    super.key,
    required this.city,
    required this.ritualSlug,
    required this.ritualName,
  });


  @override
  State<AtHomeOrTemplePage> createState() => _AtHomeOrTemplePageState();
}

class _AtHomeOrTemplePageState extends State<AtHomeOrTemplePage> {
  PoojaLocationType? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pooja Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where would you like to perform the Pooja?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can choose to perform the ritual at your home or at a temple.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            ChoiceCard(
              title: 'At Home',
              description:
                  'Pandit will perform the pooja at your home location.',
              isSelected: selectedType == PoojaLocationType.home,
              onTap: () {
                setState(() {
                  selectedType = PoojaLocationType.home;
                });
              },
            ),

            const SizedBox(height: 16),

            ChoiceCard(
              title: 'At Temple',
              description:
                  'Perform the pooja at a nearby or selected temple.',
              isSelected: selectedType == PoojaLocationType.temple,
              onTap: () {
                setState(() {
                  selectedType = PoojaLocationType.temple;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedType == null
    ? null
    : () {
        if (selectedType == PoojaLocationType.temple) {
          final encodedCity = Uri.encodeComponent(widget.city);
          context.push('/temples/$encodedCity');
        } else {
          context.push(
  '/home-address',
  extra: {
    'city': widget.city,
  },
);

        }
      },

          child: const Text('Continue'),
        ),
      ),
    );
  }
}
