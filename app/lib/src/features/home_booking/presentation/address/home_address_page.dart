import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/features/home_booking/presentation/address/widgets/address_text_field.dart';
import 'package:app/src/core/widgets/design_system.dart';

class HomeAddressPage extends StatefulWidget {
  final String city;
  final void Function(String address)? onAddressSaved;

  const HomeAddressPage({
    super.key,
    required this.city,
    this.onAddressSaved,
  });

  @override
  State<HomeAddressPage> createState() => _HomeAddressPageState();
}

class _HomeAddressPageState extends State<HomeAddressPage> with SingleTickerProviderStateMixin {
  final TextEditingController _addressController = TextEditingController();
  late final AnimationController _animController;

  bool get isAddressValid => _addressController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() {
      setState(() {});
    });
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Confirm Business Address',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Where should we send the Pandit?',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _StaggeredFade(
              controller: _animController,
              delay: 200,
              child: Text(
                'Please provide the exact address for the sacred ceremony.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
            ),

            const SizedBox(height: 32),

            // 📍 PILOT NOTICE
            _StaggeredFade(
              controller: _animController,
              delay: 400,
              child: PrimaryCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.saffron.withOpacity(0.05),
                showShadow: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.saffron, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ghaziabad Pilot',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.darkCharcoal, 
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'We are currently serving Ghaziabad to ensure the most divine experience for you.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.softGrey, 
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            _StaggeredFade(
              controller: _animController,
              delay: 500,
              child: const SectionHeader(title: 'City'),
            ),
            const SizedBox(height: 12),
            _StaggeredFade(
              controller: _animController,
              delay: 600,
              child: PrimaryCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, color: AppColors.saffron, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.city, 
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            _StaggeredFade(
              controller: _animController,
              delay: 750,
              child: AddressTextField(
                controller: _addressController,
                hintText: 'House No, Area, Society, Landmark...',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Continue to Pandit Selection →',
          onTap: () {
            final address = _addressController.text.trim();
            if (widget.onAddressSaved != null) {
              widget.onAddressSaved!(address);
              return;
            }
            BookingSession.current?.address = address;
            context.push('/pandit-selection');
          },
          loading: false,
          color: isAddressValid ? null : AppColors.softGrey.withOpacity(0.3),
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
