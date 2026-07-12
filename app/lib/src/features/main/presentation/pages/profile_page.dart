import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/features/main/presentation/state/main_navigation_provider.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';
import 'package:app/src/features/pandit_onboarding/data/pandit_repository_provider.dart';
import 'package:app/src/features/samagri_vendor/data/vendor_repository.dart';
import 'package:app/src/features/landing/state/recommendations_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(supabaseUserProvider);

    return userAsync.when(
      data: (user) {
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
                onTap: () => context.push('/personal-details'),
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.location_on_outlined,
                label: 'Saved Addresses',
                onTap: () => context.push('/saved-addresses'),
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () => context.push('/notifications'),
              ),
              const SizedBox(height: 16),
              _ProfileOption(
                icon: Icons.help_outline_rounded,
                label: 'Support & Help',
                onTap: () => context.push('/support-help'),
              ),
              const SizedBox(height: 16),

              // Pandit Status Logic
              ref.watch(panditProfileFutureProvider(user.id)).when(
                data: (profile) {
                  if (profile == null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.saffron.withOpacity(0.5), width: 1.5),
                        ),
                        child: _ProfileOption(
                          icon: Icons.handshake_rounded,
                          label: 'Register as a Pandit',
                          onTap: () => context.push('/pandit-onboarding'),
                        ),
                      ),
                    );
                  }
                  
                  if (profile.verificationStatus.name.toUpperCase() == 'PENDING') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ProfileOption(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Pandit Approval Pending',
                        onTap: () => context.push('/pandit-pending'),
                      ),
                    );
                  }
                  
                  if (profile.verificationStatus.name.toUpperCase() == 'VERIFIED') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ProfileOption(
                        icon: Icons.dashboard_outlined,
                        label: 'Pandit Dashboard',
                        onTap: () => context.push('/pandit-dashboard'),
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: AppShimmer(width: double.infinity, height: 60),
                ),
                error: (e, __) => const SizedBox.shrink(),
              ),

              // Vendor Status Logic 
              ref.watch(vendorProfileFutureProvider).when(
                data: (profile) {
                  if (profile == null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.saffron.withOpacity(0.5), width: 1.5),
                        ),
                        child: _ProfileOption(
                          icon: Icons.store_rounded,
                          label: 'Sell Samagri (Register Shop)',
                          onTap: () => context.push('/vendor-registration'),
                        ),
                      ),
                    );
                  }
                  
                  final String status = (profile['verification_status'] as String).toUpperCase();
                  
                  if (status == 'PENDING') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ProfileOption(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Shop Approval Pending',
                        onTap: () => context.push('/vendor-pending'),
                      ),
                    );
                  }
                  
                  if (status == 'VERIFIED') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ProfileOption(
                        icon: Icons.dashboard_customize_outlined,
                        label: 'Vendor Dashboard',
                        onTap: () => context.push('/vendor-dashboard'),
                      ),
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: AppShimmer(width: double.infinity, height: 60),
                ),
                error: (e, __) => const SizedBox.shrink(),
              ),

              if (ref.watch(isAdminProvider)) ...[
                _ProfileOption(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin Verification',
                  onTap: () => context.push('/admin-portal'),
                ),
                const SizedBox(height: 16),
              ],
              
              const SizedBox(height: 16), // Adjusted from 32 to keep spacing consistent
              
              // LOGOUT
              SecondaryButton(
                label: 'Sign Out',
                onTap: () async {
                  await supabase.auth.signOut();
                  // 🔄 Invalidate profile providers so they fetch fresh data on next login
                  ref.invalidate(panditProfileFutureProvider);
                  ref.invalidate(vendorProfileFutureProvider);
                  ref.invalidate(recommendationsProvider);
                },
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
      },
      loading: () => const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, __) => AppScaffold(
        body: Center(child: Text('Error: $e')),
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
    return InkWell( // Use InkWell for tap interaction
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: PrimaryCard(
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
      ),
    );
  }
}
