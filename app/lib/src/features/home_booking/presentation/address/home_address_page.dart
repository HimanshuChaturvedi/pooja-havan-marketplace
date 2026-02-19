import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';
import '../../../booking/application/booking_session.dart';
import 'widgets/address_text_field.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Confirm Home Address',
          style: AppTextStyles.title.copyWith(fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StaggeredFade(
                  controller: _animController,
                  delay: 100,
                  child: Text(
                    'Where should we send the Pandit?',
                    style: AppTextStyles.title.copyWith(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 12),
                _StaggeredFade(
                  controller: _animController,
                  delay: 200,
                  child: Text(
                    'Please provide the exact address for the sacred ceremony.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.deepSaffron),
                  ),
                ),

                const SizedBox(height: 32),

                // 📍 PILOT NOTICE
                _StaggeredFade(
                  controller: _animController,
                  delay: 400,
                  child: DivineGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.deepSaffron, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ghaziabad Pilot',
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'We are currently serving Ghaziabad to ensure the most divine experience for you.',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon.withOpacity(0.7), height: 1.4),
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
                  child: Text(
                    'City',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                _StaggeredFade(
                  controller: _animController,
                  delay: 600,
                  child: DivineGlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        Icon(Icons.location_city, color: AppColors.deepSaffron, size: 20),
                        const SizedBox(width: 12),
                        Text(widget.city, style: AppTextStyles.bodyLarge),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.midnight.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: AppColors.saffron.withOpacity(0.5),
            ),
            onPressed: isAddressValid
                ? () {
                    final address = _addressController.text.trim();
                    if (widget.onAddressSaved != null) {
                      widget.onAddressSaved!(address);
                      return;
                    }
                    BookingSession.current?.address = address;
                    context.push('/pandit-selection');
                  }
                : null,
            child: Text(
              'Continue to Pandit Selection →',
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
            ),
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
