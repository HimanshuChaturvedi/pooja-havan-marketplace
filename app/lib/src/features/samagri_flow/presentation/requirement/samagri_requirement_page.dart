import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../../data/samagri_repository_provider.dart';

class SamagriRequirementPage extends ConsumerStatefulWidget {
  const SamagriRequirementPage({super.key});

  @override
  ConsumerState<SamagriRequirementPage> createState() => _SamagriRequirementPageState();
}

class _SamagriRequirementPageState extends ConsumerState<SamagriRequirementPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool? _isAvailable;
  bool _checkingAvailability = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    
    _checkVendorAvailability();
  }

  Future<void> _checkVendorAvailability() async {
    final booking = ref.read(bookingSessionProvider).current;
    if (booking?.latitude == null || booking?.longitude == null) {
      setState(() {
        _isAvailable = false;
        _checkingAvailability = false;
      });
      return;
    }

    try {
      final vendorId = await ref.read(samagriRepositoryProvider).findNearestVendor(
        booking!.latitude!, 
        booking.longitude!,
      );
      setState(() {
        _isAvailable = vendorId != null;
        _checkingAvailability = false;
      });
    } catch (e) {
      setState(() {
        _isAvailable = false;
        _checkingAvailability = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Samagri Requirement',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Do you want us to arrange the sacred samagri?',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ✅ YES — ARRANGE SAMAGRI
            _StaggeredFade(
              controller: _animController,
              delay: 300,
              child: _optionCard(
                title: 'Yes, arrange samagri',
                subtitle: _checkingAvailability 
                    ? 'Checking availability near you...' 
                    : (_isAvailable == true 
                        ? 'Select from our curated list of authentic ritual items'
                        : 'Currently unavailable for your ceremony address'),
                icon: Icons.auto_awesome,
                isEnabled: !_checkingAvailability && _isAvailable == true,
                onTap: () {
                  ref.read(bookingSessionProvider.notifier).setSamagriDecision(true);
                  context.push('/samagri-list');
                },
              ),
            ),

            const SizedBox(height: 20),

            // ✅ NO — USER ARRANGES SAMAGRI
            _StaggeredFade(
              controller: _animController,
              delay: 500,
              child: _optionCard(
                title: 'No, I will arrange myself',
                subtitle: 'Proceed to summary with your own ritual materials',
                icon: Icons.person_outline,
                onTap: () {
                  ref.read(bookingSessionProvider.notifier).setSamagriDecision(false);
                  context.push('/home-summary');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: PrimaryCard(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.saffron, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.softGrey,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.saffron, size: 14),
            ],
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
