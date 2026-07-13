import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class BookingDetailPage extends ConsumerWidget {
  final BookingDraft booking;
  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    // Identification check: If current user is the one assigned as pandit_id, then treat as Pandit view
    final currentUserId = supabase.auth.currentUser?.id;
    final isPanditView = currentUserId == booking.panditId;
    return AppScaffold(
      title: 'Booking Details',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // STATUS HEADER
            PrimaryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor(booking.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_statusIcon(booking.status), color: _statusColor(booking.status), size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    booking.status.name.toUpperCase(),
                    style: AppTextStyles.title.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _statusColor(booking.status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _titleFromBooking(booking),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (booking.status == BookingStatusDetailed.rejected) ...[
              PrimaryCard(
                color: Colors.red.shade50,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your order could not be fulfilled by the selected vendor. Our team has been notified and will reassess your request.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // DETAILS CARD
            PrimaryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Info',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const Divider(height: 32, color: Colors.black12),
                  _DetailRow(label: 'Item/Ritual', value: booking.ritualName),
                  _DetailRow(label: 'Reference ID', value: booking.referenceId ?? 'PHM-PENDING'),
                  if (booking.selectedDate != null)
                    _DetailRow(
                      label: 'Date',
                      value: '${booking.selectedDate!.day.toString().padLeft(2, '0')}/${booking.selectedDate!.month.toString().padLeft(2, '0')}/${booking.selectedDate!.year}${booking.selectedTime != null ? " at ${booking.selectedTime}" : ""}',
                    ),
                  if (booking.address != null)
                    _DetailRow(label: 'Address', value: booking.address!),
                  if (booking.bookingType != BookingType.shop)
                    _DetailRow(label: 'Pandit', value: booking.panditName ?? 'Allocating Soon'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PRICE BREAKDOWN
            PrimaryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Price Breakdown',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const Divider(height: 32, color: Colors.black12),
                  if (booking.poojaDakshina > 0)
                    _DetailRow(label: 'Pooja Dakshina', value: '₹${booking.poojaDakshina}'),
                  if (!isPanditView && booking.samagriCharges > 0)
                    _DetailRow(label: 'Samagri Charges', value: '₹${booking.samagriCharges}'),
                  if (!isPanditView && booking.deliveryFee > 0)
                    _DetailRow(label: 'Delivery Fee', value: '₹${booking.deliveryFee}'),
                  if (!isPanditView && booking.platformFee > 0)
                    _DetailRow(label: 'Platform Fee', value: '₹${booking.platformFee}'),
                  const Divider(height: 24, color: Colors.black12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPanditView ? 'Earning' : 'Total Paid',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      Text(
                        '₹${isPanditView ? booking.poojaDakshina.toInt() : booking.totalAmount.toInt()}',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.saffron,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _titleFromBooking(BookingDraft b) {
    switch (b.bookingType) {
      case BookingType.home:
        return 'Home Pooja';
      case BookingType.temple:
        return 'Temple Ritual';
      case BookingType.shop:
        return 'Shop Order';
      default:
        return 'Booking';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
 
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
 
Color _statusColor(BookingStatusDetailed status) {
  switch (status) {
    case BookingStatusDetailed.created:
      return AppColors.saffron;
    case BookingStatusDetailed.assigned:
      return Colors.blue;
    case BookingStatusDetailed.onWay:
      return Colors.orange;
    case BookingStatusDetailed.inProgress:
      return Colors.purple;
    case BookingStatusDetailed.paid:
      return Colors.teal;
    case BookingStatusDetailed.confirmed:
      return Colors.blue;
    case BookingStatusDetailed.completed:
      return Colors.green;
    case BookingStatusDetailed.cancelled:
      return Colors.red;
    case BookingStatusDetailed.rejected:
      return Colors.red;
  }
}
 
IconData _statusIcon(BookingStatusDetailed status) {
  switch (status) {
    case BookingStatusDetailed.created:
      return Icons.info_outline;
    case BookingStatusDetailed.assigned:
      return Icons.person_outline;
    case BookingStatusDetailed.onWay:
      return Icons.directions_bike;
    case BookingStatusDetailed.inProgress:
      return Icons.sync;
    case BookingStatusDetailed.paid:
      return Icons.payments_outlined;
    case BookingStatusDetailed.confirmed:
      return Icons.verified_outlined;
    case BookingStatusDetailed.completed:
      return Icons.check_circle_outline;
    case BookingStatusDetailed.cancelled:
      return Icons.cancel_outlined;
    case BookingStatusDetailed.rejected:
      return Icons.cancel_outlined;
  }
}
