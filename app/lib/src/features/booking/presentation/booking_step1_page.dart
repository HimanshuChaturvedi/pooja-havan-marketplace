// lib/src/features/booking/presentation/booking_step1_page.dart
// Booking Flow — Step 1: Select Date & Time
// Full production-ready file (Clean Architecture + Riverpod + GoRouter)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ROUTE CONSTANT
const String kRouteBookingStep1 = '/booking/:panditName';

// Providers for selected date and time
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<String?>((ref) => null);

class BookingStep1Page extends ConsumerWidget {
  final String panditName;

  const BookingStep1Page({super.key, required this.panditName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text("Book: $panditName"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Calendar Section
            SizedBox(
              height: 320,
              child: CalendarDatePicker(
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                initialDate: selectedDate ?? DateTime.now(),
                onDateChanged: (value) {
                  ref.read(selectedDateProvider.notifier).state = value;
                },
              ),
            ),

            const SizedBox(height: 24),

            const Text("Select Time Slot", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                final isSelected = selectedTime == slot;
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedTimeProvider.notifier).state = slot;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.15)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(slot,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.shade700,
                        )),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // CTA BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedDate != null && selectedTime != null)
                    ? () {
                        context.push('/booking/details/${panditName}');
                      }
                    : null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Available time slots (later fetched dynamically)
const List<String> _timeSlots = [
  "07:00 AM",
  "08:00 AM",
  "09:00 AM",
  "10:00 AM",
  "11:00 AM",
  "12:00 PM",
  "02:00 PM",
  "03:00 PM",
  "04:00 PM",
  "06:00 PM",
];
