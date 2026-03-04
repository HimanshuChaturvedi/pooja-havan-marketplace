import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';
import '../../../samagri_flow/application/samagri_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({super.key});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BookingSession.activeFlow = ActiveFlow.booking;
    final booking = BookingSession.current;

    if (booking == null) {
      return const AppScaffold(
        title: 'Error',
        body: Center(child: Text('No booking data found')),
      );
    }

    const int poojaCost = 2100;
    final bool samagriRequired = BookingSession.samagriDecisionTaken;
    final samagriSession = SamagriSession.current;
    final int samagriCost = samagriRequired && samagriSession != null ? samagriSession.totalAmount : 0;
    final int totalAmount = poojaCost + samagriCost;

    return WillPopScope(
      onWillPop: () async {
        BookingSession.reset();
        return true;
      },
      child: AppScaffold(
        title: 'Booking Summary',
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: SectionHeader(title: booking.bookingType == BookingType.home ? 'Ceremony Location' : 'Sacred Temple'),
              ),
              _StaggeredFade(
                controller: _animController,
                delay: 200,
                child: _InfoCard(
                  text: booking.bookingType == BookingType.home
                      ? '${booking.address}\n${booking.city}'
                      : '${booking.templeName}\n${booking.city}',
                  icon: Icons.location_on_rounded,
                ),
              ),

              const SizedBox(height: 32),

              _StaggeredFade(
                controller: _animController,
                delay: 300,
                child: const SectionHeader(title: 'Date & Time'),
              ),
              _StaggeredFade(
                controller: _animController,
                delay: 400,
                child: _InfoCard(
                  text: '${booking.selectedDate?.day.toString().padLeft(2, '0')}/${booking.selectedDate?.month.toString().padLeft(2, '0')}/${booking.selectedDate?.year}'
                  ' at ${booking.selectedTime}',
                  icon: Icons.calendar_month_rounded,
                ),
              ),

              if (booking.panditName != null) ...[
                const SizedBox(height: 32),
                _StaggeredFade(
                  controller: _animController,
                  delay: 500,
                  child: const SectionHeader(title: 'Divine Guide (Pandit)'),
                ),
                _StaggeredFade(
                  controller: _animController,
                  delay: 600,
                  child: _InfoCard(text: booking.panditName!, icon: Icons.person_rounded),
                ),
              ],

              const SizedBox(height: 32),

              _StaggeredFade(
                controller: _animController,
                delay: 700,
                child: const SectionHeader(title: 'Ritual Materials'),
              ),
              _StaggeredFade(
                controller: _animController,
                delay: 800,
                child: !samagriRequired
                    ? const _InfoCard(text: 'Samagri will be arranged by you', icon: Icons.shopping_basket_rounded)
                    : (samagriSession == null || samagriSession.items.isEmpty)
                        ? const _InfoCard(text: 'Full samagri set will be arranged by us', icon: Icons.auto_awesome_rounded)
                        : _SamagriSummaryCard(session: samagriSession),
              ),

              const SizedBox(height: 48),

              _StaggeredFade(
                controller: _animController,
                delay: 900,
                child: PrimaryCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOOKING DETAILS',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.softGrey,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _statusLine('Booking Status', 'Draft / Review'),
                      const SizedBox(height: 12),
                      _statusLine('Payment Status', 'Manual Payment'),
                      const SizedBox(height: 12),
                      _statusLine('Estimated Duration', '90 - 120 Mins'),
                      const Divider(height: 48, color: Colors.black12),
                      Text(
                        'PRICE BREAKDOWN',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.softGrey,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _PriceRow(label: 'Ritual Dakshina', amount: poojaCost),
                      if (samagriRequired) ...[
                        const SizedBox(height: 16),
                        _PriceRow(label: 'Samagri Charges', amount: samagriCost),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.black12, height: 1),
                      ),
                      _PriceRow(label: 'Total Amount', amount: totalAmount, isTotal: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: PrimaryButton(
            label: 'Proceed to Payment →',
            onTap: () {
              BookingSession.status = BookingStatus.paymentPending;
              context.push('/payment');
            },
          ),
        ),
      ),
    );
  }

  Widget _statusLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.softGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.darkCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const _InfoCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.saffron.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.saffron, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.darkCharcoal,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SamagriSummaryCard extends StatelessWidget {
  final SamagriSession session;
  const _SamagriSummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.saffron, size: 20),
              const SizedBox(width: 12),
              Text(
                'Items to be arranged by us',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkCharcoal, 
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.black12),
          ...session.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.name} × ${item.quantity}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.softGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${item.unitPrice * item.quantity}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.darkCharcoal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}


class _PriceRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isTotal;
  const _PriceRow({required this.label, required this.amount, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.title.copyWith(color: AppColors.darkCharcoal, fontSize: 18, fontWeight: FontWeight.w900)
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey, fontWeight: FontWeight.w700),
        ),
        Text(
          '₹$amount',
          style: isTotal
              ? AppTextStyles.title.copyWith(color: AppColors.saffron, fontSize: 26, fontWeight: FontWeight.w900)
              : AppTextStyles.bodyLarge.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w900),
        ),
      ],
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
        final start = (delay / 1200).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1200).clamp(0, 1.0).toDouble();
        
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
