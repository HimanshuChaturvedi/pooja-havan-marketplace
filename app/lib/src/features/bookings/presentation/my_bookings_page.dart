import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/features/booking/data/booking_providers.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/core/utils/logger.dart';

import 'booking_detail_page.dart';

class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key});

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    AppLogger.info('MyBookingsPage mounted');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return AppScaffold(
      title: 'My Bookings',
      body: RefreshIndicator(
        color: AppColors.saffron,
        onRefresh: () async {
          AppLogger.debug('Refreshing bookings list');
          return ref.invalidate(bookingsProvider);
        },
        child: bookingsAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: AppColors.saffron)),
          error: (err, stack) {
            AppLogger.error('Failed to fetch bookings', err, stack);
            return Center(child: Text('Error: $err', style: AppTextStyles.bodyMedium));
          },
          data: (bookings) => bookings.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _StaggeredFade(
                      controller: _animController,
                      delay: 100 + (index * 100),
                      child: _BookingCard(booking: booking),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingDraft booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppLogger.info('Navigating to detail for: ${booking.id}');
        context.pushNamed('booking-detail', extra: booking);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: PrimaryCard(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _titleFromBooking(booking).toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.saffron,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 🚀 UX TAGS — distinguish shop orders from pooja items
                    if (booking.bookingType == BookingType.shop)
                      _Badge(label: 'STANDALONE', color: Colors.blue),
                    if (booking.bookingType != BookingType.shop && booking.samagriRequired)
                      _Badge(label: '+ SAMAGRI', color: Colors.green),
                  ],
                ),
                Text(
                  '₹${booking.totalAmount}',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.darkCharcoal, 
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              booking.ritualName,
              style: AppTextStyles.title.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
            SizedBox(height: 12),
            _InfoLine(
              label: 'Type', 
              value: booking.bookingType == BookingType.shop ? 'SHOP ORDER' : booking.bookingType.name.toUpperCase(),
            ),
            const SizedBox(height: 6),
            if (booking.selectedDate != null) ...[
              _InfoLine(
                label: 'Scheduled',
                value: '${booking.selectedDate!.day.toString().padLeft(2, '0')}/${booking.selectedDate!.month.toString().padLeft(2, '0')}/${booking.selectedDate!.year} at ${booking.selectedTime ?? '--'}',
              ),
            ],
            const SizedBox(height: 6),
            _InfoLine(
              label: 'Status',
              value: 'Confirmed',
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
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

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ', 
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.softGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _formatDateTime(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: AppColors.softGrey.withOpacity(0.2), size: 64),
          SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
          ),
        ],
      ),
    );
  }
}

class _StaggeredFade extends StatelessWidget {
  final AnimationController controller;
  final int delay;
  final Widget child;

  const _StaggeredFade({required this.controller, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final start = (delay / 1500).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1500).clamp(0, 1.0).toDouble();
        
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ).value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
    );
  }
}
