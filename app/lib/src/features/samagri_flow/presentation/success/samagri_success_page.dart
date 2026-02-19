import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/logs/transaction_log.dart';
import 'package:app/src/core/utils/whatsapp_helper.dart';
import 'package:app/src/core/utils/app_identity.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class SamagriSuccessPage extends StatefulWidget {
  const SamagriSuccessPage({super.key});

  @override
  State<SamagriSuccessPage> createState() => _SamagriSuccessPageState();
}

class _SamagriSuccessPageState extends State<SamagriSuccessPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _logged = false;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _logTransaction();
  }

  Future<void> _logTransaction() async {
    if (_logged) return;
    final samagri = SamagriSession.current;
    if (samagri == null) return;

    final rawUserId = await AppIdentity.userId;
    final displayUserId = _shortUserId(rawUserId);

    TransactionLogService.append(
      TransactionLogEntry(
        id: samagri.sessionId,
        type: TransactionType.samagri,
        title: 'Samagri Order Request',
        amount: samagri.totalAmount,
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        userLabel: displayUserId,
        samagriSessionId: samagri.sessionId,
      ),
    );
    _logged = true;
  }
  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _shortUserId(String rawId) {
    final tail = rawId.length >= 4 ? rawId.substring(rawId.length - 4) : rawId;
    return 'SP-USER-$tail';
  }

  @override
  Widget build(BuildContext context) {
    final samagri = SamagriSession.current;
    final booking = BookingSession.current;
    final isBookingFlow = booking != null;

    return FutureBuilder<String>(
      future: AppIdentity.userId,
      builder: (context, snapshot) {
        final rawUserId = snapshot.hasData ? snapshot.data! : '0000';
        final displayUserId = _shortUserId(rawUserId);

        final String city = isBookingFlow ? booking!.city : 'Ghaziabad';
        final String deliveryAddress = isBookingFlow
            ? '${booking!.address ?? "NA"}, ${booking.city}'
            : (samagri?.addressText ?? 'Address not provided');

        return Scaffold(
          body: DivineBackground( // Changed from Container to DivineBackground
            child: Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Container(
                        width: 300 * _animController.value,
                        height: 300 * _animController.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.saffron.withOpacity(0.15 * (1 - _animController.value)), // Changed color
                              blurRadius: 100,
                              spreadRadius: 50,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // Changed from gradient to solid color
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.saffron.withOpacity(0.4), // Changed color
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.shopping_basket, color: AppColors.maroon, size: 60), // Changed icon color
                          ),
                        ),
                        const SizedBox(height: 48),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 800,
                          child: Text(
                            "Order Submitted!",
                            style: AppTextStyles.titleLarge.copyWith(color: AppColors.maroon, fontSize: 32), // Changed text color
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 1000,
                          child: Text(
                            "Your samagri request has been sent to the vendor. They will contact you shortly for delivery.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon.withOpacity(0.7), height: 1.5, fontWeight: FontWeight.w500), // Changed text color and added fontWeight
                          ),
                        ),
                        const SizedBox(height: 48),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 1200,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1), // Changed opacity
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.glassBorder), // Changed border color
                            ),
                            child: Column(
                              children: [
                                _InfoRow(label: 'Order ID', value: samagri?.sessionId.substring(0, 10).toUpperCase() ?? '---'),
                                const SizedBox(height: 12),
                                _InfoRow(label: 'Delivery City', value: city),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 1400,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Send details to Vendor'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.saffron,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                WhatsAppHelper.openChat(
                                  message: 'Namaste,\n\n'
                                      'A samagri order has been placed via Bharat Pooja Setu.\n\n'
                                      'User ID: $displayUserId\n'
                                      'Transaction ID: ${samagri?.sessionId}\n\n'
                                      '📍 City: $city\n\n'
                                      'Items:\n'
                                      '${samagri?.items.map((e) => '- ${e.name} × ${e.quantity}').join('\n')}\n\n'
                                      'Delivery Address:\n'
                                      '$deliveryAddress\n\n'
                                      'Please confirm availability.\n\n'
                                      '— Bharat Pooja Setu',
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StaggeredFade(
                          controller: _animController,
                          delay: 1600,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.maroon.withOpacity(0.5)), // Changed border color
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              minimumSize: const Size(double.infinity, 54),
                            ),
                            onPressed: () {
                              if (isBookingFlow) {
                                context.go('/home-summary');
                              } else {
                                SamagriSession.clear();
                                context.go('/landing');
                              }
                            },
                            child: Text(
                              'Continue',
                              style: AppTextStyles.button.copyWith(color: AppColors.maroon), // Changed text color
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
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon.withOpacity(0.6))), // Changed text color
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon, fontWeight: FontWeight.bold)), // Changed text color
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
        final start = (delay / 2000).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 2000).clamp(0, 1.0).toDouble();
        
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
