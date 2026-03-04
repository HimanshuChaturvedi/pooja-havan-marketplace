import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/features/home_booking/presentation/address/home_address_page.dart';
import 'package:app/src/features/home_booking/presentation/address/state/address_provider.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class SamagriAddressPage extends ConsumerWidget {
  const SamagriAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressBookProvider);

    if (addresses.isEmpty) {
      return HomeAddressPage(
        city: 'Delivery Location',
        onAddressSaved: (addressText) {
          SamagriSession.attachAddress(addressText);
          context.go('/payment');
        },
      );
    }

    return AppScaffold(
      title: 'Select Delivery Address',
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                SamagriSession.attachAddress(
                  '${address.line1}, ${address.city}',
                  addressId: address.id,
                );
                context.go('/payment');
              },
              child: PrimaryCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_outlined, color: AppColors.saffron, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.line1,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address.city,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.softGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.saffron, size: 14),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
