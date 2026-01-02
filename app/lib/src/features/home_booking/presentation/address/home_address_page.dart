import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import 'widgets/address_text_field.dart';

/// 🔑 NOTE:
/// This page is used by:
/// 1️⃣ Book a Pooja (existing flow)
/// 2️⃣ Buy Samagri (reused via optional callback)
class HomeAddressPage extends StatefulWidget {
  final String city;

  /// 🔑 OPTIONAL callback
  /// If provided, caller will handle navigation
  final void Function(String address)? onAddressSaved;

  const HomeAddressPage({
    super.key,
    required this.city,
    this.onAddressSaved,
  });

  @override
  State<HomeAddressPage> createState() =>
      _HomeAddressPageState();
}

class _HomeAddressPageState
    extends State<HomeAddressPage> {
  final TextEditingController _addressController =
      TextEditingController();

  bool get isAddressValid =>
      _addressController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Home Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide the address where the pooja will be performed.',
            ),
            const SizedBox(height: 20),

            const Text(
              'City',
              style:
                  TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(widget.city),
            ),

            const SizedBox(height: 20),

            AddressTextField(
              controller: _addressController,
              hintText:
                  'House No, Area, Society, Landmark',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAddressValid
                    ? () {
                        final address =
                            _addressController.text
                                .trim();

                        // ----------------------------
                        // CASE 1: Buy Samagri flow
                        // ----------------------------
                        if (widget.onAddressSaved !=
                            null) {
                          widget.onAddressSaved!(
                              address);
                          return;
                        }

                        // ----------------------------
                        // CASE 2: Booking flow (existing)
                        // ----------------------------
                        BookingSession.current?.address =
                            address;

                        context.push(
                            '/pandit-selection');
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
