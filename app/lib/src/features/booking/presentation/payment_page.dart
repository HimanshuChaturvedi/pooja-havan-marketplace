import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../booking/application/booking_session.dart';
import '../../samagri_flow/application/samagri_session.dart';
import '../../samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> with SingleTickerProviderStateMixin {
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

  bool canPayNow() {
    if (BookingSession.current != null) {
      return BookingSession.status == BookingStatus.paymentPending;
    }
    final samagri = SamagriSession.current;
    if (samagri == null) return false;
    if (samagri.addressText == null || samagri.addressText!.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingSession.current;
    final samagri = SamagriSession.current;
    final amount = samagri != null ? samagri.totalAmount : 3000;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Payment',
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
        leading: BackButton(
          onPressed: () {
            if (booking != null) {
              context.go('/home-address');
              return;
            }
            context.go('/samagri-summary');
          },
        ),
      ),
      body: DivineBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Text(
                  'Final Payment',
                  style: AppTextStyles.title.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(height: 8),
              _StaggeredFade(
                controller: _animController,
                delay: 200,
                child: Text(
                  'Review your amount and complete the sacred booking.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: 40),

              _StaggeredFade(
                controller: _animController,
                delay: 400,
                child: DivineGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                      ),
                      Text(
                        '₹$amount',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.deepSaffron,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _StaggeredFade(
                controller: _animController,
                delay: 600,
                child: DivineGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.deepSaffron, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          booking != null
                              ? 'Manual payment confirmed. Pay directly to the Pandit after the sacred ritual.'
                              : 'Manual payment confirmed. Pay directly to the Vendor upon delivery of samagri.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.maroon,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: AppColors.saffron.withOpacity(0.5),
            ),
            onPressed: canPayNow()
                ? () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (booking != null) {
                      BookingSession.status = BookingStatus.confirmed;
                      context.go('/booking-success');
                      return;
                    }
                    if (samagri != null) {
                      SamagriSession.markPaid();
                      ref.read(samagriCartProvider.notifier).clearCart();
                      context.go('/samagri-success');
                    }
                  }
                : null,
            child: Text(
              'Confirm Booking ₹$amount →',
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
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

class _AmountCard extends StatelessWidget {
  final String label;
  final int amount;
  const _AmountCard({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.saffron.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 18)),
          Text(
            '₹$amount',
            style: AppTextStyles.title.copyWith(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
