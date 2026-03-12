import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = supabase.auth.currentUser;
    final bool isAnonymous = user == null || user.isAnonymous;

    return Container(
      color: AppColors.warmIvory,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // PROFILE AVATAR
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: isAnonymous ? Colors.grey.shade200 : AppColors.saffron,
                      child: Icon(
                        isAnonymous ? Icons.person_outline_rounded : Icons.person_rounded, 
                        size: 50, 
                        color: isAnonymous ? Colors.grey : Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAnonymous ? 'Sacred Guest' : 'Sacred Devotee',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  Text(
                    isAnonymous ? 'Sign in to sync your bookings' : (user.email ?? 'devotee@poojasetu.com'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.softGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            if (isAnonymous)
              PrimaryButton(
                label: 'Sign In / Register',
                icon: Icons.login_rounded,
                onTap: () => context.push('/login'),
              )
            else ...[
              // SETTINGS OPTIONS
              _ProfileOption(
                icon: Icons.person_outline_rounded,
                label: 'Personal Details',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.location_on_outlined,
                label: 'Saved Addresses',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.help_outline_rounded,
                label: 'Support & Help',
                onTap: () {},
              ),
              const SizedBox(height: 32),
              
              // LOGOUT
              SecondaryButton(
                label: 'Sign Out',
                onTap: () async {
                  await supabase.auth.signOut();
                  // Reset navigation to Home
                  ref.read(mainNavigationProvider.notifier).state = 0;
                },
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
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
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.softGrey, size: 20),
        ],
      ),
    );
  }
}
