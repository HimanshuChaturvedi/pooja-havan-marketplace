import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import 'package:app/src/logs/transaction_log.dart';
import 'package:app/src/core/utils/whatsapp_helper.dart';
import 'package:app/src/core/utils/app_identity.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/features/samagri_flow/state/samagri_cart_notifier.dart';
import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';

class SamagriSuccessPage extends ConsumerStatefulWidget {
  const SamagriSuccessPage({super.key});

  @override
  ConsumerState<SamagriSuccessPage> createState() => _SamagriSuccessPageState();
}

class _SamagriSuccessPageState extends ConsumerState<SamagriSuccessPage> with SingleTickerProviderStateMixin {
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
                    return Container(
                      width: 300 * _animController.value,
                      height: 300 * _animController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.saffron.withOpacity(0.2 * (1 - _animController.value)),
                            AppColors.saffron.withOpacity(0.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      ScaleTransition(
                        scale: CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.saffron.withOpacity(0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.shopping_basket, color: AppColors.saffron, size: 60),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // ... [rest of the column content remains staggered]
                      _StaggeredFade(
                        controller: _animController,
                        delay: 800,
                        child: Text(
                          "Order Successful 🙏",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.darkCharcoal, 
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 1000,
                        child: Text(
                          "Your samagri order has been placed successfully. Our vendor will contact you for delivery.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.softGrey, 
                            height: 1.5, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 1200,
                        child: PrimaryCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'Order ID', 
                                value: samagri?.isPartOfBooking == true 
                                    ? (booking?.referenceId ?? 'PHM-PENDING')
                                    : 'SMG-${samagri?.sessionId.substring(samagri.sessionId.length - 6).toUpperCase() ?? "XXXX"}',
                              ),
                              const Divider(height: 24, color: Colors.black12),
                               _InfoRow(
                                label: 'Total Amount', 
                                value: '₹${samagri?.finalTotal ?? 0}',
                                isHighlight: true,
                              ),
                              const Divider(height: 24, color: Colors.black12),
                              _InfoRow(label: 'Delivery City', value: city),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 1400,
                        child: PrimaryButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'Send to WhatsApp',
                          onTap: () {
                            final String orderId = samagri?.isPartOfBooking == true 
                                ? (booking?.referenceId ?? 'PHM-PENDING')
                                : 'SMG-${samagri?.sessionId.substring(samagri.sessionId.length - 6).toUpperCase() ?? "XXXX"}';
                            final String total = '₹${samagri?.finalTotal ?? 0}';
                            
                            WhatsAppHelper.openChat(
                              message: 'Namaste 🙏\n\n'
                                  'Your Bharat Pooja Setu samagri order has been confirmed.\n\n'
                                  'Order ID: $orderId\n'
                                  'Total Amount: $total\n\n'
                                  '📍 Delivery to: $city\n'
                                  'Address: $deliveryAddress\n\n'
                                  'Items:\n'
                                  '${samagri?.items.map((e) => '- ${e.name} × ${e.quantity}').join('\n')}\n\n'
                                  '— Bharat Pooja Setu',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StaggeredFade(
                        controller: _animController,
                        delay: 1600,
                        child: TextButton(
                          onPressed: () {
                            if (isBookingFlow) {
                              context.go('/home-summary');
                            } else {
                              BookingSession.reset();
                              SamagriSession.clear();
                              ref.read(samagriCartProvider.notifier).clearCart();
                              // 🚀 RESET NAVIGATION: Go to Home Tab (index 0)
                              ref.read(mainNavigationProvider.notifier).state = 0;
                              context.go('/');
                            }
                          },
                          child: Text(
                            'Go to Home',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.softGrey,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  const _InfoRow({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isHighlight ? AppColors.saffron : AppColors.darkCharcoal, 
              fontWeight: FontWeight.w900,
              fontSize: isHighlight ? 20 : 16,
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
