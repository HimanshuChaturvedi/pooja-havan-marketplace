import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:app/src/logs/transaction_log.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/samagri_flow/state/samagri_session_notifier.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/core/supabase/supabase_client.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';

class BookingSuccessPage extends ConsumerStatefulWidget {
  const BookingSuccessPage({super.key});

  @override
  ConsumerState<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends ConsumerState<BookingSuccessPage> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _iconAnimController;
  late final AnimationController _entryController;
  bool _transactionLogged = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    HapticFeedback.heavyImpact();
    _logTransaction();
  }

  Future<void> _logTransaction() async {
    if (_transactionLogged) return;
    
    final bookingSession = ref.read(bookingSessionProvider);
    final booking = bookingSession.current;
    if (booking == null) return;

    final userId = supabase.auth.currentUser?.id ?? '0000';
    final displayUserId = _shortUserId(userId);

    // Use transaction ID from state or generate a fallback
    final transactionId = bookingSession.transactionId ?? 'BKG-${DateTime.now().millisecondsSinceEpoch}';
    final uniqueLogId = '$transactionId-${DateTime.now().millisecondsSinceEpoch}';

    final int computedTotal = bookingSession.totalAmount.toInt();

    TransactionLogService.append(
      TransactionLogEntry(
        id: uniqueLogId,
        type: TransactionType.booking,
        title: booking.ritualName,
        amount: computedTotal,
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        userLabel: displayUserId,
        bookingId: transactionId,
        bookedForDate: booking.selectedDate,
        bookedForTime: booking.selectedTime,
      ),
    );

    _transactionLogged = true;
  }

  @override
  void dispose() {
    _animController.dispose();
    _iconAnimController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  String _shortUserId(String rawId) {
    final tail = rawId.length >= 4 ? rawId.substring(rawId.length - 4) : rawId;
    return 'SP-USER-$tail';
  }

  @override
  Widget build(BuildContext context) {
    final bookingSession = ref.watch(bookingSessionProvider);
    final booking = bookingSession.current;

    return AppScaffold(
      showAppBar: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 🔆 DIVINE HALO EFFECT
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animController.value * 2 * math.pi,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.saffron.withOpacity(0.3),
                          AppColors.saffron.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // ✨ SUCCESS ICON
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _iconAnimController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.saffron.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.softGreen,
                        size: 64,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _StaggeredFade(
                    controller: _entryController,
                    delay: 0,
                    child: Text(
                      "Booking Confirmed!",
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 32, 
                        color: AppColors.darkCharcoal,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _StaggeredFade(
                    controller: _entryController,
                    delay: 400,
                    child: Text(
                      "May the Divine blessings be with you.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.softGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  _StaggeredFade(
                    controller: _entryController,
                    delay: 800,
                    child: PrimaryCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _detailItem('Booking ID', bookingSession.referenceId ?? bookingSession.bookingId ?? booking?.referenceId ?? bookingSession.transactionId ?? '---'),
                          const Divider(height: 32, color: Colors.black12),
                          _detailItem('Account', supabase.auth.currentUser?.email ?? 'Sacred Guest'),
                          const Divider(height: 32, color: Colors.black12),
                          _detailItem('Ritual', booking?.ritualName ?? '---'),
                          const Divider(height: 32, color: Colors.black12),
                          _detailItem('Status', 'Awaiting Pandit Confirmation'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🏠 SHARE & HOME BUTTONS
                  _StaggeredFade(
                    controller: _entryController,
                    delay: 1200,
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            ref.read(bookingSessionProvider.notifier).reset();
                            ref.read(samagriSessionProvider.notifier).clear();
                            ref.read(samagriCartProvider.notifier).clearCart();
                            context.go('/landing');
                          },
                          child: Text(
                            'Return to Home',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.softGrey, 
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.softGrey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
        const totalDuration = 1500;
        final start = (delay / totalDuration).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / totalDuration).clamp(0, 1.0).toDouble();
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
