import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:app/src/logs/transaction_log.dart';
import 'package:app/src/core/utils/whatsapp_helper.dart';
import 'package:app/src/core/utils/app_identity.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class BookingSuccessPage extends StatefulWidget {
  const BookingSuccessPage({super.key});

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _iconAnimController;
  late final AnimationController _entryController; // New: one-time entry animations
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

    // 🏎️ Haptic Pulse on Success
    HapticFeedback.heavyImpact();

    // ✅ FIXED REFRESH LOOP: Log transaction once in initState
    _logTransaction();
  }

  Future<void> _logTransaction() async {
    if (_transactionLogged) return;
    
    final booking = BookingSession.current;
    if (booking == null) return;

    final userId = await AppIdentity.userId;
    final displayUserId = _shortUserId(userId);

    BookingSession.transactionId ??= 'BKG-${DateTime.now().millisecondsSinceEpoch}';
    final uniqueLogId = '${BookingSession.transactionId}-${DateTime.now().millisecondsSinceEpoch}';

    TransactionLogService.append(
      TransactionLogEntry(
        id: uniqueLogId,
        type: TransactionType.booking,
        title: booking.ritualName,
        amount: 3000,
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        userLabel: displayUserId,
        bookingId: BookingSession.transactionId,
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
    final booking = BookingSession.current;

    return FutureBuilder<String>(
      future: AppIdentity.userId,
      builder: (context, snapshot) {
        final rawUserId = snapshot.hasData ? snapshot.data! : '0000';
        final displayUserId = _shortUserId(rawUserId);

        return Scaffold(
          body: DivineBackground(
            child: Stack(
              children: [
                // 🔆 DIVINE HALO EFFECT (ROTATING GLOW)
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
                                AppColors.saffron.withOpacity(0.4),
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
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.saffron.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF4CAF50),
                              size: 64,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        _StaggeredFade(
                          controller: _entryController, // Changed to _entryController
                          delay: 0,
                          child: Text(
                            "Booking Confirmed!",
                            style: AppTextStyles.titleLarge.copyWith(fontSize: 30, color: AppColors.maroon),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _StaggeredFade(
                          controller: _entryController, // Changed to _entryController
                          delay: 400,
                          child: Text(
                            "May the Divine blessings be with you.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.maroon.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // 📑 BOOKING DETAILS (3D GLASS CARD)
                        _StaggeredFade(
                          controller: _entryController, // Changed to _entryController
                          delay: 800,
                          child: DivineGlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                _detailItem('Booking ID', BookingSession.transactionId ?? '---'),
                                const Divider(height: 32, color: Colors.black12),
                                _detailItem('Ritual', booking?.ritualName ?? '---'),
                                const Divider(height: 32, color: Colors.black12),
                                _detailItem('Status', 'Confirmation Pending'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 🏠 SHARE & HOME BUTTONS
                        _StaggeredFade(
                          controller: _entryController, // Changed to _entryController
                          delay: 1200,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                                  label: const Text('Share Details with Pandit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.saffron,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: booking == null
                                      ? null
                                      : () {
                                          WhatsAppHelper.openChat(
                                            message: 'Namaste Pandit ji,\n\n'
                                                'A pooja has been booked via Bharat Pooja Setu.\n\n'
                                                'User ID: $displayUserId\n'
                                                'Transaction ID: ${BookingSession.transactionId}\n\n'
                                                'Ritual: ${booking.ritualName}\n'
                                                'Address: ${booking.address ?? 'NA'}\n\n'
                                                'Please confirm availability.\n\n'
                                                '— Bharat Pooja Setu',
                                          );
                                        },
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => context.go('/landing'),
                                child: Text(
                                  'Return to Home',
                                  style: AppTextStyles.button.copyWith(color: AppColors.maroon, fontWeight: FontWeight.bold),
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
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
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
        final totalDuration = 1500; // Match _entryController duration
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.4))),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
