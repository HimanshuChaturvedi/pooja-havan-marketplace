import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/design_system.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import '../../../core/supabase/supabase_client.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import '../../booking/data/booking_providers.dart';
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
        final bookingsAsync = ref.watch(assignedBookingsProvider);

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
                  // ignore: unused_result
                  ref.refresh(assignedBookingsProvider);
                },
                child: bookingsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
                  error: (e, __) => Center(child: Text('Error loading bookings: $e')),
                  data: (bookings) {
                    // Calculate Stats
                    final total = bookings.length;
                    final pending = bookings.where((b) => b.status == BookingStatusDetailed.created || b.status == BookingStatusDetailed.assigned).length;
                    final completed = bookings.where((b) => b.status == BookingStatusDetailed.completed).length;
                    final earnings = bookings
                        .where((b) => b.status == BookingStatusDetailed.completed)
                        .fold<double>(0, (sum, b) => sum + b.poojaDakshina);

                    return ListView(
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
                            _buildStatCard('Total Bookings', '$total', Icons.assignment_outlined),
                            const SizedBox(width: 12),
                            _buildStatCard('Pending', '$pending', Icons.pending_actions_outlined),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatCard('Completed', '$completed', Icons.check_circle_outline),
                            const SizedBox(width: 12),
                            _buildStatCard('Earnings', '₹${earnings.toInt()}', Icons.account_balance_wallet_outlined),
                          ],
                        ),

                        const SizedBox(height: 32),
                        Text('Assignments', style: AppTextStyles.title.copyWith(fontSize: 18)),
                        const SizedBox(height: 12),
                        
                        if (bookings.isEmpty)
                          const Center(
                             child: Padding(
                               padding: EdgeInsets.all(32.0),
                               child: Text(
                                 'No active bookings right now.\nWhen customers book you, they will appear here.', 
                                 textAlign: TextAlign.center, 
                                 style: TextStyle(color: Colors.grey)
                               ),
                             )
                          )
                        else
                          ...bookings.map((booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PanditBookingCard(
                              booking: booking,
                              onRefresh: () => ref.refresh(assignedBookingsProvider),
                            ),
                          )),
                      ],
                    );
                  },
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

class _PanditBookingCard extends ConsumerStatefulWidget {
  final BookingDraft booking;
  final VoidCallback onRefresh;
  const _PanditBookingCard({required this.booking, required this.onRefresh});

  @override
  ConsumerState<_PanditBookingCard> createState() => _PanditBookingCardState();
}

class _PanditBookingCardState extends ConsumerState<_PanditBookingCard> {
  bool _isUpdating = false;

  Future<void> _updateStatus(BookingStatusDetailed status) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(bookingRepositoryProvider).updateBookingStatus(widget.booking.id!, status);
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    
    return PrimaryCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.ritualName,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.softGrey),
                const SizedBox(width: 8),
                Text(
                  booking.selectedDate != null 
                      ? "${booking.selectedDate!.day}/${booking.selectedDate!.month}/${booking.selectedDate!.year}"
                      : "Date TBD",
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: AppColors.softGrey),
                const SizedBox(width: 8),
                Text(booking.selectedTime ?? "Time TBD", style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.softGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.address ?? "No address specified",
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dakshina:', style: AppTextStyles.bodySmall),
                Text('₹${booking.poojaDakshina.toInt()}', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            
            // Lifecycle Buttons
            if (booking.status == BookingStatusDetailed.assigned) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Start Trip',
                loading: _isUpdating,
                onTap: () => _updateStatus(BookingStatusDetailed.onWay),
              ),
            ] else if (booking.status == BookingStatusDetailed.onWay) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Arrived / Start Pooja',
                loading: _isUpdating,
                onTap: () => _updateStatus(BookingStatusDetailed.inProgress),
              ),
            ] else if (booking.status == BookingStatusDetailed.inProgress) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Mark as Completed',
                loading: _isUpdating,
                onTap: () => _updateStatus(BookingStatusDetailed.completed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatusDetailed status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BookingStatusDetailed.created:
      case BookingStatusDetailed.assigned:
        color = AppColors.saffron;
        break;
      case BookingStatusDetailed.onWay:
      case BookingStatusDetailed.inProgress:
        color = Colors.blue;
        break;
      case BookingStatusDetailed.completed:
        color = Colors.green;
        break;
      case BookingStatusDetailed.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
