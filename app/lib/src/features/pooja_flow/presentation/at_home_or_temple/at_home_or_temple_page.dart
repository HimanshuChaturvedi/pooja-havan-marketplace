import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where would you like to perform the pooja?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose the location that suits you best.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 28),

            ChoiceCard(
              title: 'At Home',
              description:
                  'Pandit will visit your home and perform the pooja.',
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

            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: selectedType == null
                ? null
                : () {
                    if (BookingSession.current == null) return;

                    if (selectedType == PoojaLocationType.home) {
                      BookingSession.current!.bookingType = BookingType.home;
                      context.push('/home-address');
                    } else {
                      BookingSession.current!.bookingType =
                          BookingType.temple;
                      final city =
                          Uri.encodeComponent(widget.city);
                      context.push('/temples/$city');
                    }
                  },
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}
