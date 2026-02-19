import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';
import '../../../samagri_flow/application/samagri_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

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
    // 🔒 MARK FLOW AS BOOKING (CRITICAL FIX)
    BookingSession.activeFlow = ActiveFlow.booking;

    final booking = BookingSession.current;

    if (booking == null) {
      return const Scaffold(
        body: Center(child: Text('No booking data found', style: TextStyle(color: AppColors.maroon))),
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
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Booking Summary',
            style: AppTextStyles.title.copyWith(fontSize: 22),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.maroon),
        ),
        body: DivineBackground(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StaggeredFade(
                        controller: _animController,
                        delay: 100,
                        child: _sectionTitle(booking.bookingType == BookingType.home ? 'Ceremony Location' : 'Sacred Temple'),
                      ),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 200,
                        child: _infoTile(
                          booking.bookingType == BookingType.home
                              ? '${booking.address}\n${booking.city}'
                              : '${booking.templeName}\n${booking.city}',
                          Icons.location_on_outlined,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _StaggeredFade(
                        controller: _animController,
                        delay: 300,
                        child: _sectionTitle('Date & Time'),
                      ),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 400,
                        child: _infoTile(
                          '${booking.selectedDate?.day.toString().padLeft(2, '0')}/${booking.selectedDate?.month.toString().padLeft(2, '0')}/${booking.selectedDate?.year}'
                          ' at ${booking.selectedTime}',
                          Icons.calendar_month_outlined,
                        ),
                      ),

                      if (booking.panditName != null) ...[
                        const SizedBox(height: 24),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 500,
                          child: _sectionTitle('Divine Guide (Pandit)'),
                        ),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 600,
                          child: _infoTile(booking.panditName!, Icons.person_outline),
                        ),
                      ],

                      const SizedBox(height: 24),

                      _StaggeredFade(
                        controller: _animController,
                        delay: 700,
                        child: _sectionTitle('Ritual Materials (Samagri)'),
                      ),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 800,
                        child: !samagriRequired
                            ? _infoTile('Samagri will be arranged by you', Icons.shopping_basket_outlined)
                            : (samagriSession == null || samagriSession.items.isEmpty)
                                ? _infoTile('Full samagri set will be arranged by us', Icons.auto_awesome_outlined)
                                : _samagriList(samagriSession),
                      ),

                      const SizedBox(height: 32),

                      _StaggeredFade(
                        controller: _animController,
                        delay: 900,
                        child: DivineGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Breakdown',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _priceRow('Pooja Dakshina', poojaCost),
                              if (samagriRequired) ...[
                                const SizedBox(height: 12),
                                _priceRow('Samagri Charges', samagriCost),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Colors.black12),
                              ),
                              _priceRow('Total Amount', totalAmount, isTotal: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.dawnOrange.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffron,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                      shadowColor: AppColors.saffron.withOpacity(0.5),
                    ),
                    onPressed: () {
                      BookingSession.status = BookingStatus.paymentPending;
                      context.push('/payment');
                    },
                    child: Text(
                      'Proceed to Payment →',
                      style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.deepSaffron,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _infoTile(String text, IconData icon) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.cream.withOpacity(0.4), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon, height: 1.4, fontSize: 16),
              ),
            ),
          ],
        ),
      );

  Widget _samagriList(SamagriSession session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: 12),
              Text(
                'Items to be arranged by us',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.black12),
          ),
          ...session.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.name} × ${item.quantity}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.deepSaffron.withOpacity(0.7)),
                  ),
                  Text(
                    '₹${item.unitPrice * item.quantity}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.maroon),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _priceRow(String label, int amount, {bool isTotal = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.title.copyWith(color: AppColors.maroon, fontSize: 18)
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.deepSaffron.withOpacity(0.6)),
          ),
          Text(
            '₹$amount',
            style: isTotal
                ? AppTextStyles.title.copyWith(color: AppColors.maroon, fontSize: 24)
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon, fontWeight: FontWeight.bold),
          ),
        ],
      );
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
