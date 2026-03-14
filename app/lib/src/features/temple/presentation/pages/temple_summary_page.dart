import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_session_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';

class TempleSummaryPage extends ConsumerWidget {
  final String temple;
  final String city;
  final String ritual;
  final String date;
  final String slot;

  const TempleSummaryPage({
    super.key,
    required this.temple,
    required this.city,
    required this.ritual,
    required this.date,
    required this.slot,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Booking Summary',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ✅ BOOKING INFO CARD
            PrimaryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, color: AppColors.saffron, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Temple Booking',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.black12),
                  _SummaryRow(label: 'Temple', value: temple),
                  _SummaryRow(label: 'City', value: city),
                  _SummaryRow(label: 'Ritual', value: ritual),
                  _SummaryRow(label: 'Date', value: date),
                  _SummaryRow(label: 'Time Slot', value: slot),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ℹ️ INFO NOTICE
            PrimaryCard(
              padding: const EdgeInsets.all(20),
              color: AppColors.saffron.withOpacity(0.05),
              showShadow: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.saffron, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The temple priest will confirm your booking within 2 hours. You will receive a notification once confirmed.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.softGrey,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          label: 'Confirm Temple Booking',
          onTap: () {
            ref.read(bookingSessionProvider.notifier).reset();
            ref.read(samagriSessionProvider.notifier).clear();
            ref.read(samagriCartProvider.notifier).clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Temple booking confirmed! (Pilot mode)')),
            );
            context.go('/landing');
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.softGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
