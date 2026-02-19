import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../home_booking/presentation/address/home_address_page.dart';
import '../../../home_booking/presentation/address/state/address_provider.dart';
import '../../application/samagri_session.dart';

class SamagriAddressPage extends ConsumerWidget {
  const SamagriAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressBookProvider);

    // 🟢 CASE 1: No saved address → reuse Home Address form
    if (addresses.isEmpty) {
      return HomeAddressPage(
        city: 'Delivery Location',
        onAddressSaved: (addressText) {
          // ✅ Attach raw address text
          SamagriSession.attachAddress(addressText);

          // 👉 Go to payment
          context.go('/payment');
        },
      );
    }

    // 🟢 CASE 2: Saved addresses exist → select one
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Card(
            child: ListTile(
              title: Text(address.line1),
              subtitle: Text(address.city),
              onTap: () {
                // ✅ Attach selected address as text + ID
                SamagriSession.attachAddress(
                  '${address.line1}, ${address.city}',
                  addressId: address.id,
                );

                context.go('/payment');
              },
            ),
          );
        },
      ),
    );
  }
}
