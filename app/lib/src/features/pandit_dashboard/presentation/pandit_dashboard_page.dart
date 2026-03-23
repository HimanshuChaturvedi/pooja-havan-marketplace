import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/design_system.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../pandit_onboarding/data/pandit_repository_provider.dart';
import '../../auth/presentation/state/auth_provider_impl.dart';

class PanditDashboardPage extends ConsumerWidget {
  const PanditDashboardPage({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(supabaseUserProvider);

    return userAsync.when(
      loading: () => const AppScaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, __) => AppScaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }

        final profileAsync = ref.watch(panditProfileFutureProvider(user.id));

        return AppScaffold(
          title: 'Pandit Dashboard',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.saffron),
              onPressed: () => _handleLogout(context, ref),
            )
          ],
          body: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (profile) {
              if (profile == null) {
                return const Center(child: Text('Profile not found'));
              }
              return RefreshIndicator(
                color: AppColors.saffron,
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(panditProfileFutureProvider(user.id));
                },
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Profile Header
                    PrimaryCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.saffron.withOpacity(0.2),
                            backgroundImage: profile.profileImageUrl != null
                                ? NetworkImage(profile.profileImageUrl!)
                                : null,
                            child: profile.profileImageUrl == null
                                ? const Icon(Icons.person, color: AppColors.saffron, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile.firstName} ${profile.lastName}',
                                  style: AppTextStyles.title.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: profile.verificationStatus.name == 'VERIFIED' ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    profile.verificationStatus.name,
                                    style: TextStyle(
                                      color: profile.verificationStatus.name == 'VERIFIED' ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Overview', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    
                    // Stat Grid
                    Row(
                      children: [
                        _buildStatCard('Total Bookings', '0', Icons.assignment_outlined),
                        const SizedBox(width: 12),
                        _buildStatCard('Pending', '0', Icons.pending_actions_outlined),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCard('Completed', '0', Icons.check_circle_outline),
                        const SizedBox(width: 12),
                        _buildStatCard('Earnings', '₹0', Icons.account_balance_wallet_outlined),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text('Recent Requests', style: AppTextStyles.title.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    const Center(
                       child: Padding(
                         padding: EdgeInsets.all(32.0),
                         child: Text(
                           'No active bookings right now.\nWhen customers book you, they will appear here.', 
                           textAlign: TextAlign.center, 
                           style: TextStyle(color: Colors.grey)
                         ),
                       )
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: PrimaryCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.saffron, size: 28),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey)),
          ],
        ),
      ),
    );
  }
}
