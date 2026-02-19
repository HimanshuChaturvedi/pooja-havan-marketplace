import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import '../../application/samagri_session.dart';
import '../../state/samagri_cart_notifier.dart';
import '../../state/samagri_item.dart' as CatalogItem;
import '../../../booking/application/booking_session.dart';

class SamagriCartPage extends ConsumerWidget {
  const SamagriCartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(samagriCartProvider);
    final items = cart.items.entries.toList();
    final hasItems = items.isNotEmpty;
    final isBookingFlow = BookingSession.current != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Samagri Cart',
          style: AppTextStyles.title.copyWith(color: AppColors.maroon, fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.midnight, AppColors.midnight.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: hasItems
            ? ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final entry = items[index];
                  final CatalogItem.SamagriItem item = entry.key;
                  final qty = entry.value;

                  return _CartItemRow(
                    name: item.name,
                    qty: qty,
                    price: (item.price * qty).round(),
                  );
                },
              )
            : Center(
                child: Text(
                  'No items in cart',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon.withOpacity(0.5)),
                ),
              ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.midnight.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.saffron,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: hasItems
              ? () {
                  SamagriSession.createFromCart(
                    items: items.map((e) {
                      final CatalogItem.SamagriItem i = e.key;
                      return SamagriItem(
                        itemId: i.id,
                        name: i.name,
                        unitPrice: i.price.round(),
                        quantity: e.value,
                      );
                    }).toList(),
                    isPartOfBooking: isBookingFlow,
                  );

                  context.push(
                    isBookingFlow ? '/samagri-summary' : '/samagri-address',
                  );
                }
              : null,
          child: Text(
            'Continue • ₹${cart.totalAmount.round()} →',
            style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final String name;
  final int qty;
  final int price;

  const _CartItemRow({
    required this.name,
    required this.qty,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$name × $qty',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon, fontSize: 16),
            ),
          ),
          Text(
            '₹$price',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
