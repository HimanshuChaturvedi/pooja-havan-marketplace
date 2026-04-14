import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import '../../booking/data/booking_providers.dart';
import '../../samagri_flow/data/samagri_repository_provider.dart';
import '../../../core/payment/razorpay_provider.dart';
import '../../../core/payment/razorpay_service.dart';
import '../data/payment_provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../samagri_vendor/data/vendor_repository.dart';
import '../../booking/domain/booking_draft.dart';

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

    // Initialize Razorpay listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final razorpay = ref.read(razorpayServiceProvider);
      razorpay.onSuccess = _onPaymentSuccess;
      razorpay.onFailure = _onPaymentError;
    });
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    final bookingSession = ref.read(bookingSessionProvider);
    final booking = bookingSession.current;
    final samagri = ref.read(samagriSessionProvider);

    try {
      // 1. Create the booking/order in Supabase
      String? bookingId;
      String? referenceId;
      if (booking != null) {
        final items = samagri.items.isNotEmpty ? samagri.items : null;
        final result = await ref.read(bookingRepositoryProvider).createBooking(
          booking,
          samagriItems: items,
        );
        bookingId = result['bookingId'];
        referenceId = result['referenceId'];
      } else if (samagri.sessionId != null) {
        // Handle standalone samagri order
        final orderId = await ref.read(samagriRepositoryProvider).createOrder(
          items: samagri.items,
          totalAmount: samagri.finalTotal.toDouble(),
          deliveryAddress: samagri.addressText,
          latitude: samagri.latitude,
          longitude: samagri.longitude,
          deliveryFee: samagri.deliveryFee.toDouble(),
          platformFee: samagri.platformFee.toDouble(),
        );
        // Link to payment record
        bookingId = orderId; 
      }

      // 2. Record payment in Supabase
      await ref.read(paymentRepositoryProvider).recordPayment(
        razorpayPaymentId: response.paymentId!,
        amount: bookingSession.totalAmount,
        bookingId: booking != null ? bookingId : null,
        samagriOrderId: booking == null ? bookingId : null,
        status: 'captured',
      );

      // 3. Update Status to PAID
      if (bookingId != null) {
        if (booking != null) {
           await ref.read(bookingRepositoryProvider).updateBookingStatus(bookingId, BookingStatusDetailed.paid);
        } else {
           await ref.read(samagriVendorRepositoryProvider).updateOrderStatus(bookingId, 'paid');
        }
      }

      // 4. Update UI State & Navigate
      if (booking != null) {
        ref.read(bookingSessionProvider.notifier).updateStatus(BookingStatus.confirmed);
        ref.read(bookingSessionProvider.notifier).setTransactionId(response.paymentId!);
        if (bookingId != null) ref.read(bookingSessionProvider.notifier).setBookingId(bookingId);
        if (referenceId != null) ref.read(bookingSessionProvider.notifier).setReferenceId(referenceId);
        if (mounted) {
          ref.invalidate(bookingsProvider);
          context.go('/booking-success');
        }
      } else {
        ref.read(samagriSessionProvider.notifier).markPaid();
        ref.read(samagriCartProvider.notifier).clearCart();
        if (mounted) {
          ref.invalidate(bookingsProvider);
          context.go('/samagri-success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finalizing booking: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool canPayNow(BookingSessionState bookingSession, SamagriSessionState samagri) {
    if (bookingSession.current != null) {
      // Allow if status is either draft or paymentPending (robustness fix)
      return bookingSession.status != BookingStatus.confirmed;
    }
    if (samagri.sessionId == null) return false;
    if (samagri.addressText == null || samagri.addressText!.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _handlePayment() async {
    if (_isLoading) return;
    
    // 🔒 Security Guard
    final currentUser = supabase.auth.currentUser;
    final bool isGuest = currentUser == null || currentUser.isAnonymous || (currentUser.email?.isEmpty ?? true);
    
    if (isGuest) {
      context.push('/login?redirectTo=/payment');
      return;
    }

    debugPrint('PaymentPage: Starting payment flow...');
    setState(() => _isLoading = true);

    final bookingSession = ref.read(bookingSessionProvider);
    final samagriSession = ref.read(samagriSessionProvider);
    final user = currentUser!;

    final double amountToPay = bookingSession.current != null 
        ? bookingSession.totalAmount 
        : samagriSession.finalTotal.toDouble();

    debugPrint('PaymentPage: amount=$amountToPay, sessionId=${bookingSession.current?.referenceId ?? samagriSession.sessionId}');

    final String orderDescription = bookingSession.current != null 
        ? 'Ritual Booking: ${bookingSession.current?.ritualName}'
        : 'Samagri Order: ${samagriSession.sessionId}';

    try {
      debugPrint('PaymentPage: Opening Razorpay SDK...');
      ref.read(razorpayServiceProvider).openCheckout(
        amount: amountToPay,
        contact: user.phone ?? '', 
        email: user.email ?? '',
        description: orderDescription,
        notes: {
          'session_id': bookingSession.current?.referenceId ?? samagriSession.sessionId ?? 'N/A',
          'user_id': user.id,
          'type': bookingSession.current != null ? 'ritual' : 'samagri',
        },
      );
    } catch (e) {
      debugPrint('PaymentPage ERROR: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open payment gateway: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ═══════════════════════════════════════════════
    // 🔒 FULL-SCREEN AUTH WALL (Build v3.1)
    // ═══════════════════════════════════════════════
    // 🔒 AUTH WALL v4.0: Uses isAnonymous (same as Profile page)
    final currentUser = supabase.auth.currentUser;
    final bool isGuest = currentUser == null || currentUser.isAnonymous || (currentUser.email?.isEmpty ?? true);
    
    debugPrint('═══ PaymentPage BUILD v4.0 ═══');
    debugPrint('isGuest: $isGuest | isAnonymous: ${currentUser?.isAnonymous} | email: "${currentUser?.email}"');
    debugPrint('══════════════════════════════');

    if (isGuest) {
      return AppScaffold(
        title: 'Identity Required',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: AppColors.saffron, size: 64),
                ),
                const SizedBox(height: 32),
                Text(
                  'Sign In Required',
                  style: AppTextStyles.title.copyWith(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.darkCharcoal),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please sign in with your email to confirm this sacred booking.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Build v3.1', style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey.withOpacity(0.4), fontSize: 10)),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Sign In to Continue',
                  icon: Icons.login_rounded,
                  onTap: () => context.push('/login?redirectTo=/payment'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Go Back', style: AppTextStyles.button.copyWith(color: AppColors.softGrey, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── LOGGED IN: Show normal payment ──
    final bookingSession = ref.watch(bookingSessionProvider);
    final samagriSession = ref.watch(samagriSessionProvider);
    
    final booking = bookingSession.current;
    final bool isDirectSamagri = booking == null && samagriSession.sessionId != null;
    
    final double amount = booking != null 
        ? bookingSession.totalAmount 
        : samagriSession.finalTotal.toDouble();
        
    final bool payEnabled = canPayNow(bookingSession, samagriSession);
    
    debugPrint('PaymentPage: amount=$amount, payEnabled=$payEnabled');
    if (!payEnabled) {
      debugPrint('PaymentPage: Disabled because - booking: ${booking != null}, samagriSession: ${samagriSession.sessionId != null}, address: ${samagriSession.addressText}');
    }

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
              child: Text('Final Payment', style: AppTextStyles.title.copyWith(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.darkCharcoal)),
            ),
            const SizedBox(height: 8),
            _StaggeredFade(
              controller: _animController,
              delay: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confirming as ${currentUser.email}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGreen, fontWeight: FontWeight.w700)),
                  if (booking != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                         const Icon(Icons.auto_awesome_rounded, color: AppColors.saffron, size: 20),
                         const SizedBox(width: 8),
                         Text(booking.ritualName ?? 'Ritual Order', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            _StaggeredFade(
              controller: _animController,
              delay: 300,
              child: PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (isDirectSamagri) ...[
                      _priceItem('Samagri Charges', '₹${samagriSession.totalAmount}'),
                      _priceItem('Vendor Service Charge', '₹${samagriSession.deliveryFee}'),
                      _priceItem('Platform & Service Fee', '₹${samagriSession.platformFee}'),
                      const Divider(height: 32, color: Colors.black12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payable', style: AppTextStyles.title.copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('₹$amount', style: AppTextStyles.title.copyWith(color: AppColors.saffron, fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
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
                            ? 'Dakshina & Service Fee secured via Razorpay. Pandit will be assigned soon.'
                            : 'Fulfillment & Delivery by Vendor. Payment secured via Razorpay.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal.withOpacity(0.8), fontWeight: FontWeight.bold),
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
        
          Widget _priceItem(String label, String value) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey, fontWeight: FontWeight.w600)),
                   Text(value, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w800)),
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
