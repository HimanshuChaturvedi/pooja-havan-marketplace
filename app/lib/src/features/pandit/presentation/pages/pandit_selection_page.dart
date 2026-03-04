import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class PanditSelectionPage extends StatefulWidget {
  final String templeName;

  const PanditSelectionPage({
    super.key,
    required this.templeName,
  });

  @override
  State<PanditSelectionPage> createState() => _PanditSelectionPageState();
}

class _PanditSelectionPageState extends State<PanditSelectionPage> with SingleTickerProviderStateMixin {
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
      title: 'Select Pandit',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                'Choose a Divine Guide',
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
                widget.templeName.isNotEmpty
                    ? 'Available pandits for ${widget.templeName}'
                    : 'Available authentic pandits for your pooja',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.softGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 32),

            _PanditList(animController: _animController),
          ],
        ),
      ),
    );
  }
}

class _PanditList extends StatelessWidget {
  final AnimationController animController;
  const _PanditList({required this.animController});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pandits = [
      {'name': 'Pandit Sharma', 'exp': '12+ years experience'},
      {'name': 'Pandit Mishra', 'exp': '8+ years experience'},
      {'name': 'Pandit Verma', 'exp': '15+ years experience'},
    ];

    return Column(
      children: List.generate(pandits.length, (index) {
        final pandit = pandits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _StaggeredFade(
            controller: animController,
            delay: 400 + (index * 150),
            child: _PanditCard(
              name: pandit['name']!,
              experience: pandit['exp']!,
              onTap: () {
                context.push('/pandit-details', extra: pandit['name']);
              },
            ),
          ),
        );
      }),
    );
  }
}

class _PanditCard extends StatelessWidget {
  final String name;
  final String experience;
  final VoidCallback onTap;

  const _PanditCard({
    required this.name,
    required this.experience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.saffron, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    experience,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.saffron,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffron),
          ],
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
