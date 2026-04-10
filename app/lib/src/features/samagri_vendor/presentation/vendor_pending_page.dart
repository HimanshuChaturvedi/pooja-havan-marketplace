import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../../../core/supabase/supabase_client.dart';

import 'package:go_router/go_router.dart';

class VendorPendingPage extends ConsumerWidget {
  const VendorPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_outlined, color: AppColors.saffron, size: 64),
            ),
            const SizedBox(height: 32),
            Text(
              'Verification in Progress',
              style: AppTextStyles.title.copyWith(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.darkCharcoal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Dhanyawad! Your shop details have been received. Our admin team will verify your location and profile within 24-48 hours.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () async {
                await supabase.auth.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: const Text('Logout & Exit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
}
}
