import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../data/ritual_repository_provider.dart';

class PoojaDetailsPage extends ConsumerStatefulWidget {
  final String poojaName;
  final String poojaSlug; // This is the ID in the route

  const PoojaDetailsPage({
    super.key,
    required this.poojaName,
    required this.poojaSlug,
  });

  @override
  ConsumerState<PoojaDetailsPage> createState() => _PoojaDetailsPageState();
}

class _PoojaDetailsPageState extends ConsumerState<PoojaDetailsPage> with SingleTickerProviderStateMixin {
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
    final ritualAsync = ref.watch(ritualByIdProvider(widget.poojaSlug));

    return AppScaffold(
      title: widget.poojaName,
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: AppColors.darkCharcoal),
          onPressed: () => context.go('/landing'),
        )
      ],
      body: ritualAsync.when(
        data: (ritual) {
          if (ritual == null) {
            return const Center(child: Text('Pooja not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StaggeredFade(
                  controller: _animController,
                  delay: 100,
                  child: PrimaryCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pooja Overview',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 18,
                            color: AppColors.darkCharcoal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ritual.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.6,
                            color: AppColors.darkCharcoal.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _StaggeredFade(
                  controller: _animController,
                  delay: 300,
                  child: PrimaryCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _infoRow(
                          icon: Icons.timer_outlined,
                          title: 'Duration',
                          value: '90 – 120 minutes', // Can be dynamic if added to rituals table
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.black12),
                        const SizedBox(height: 12),
                        _infoRow(
                          icon: Icons.inventory_2_outlined,
                          title: 'Samagri',
                          value: 'Pandit will provide list', 
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Colors.black12),
                        const SizedBox(height: 12),
                        _infoRow(
                          icon: Icons.payments_outlined,
                          title: 'Dakshina',
                          value: '₹1,500 – ₹2,500', 
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _StaggeredFade(
                  controller: _animController,
                  delay: 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '*Final dakshina may vary based on city & pandit availability',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.softGrey,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Select Location →',
          onTap: () {
            final booking = ref.read(bookingSessionProvider).current;
            if (booking != null) {
              if (booking.bookingType == BookingType.temple) {
                if (booking.templeName == null) {
                  context.push('/temples/${Uri.encodeComponent(booking.city)}');
                } else {
                  context.push('/home-date-time');
                }
              } else {
                context.push('/home-address');
              }
              return;
            }
            context.push(
              '/location/${widget.poojaSlug}/${Uri.encodeComponent(widget.poojaName)}',
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.softGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.darkCharcoal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
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
