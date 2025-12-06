// lib/src/features/booking/presentation/booking_review_page.dart
// Booking Flow — Step 3: Review & Confirm
// Enhanced Modern UI • Clean Architecture • Riverpod

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/booking_step1_page.dart';
import '../presentation/booking_step2_page.dart';

class BookingReviewPage extends ConsumerWidget {
  final String panditName;

  const BookingReviewPage({super.key, required this.panditName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final date = ref.watch(selectedDateProvider);
    final time = ref.watch(selectedTimeProvider);
    final name = ref.watch(fullNameProvider);
    final phone = ref.watch(phoneProvider);
    final email = ref.watch(emailProvider);
    final address1 = ref.watch(address1Provider);
    final address2 = ref.watch(address2Provider);
    final city = ref.watch(cityProvider);
    final pincode = ref.watch(pincodeProvider);
    final notes = ref.watch(instructionsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Review & Confirm"),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(title: "Pandit Details", children: [
              _RowText(label: "Pandit", value: panditName),
            ]),

            const SizedBox(height: 20),

            _SectionCard(title: "Selected Date & Time", children: [
              _RowText(label: "Date", value: date != null ? _formatDate(date) : "Not selected"),
              _RowText(label: "Time", value: time ?? "Not selected"),
            ]),

            const SizedBox(height: 20),

            _SectionCard(title: "Personal Information", children: [
              _RowText(label: "Name", value: name),
              _RowText(label: "Phone", value: phone),
              _RowText(label: "Email", value: email.isEmpty ? "—" : email),
            ]),

            const SizedBox(height: 20),

            _SectionCard(title: "Address", children: [
              _RowText(label: "Address 1", value: address1),
              _RowText(label: "Address 2", value: address2.isEmpty ? "—" : address2),
              _RowText(label: "City", value: city),
              _RowText(label: "Pincode", value: pincode),
            ]),

            const SizedBox(height: 20),

            _SectionCard(title: "Special Instructions", children: [
              Text(notes.isEmpty ? "No instructions added" : notes,
                  style: TextStyle(color: Colors.grey.shade700)),
            ]),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surface,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              context.push('/payment/${panditName}');
            },
            child: const Text("Proceed to Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------
// Reusable UI Components
// --------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  final String label;
  final String value;
  const _RowText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}