import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../../booking/data/booking_providers.dart';
import '../../samagri_flow/data/samagri_repository_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _isLoading = false;

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

  Future<void> _handlePayment() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final booking = BookingSession.current;
    final samagri = SamagriSession.current;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (booking != null) {
      try {
        final items = samagri?.items;
        await ref.read(bookingRepositoryProvider).createBooking(
          booking,
          samagriItems: items,
        );
        BookingSession.status = BookingStatus.confirmed;
        if (mounted) {
          ref.invalidate(bookingsProvider);
          context.go('/booking-success');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    if (samagri != null) {
      try {
        await ref.read(samagriRepositoryProvider).createOrder(
          items: samagri.items,
          totalAmount: samagri.totalAmount.toDouble(),
          deliveryAddress: samagri.addressText,
        );
        SamagriSession.markPaid();
        ref.read(samagriCartProvider.notifier).clearCart();
        if (mounted) {
          ref.invalidate(bookingsProvider);
          context.go('/samagri-success');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingSession.current;
    final double amount = BookingSession.totalAmount;
    final bool payEnabled = canPayNow();

    return AppScaffold(
      title: 'Payment',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Final Payment',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _StaggeredFade(
              controller: _animController,
              delay: 200,
              child: Text(
                'Review your amount and complete the sacred booking.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
            ),

            const SizedBox(height: 40),

            _StaggeredFade(
              controller: _animController,
              delay: 400,
              child: PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '₹$amount',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.saffron,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _StaggeredFade(
              controller: _animController,
              delay: 600,
              child: PrimaryCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.saffron.withOpacity(0.05),
                showShadow: false,
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.saffron, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        booking != null
                            ? 'Pay directly to the Pandit after the sacred ritual.'
                            : 'Pay directly to the Vendor upon delivery of samagri.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.darkCharcoal.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          label: 'Confirm Booking ₹$amount',
          onTap: payEnabled ? _handlePayment : null,
          loading: _isLoading,
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
