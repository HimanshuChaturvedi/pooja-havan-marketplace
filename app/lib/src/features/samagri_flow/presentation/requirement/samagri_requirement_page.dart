import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class SamagriRequirementPage extends StatefulWidget {
  const SamagriRequirementPage({super.key});

  @override
  State<SamagriRequirementPage> createState() => _SamagriRequirementPageState();
}

class _SamagriRequirementPageState extends State<SamagriRequirementPage> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Samagri Requirement',
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Text(
                  'Do you want us to arrange the sacred samagri?',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 22,
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
                  subtitle: 'Select from our curated list of authentic ritual items',
                  icon: Icons.auto_awesome,
                  onTap: () {
                    BookingSession.samagriDecisionTaken = true;
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
                    BookingSession.samagriDecisionTaken = false;
                    context.push('/home-summary');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return DivineGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.saffron.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepSaffron, size: 28),
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
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.deepSaffron, // Remove opacity for maximum readability
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.saffron, size: 14),
        ],
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
