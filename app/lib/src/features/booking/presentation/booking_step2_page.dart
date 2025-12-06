// lib/src/features/booking/presentation/booking_step2_page.dart
// Booking Flow — Step 2: Personal & Address Details
// Enhanced Modern UI (CRED-inspired) • Clean Architecture • Riverpod

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Providers for form fields
final fullNameProvider = StateProvider<String>((ref) => "");
final phoneProvider = StateProvider<String>((ref) => "");
final emailProvider = StateProvider<String>((ref) => "");
final address1Provider = StateProvider<String>((ref) => "");
final address2Provider = StateProvider<String>((ref) => "");
final cityProvider = StateProvider<String>((ref) => "");
final pincodeProvider = StateProvider<String>((ref) => "");
final instructionsProvider = StateProvider<String>((ref) => "");

class BookingStep2Page extends ConsumerWidget {
  final String panditName;
  const BookingStep2Page({super.key, required this.panditName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Your Details"),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: "Personal Information",
              children: [
                _InputField(
                  label: "Full Name",
                  icon: Icons.person_outline,
                  value: ref.watch(fullNameProvider),
                  onChanged: (v) => ref.read(fullNameProvider.notifier).state = v,
                ),
                _InputField(
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  value: ref.watch(phoneProvider),
                  onChanged: (v) => ref.read(phoneProvider.notifier).state = v,
                ),
                _InputField(
                  label: "Email (optional)",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  value: ref.watch(emailProvider),
                  onChanged: (v) => ref.read(emailProvider.notifier).state = v,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionCard(
              title: "Address Details",
              children: [
                _InputField(
                  label: "Address Line 1",
                  icon: Icons.home_outlined,
                  value: ref.watch(address1Provider),
                  onChanged: (v) => ref.read(address1Provider.notifier).state = v,
                ),
                _InputField(
                  label: "Address Line 2 (optional)",
                  icon: Icons.location_city_outlined,
                  value: ref.watch(address2Provider),
                  onChanged: (v) => ref.read(address2Provider.notifier).state = v,
                ),
                _InputField(
                  label: "City",
                  icon: Icons.location_on_outlined,
                  value: ref.watch(cityProvider),
                  onChanged: (v) => ref.read(cityProvider.notifier).state = v,
                ),
                _InputField(
                  label: "Pincode",
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  value: ref.watch(pincodeProvider),
                  onChanged: (v) => ref.read(pincodeProvider.notifier).state = v,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionCard(
              title: "Special Instructions",
              children: [
                _InputField(
                  label: "Add any notes for the pandit",
                  icon: Icons.edit_outlined,
                  maxLines: 4,
                  value: ref.watch(instructionsProvider),
                  onChanged: (v) => ref.read(instructionsProvider.notifier).state = v,
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomSheet: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              context.push('/booking/confirm/${panditName}');
            },
            child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------
// Section Card UI (CRED-inspired minimal luxury)
// ------------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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

// ------------------------------------------------
// Input Field with Icon
// ------------------------------------------------
class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
