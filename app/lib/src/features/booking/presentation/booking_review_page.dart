import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/features/booking/presentation/booking_step1_page.dart';
import 'package:app/src/core/widgets/design_system.dart';

class BookingReviewPage extends ConsumerStatefulWidget {
  final String panditName;
  const BookingReviewPage({super.key, required this.panditName});

  @override
  ConsumerState<BookingReviewPage> createState() => _BookingReviewPageState();
}

class _BookingReviewPageState extends ConsumerState<BookingReviewPage> with SingleTickerProviderStateMixin {
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
    final booking = BookingSession.current;
    if (booking == null) {
      return const AppScaffold(
        title: "Error",
        body: Center(
          child: Text('No booking found'),
        ),
      );
    }

    final date = ref.watch(selectedDateProvider);
    final time = ref.watch(selectedTimeProvider);

    return AppScaffold(
      title: 'Review & Confirm',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                "Finalizing your ritual details",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
            ),
            const SizedBox(height: 24),

            _StaggeredFade(
              controller: _animController,
              delay: 300,
              child: PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _ReviewRow(
                      icon: Icons.person_pin_outlined,
                      label: 'Pandit',
                      value: widget.panditName,
                    ),
                    const Divider(height: 32, color: Colors.black12),
                    _ReviewRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: date != null ? _formatDate(date) : '-',
                    ),
                    const Divider(height: 32, color: Colors.black12),
                    _ReviewRow(
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: time ?? '-',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _StaggeredFade(
              controller: _animController,
              delay: 500,
              child: PrimaryCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.saffron.withOpacity(0.05),
                showShadow: false,
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined, color: AppColors.saffron, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your booking is secure and confirmed manually by our team.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.darkCharcoal.withOpacity(0.8),
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
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ReviewRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.softGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
