import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/services/domain/explore_service.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';

class ExploreServiceDetailPage extends ConsumerWidget {
  final ExploreService service;

  const ExploreServiceDetailPage({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: service.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: AppColors.darkCharcoal),
          onPressed: () {
            ref.read(mainNavigationProvider.notifier).state = 0;
            context.go('/home');
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.darkCharcoal),
          onPressed: () {
            ref.read(mainNavigationProvider.notifier).state = 3;
            context.go('/home');
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkCharcoal.withOpacity(0.8),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle('What this service involves'),
            ...service.requirements.map(_bullet),

            const SizedBox(height: 32),

            _sectionTitle('Additional arrangements may be required'),
            ...service.additionalArrangements.map(_bullet),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Request this service (Coming Soon)',
          onTap: () {}, // 🔒 PHASE-1: Disabled but styled consistently
          loading: false,
          color: AppColors.softGrey.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: AppTextStyles.title.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.darkCharcoal,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: AppColors.saffron, size: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
