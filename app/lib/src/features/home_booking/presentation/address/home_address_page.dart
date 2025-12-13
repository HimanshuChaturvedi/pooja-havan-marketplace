import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/address_text_field.dart';

class HomeAddressPage extends StatefulWidget {
  final String city;

  const HomeAddressPage({
    super.key,
    required this.city,
  });

  @override
  State<HomeAddressPage> createState() => _HomeAddressPageState();
}

class _HomeAddressPageState extends State<HomeAddressPage> {
  final TextEditingController _addressController = TextEditingController();
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

  bool get isAddressValid => _addressController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Home Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide the address where the pooja will be performed.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // CITY (READ ONLY)
            Text(
              'City',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(widget.city),
            ),

            const SizedBox(height: 20),

            // ADDRESS FIELD
            Text(
              'Complete Address',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),

            AddressTextField(
  controller: _addressController,
  hintText: 'House No, Area, Society, Landmark',
),



            const Spacer(),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAddressValid
                    ? () {
                        context.push('/home-date-time');
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
