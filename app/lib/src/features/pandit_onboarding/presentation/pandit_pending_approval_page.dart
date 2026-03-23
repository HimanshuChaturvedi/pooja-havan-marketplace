import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/design_system.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

class PanditPendingApprovalPage extends StatelessWidget {
  const PanditPendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Hero Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 60,
                  color: AppColors.saffron,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Profile Under Review',
                style: AppTextStyles.title.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Thank you for joining Bharat Pooja Setu.\n\n'
                'To ensure the safety of our devotees, our Admin Team is currently verifying your Aadhar and background details.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Timeline
              PrimaryCard(
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'What happens next?',
                            style: AppTextStyles.button.copyWith(color: AppColors.darkCharcoal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Verification typically takes 24-48 hours. Once your identity is verified, you will be granted access to the Pandit Dashboard to start receiving bookings.',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Action Buttons
              PrimaryButton(
                label: 'Return to Home',
                onTap: () {
                  context.go('/landing'); // Use /landing to bypass the pandit guard for customers
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
