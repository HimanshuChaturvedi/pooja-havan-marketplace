import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

final fullNameProvider = StateProvider<String>((ref) => "");
final phoneProvider = StateProvider<String>((ref) => "");
final emailProvider = StateProvider<String>((ref) => "");
final address1Provider = StateProvider<String>((ref) => "");
final address2Provider = StateProvider<String>((ref) => "");
final cityProvider = StateProvider<String>((ref) => "");
final pincodeProvider = StateProvider<String>((ref) => "");
final instructionsProvider = StateProvider<String>((ref) => "");

class BookingStep2Page extends ConsumerStatefulWidget {
  final String panditName;
  const BookingStep2Page({super.key, required this.panditName});

  @override
  ConsumerState<BookingStep2Page> createState() => _BookingStep2PageState();
}

class _BookingStep2PageState extends ConsumerState<BookingStep2Page> with SingleTickerProviderStateMixin {
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
    return AppScaffold(
      title: "Your Details",
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: _SectionCard(
                title: "Personal Information",
                children: [
                  _InputField(
                    label: "Full Name",
                    icon: Icons.person_outline,
                    value: ref.watch(fullNameProvider),
                    onChanged: (v) => ref.read(fullNameProvider.notifier).state = v,
                  ),
                  _InputField(
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    value: ref.watch(phoneProvider),
                    onChanged: (v) => ref.read(phoneProvider.notifier).state = v,
                  ),
                  _InputField(
                    label: "Email (optional)",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    value: ref.watch(emailProvider),
                    onChanged: (v) => ref.read(emailProvider.notifier).state = v,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _StaggeredFade(
              controller: _animController,
              delay: 400,
              child: _SectionCard(
                title: "Address Details",
                children: [
                  _InputField(
                    label: "Address Line 1",
                    icon: Icons.home_outlined,
                    value: ref.watch(address1Provider),
                    onChanged: (v) => ref.read(address1Provider.notifier).state = v,
                  ),
                  _InputField(
                    label: "City",
                    icon: Icons.location_on_outlined,
                    value: ref.watch(cityProvider),
                    onChanged: (v) => ref.read(cityProvider.notifier).state = v,
                  ),
                  _InputField(
                    label: "Pincode",
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    value: ref.watch(pincodeProvider),
                    onChanged: (v) => ref.read(pincodeProvider.notifier).state = v,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _StaggeredFade(
              controller: _animController,
              delay: 700,
              child: _SectionCard(
                title: "Instructions",
                children: [
                  _InputField(
                    label: "Notes for Pandit (optional)",
                    icon: Icons.edit_outlined,
                    maxLines: 3,
                    value: ref.watch(instructionsProvider),
                    onChanged: (v) => ref.read(instructionsProvider.notifier).state = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Continue to Review →',
          onTap: () {
            context.push('/booking/confirm/${widget.panditName}');
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.darkCharcoal, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        // We avoid creating a new controller every build to prevent cursor jumps
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          ),
        ),
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkCharcoal),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.saffron, size: 20),
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
