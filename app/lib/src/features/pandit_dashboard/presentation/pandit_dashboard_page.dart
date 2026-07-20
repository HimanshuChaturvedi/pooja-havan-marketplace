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
import 'state/pandit_availability_provider.dart';

class PanditDashboardPage extends ConsumerStatefulWidget {
  const PanditDashboardPage({super.key});

  @override
  ConsumerState<PanditDashboardPage> createState() => _PanditDashboardPageState();
}

class _PanditDashboardPageState extends ConsumerState<PanditDashboardPage> {
  int _selectedTab = 0; // 0 = Assignments, 1 = Availability
  DateTime _currentMonth = DateTime.now();

  void _handleLogout(BuildContext context) async {
    await supabase.auth.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _handleLogout(context),
            )
          ],
          body: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (profile) {
              if (profile == null) {
                return const Center(child: Text('Profile not found'));
              }
              return Column(
                children: [
                  // Tab Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedTab == 0
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : null,
                                ),
                                child: Text(
                                  'Bookings',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 0 ? AppColors.saffron : AppColors.softGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _selectedTab == 1
                                      ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                      : null,
                                ),
                                child: Text(
                                  'My Availability',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 1 ? AppColors.saffron : AppColors.softGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: IndexedStack(
                      index: _selectedTab,
                      children: [
                        // TAB 0: Bookings View
                        RefreshIndicator(
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
                              final pendingStatuses = [BookingStatusDetailed.created, BookingStatusDetailed.assigned, BookingStatusDetailed.onWay, BookingStatusDetailed.inProgress];
                              final pending = bookings.where((b) => pendingStatuses.contains(b.status)).length;
                              final completed = bookings.where((b) => b.status == BookingStatusDetailed.completed).length;
                              final earnings = bookings
                                  .where((b) => b.status == BookingStatusDetailed.completed)
                                  .fold<double>(0, (sum, b) => sum + b.poojaDakshina);

                              return ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                children: [
                                  // Profile Header Card
                                  PrimaryCard(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: AppColors.saffron.withOpacity(0.2),
                                          backgroundImage: profile.profileImageUrl != null
                                              ? NetworkImage(profile.profileImageUrl!)
                                              : null,
                                          child: profile.profileImageUrl == null
                                              ? const Icon(Icons.person, color: AppColors.saffron, size: 26)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${profile.firstName} ${profile.lastName}',
                                                style: AppTextStyles.title.copyWith(fontSize: 16),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Verified Pandit Partner',
                                                style: AppTextStyles.bodySmall.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  Text('Overview', style: AppTextStyles.title.copyWith(fontSize: 16)),
                                  const SizedBox(height: 10),
                                  
                                  // Stat Grid
                                  Row(
                                    children: [
                                      _buildStatCard('Total Bookings', '$total', Icons.assignment_outlined),
                                      const SizedBox(width: 10),
                                      _buildStatCard('Pending', '$pending', Icons.pending_actions_outlined),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _buildStatCard('Completed', '$completed', Icons.check_circle_outline),
                                      const SizedBox(width: 10),
                                      _buildStatCard('Earnings', '₹${earnings.toInt()}', Icons.account_balance_wallet_outlined),
                                    ],
                                  ),

                                  const SizedBox(height: 24),
                                  Text('Active Requests', style: AppTextStyles.title.copyWith(fontSize: 16)),
                                  const SizedBox(height: 10),
                                  
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
                                        panditProfileId: profile.id,
                                      ),
                                    )),
                                ],
                              );
                            },
                          ),
                        ),

                        // TAB 1: Availability Calendar View
                        _buildCalendarTab(profile.id),
                      ],
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.saffron, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab(String panditId) {
    final blockedDatesAsync = ref.watch(panditBlockedDatesProvider(panditId));
    final bookingsAsync = ref.watch(assignedBookingsProvider);

    return blockedDatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
      error: (e, __) => Center(child: Text('Error loading calendar: $e')),
      data: (blockedDates) {
        final year = _currentMonth.year;
        final month = _currentMonth.month;
        final firstDay = DateTime(year, month, 1);
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final firstWeekday = firstDay.weekday % 7; // Sunday start: 0 for Sunday

        final monthNames = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];

        // Build a map of date -> list of bookings for this month
        final Map<String, List<BookingDraft>> bookingsByDate = {};
        final allBookings = bookingsAsync.value ?? [];
        for (final b in allBookings) {
          if (b.selectedDate != null && 
              b.status != BookingStatusDetailed.cancelled) {
            final dateStr = "${b.selectedDate!.year}-${b.selectedDate!.month.toString().padLeft(2, '0')}-${b.selectedDate!.day.toString().padLeft(2, '0')}";
            bookingsByDate.putIfAbsent(dateStr, () => []);
            bookingsByDate[dateStr]!.add(b);
          }
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Calendar Description
            PrimaryCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.saffron, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap dates to mark your days off. Green dates have bookings — tap to see details.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkCharcoal, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Legend
                  Row(
                    children: [
                      _legendDot(Colors.green.shade500, 'Has Bookings'),
                      const SizedBox(width: 16),
                      _legendDot(AppColors.saffron, 'Day Off'),
                      const SizedBox(width: 16),
                      _legendDot(Colors.white, 'Available', borderColor: Colors.grey.shade300),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Month Selector Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.saffron),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(year, month - 1, 1);
                    });
                  },
                ),
                Text(
                  '${monthNames[month - 1]} $year',
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.saffron),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(year, month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Days of the Week Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((d) => SizedBox(
                width: 40,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.softGrey),
                ),
              )).toList(),
            ),
            const SizedBox(height: 10),

            // Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: firstWeekday + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox.shrink();
                }

                final dayNum = index - firstWeekday + 1;
                final date = DateTime(year, month, dayNum);
                final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                
                final dateBookings = bookingsByDate[dateStr] ?? [];
                final bookingCount = dateBookings.length;
                final isManuallyBlocked = blockedDates.contains(dateStr);
                final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                Color bgColor;
                Color borderColor;
                Color textColor;
                Widget? badge;

                if (bookingCount > 0 && !isManuallyBlocked) {
                  // Has bookings — green
                  bgColor = Colors.green.shade500;
                  borderColor = Colors.green.shade600;
                  textColor = Colors.white;
                  badge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$bookingCount',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.green.shade700,
                      ),
                    ),
                  );
                } else if (isManuallyBlocked) {
                  // Manually blocked — saffron
                  bgColor = AppColors.saffron;
                  borderColor = AppColors.saffron;
                  textColor = Colors.white;
                  badge = const Icon(Icons.block, color: Colors.white, size: 10);
                } else if (isPast) {
                  bgColor = Colors.grey.shade100;
                  borderColor = Colors.transparent;
                  textColor = Colors.grey;
                  badge = null;
                } else {
                  bgColor = Colors.white;
                  borderColor = Colors.grey.shade200;
                  textColor = AppColors.darkCharcoal;
                  badge = null;
                }

                return InkWell(
                  onTap: isPast
                      ? null
                      : bookingCount > 0
                          ? () => _showBookingDetailsSheet(context, dateStr, dateBookings)
                          : () async {
                              try {
                                await ref.read(panditBlockedDatesProvider(panditId).notifier).toggleDate(dateStr);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          if (badge != null) badge,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _legendDot(Color color, String label, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.softGrey)),
      ],
    );
  }

  void _showBookingDetailsSheet(BuildContext context, String dateStr, List<BookingDraft> bookings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        // Format date for display
        final parts = dateStr.split('-');
        final displayDate = '${parts[2]}/${parts[1]}/${parts[0]}';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.saffron, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bookings on $displayDate',
                    style: AppTextStyles.title.copyWith(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${bookings.length} booking${bookings.length > 1 ? 's' : ''} scheduled',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey),
              ),
              const SizedBox(height: 16),
              ...bookings.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.access_time, size: 18, color: Colors.green.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.ritualName,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '⏰ ${b.selectedTime ?? "Time TBD"} • ${b.address ?? "No address"}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.status == BookingStatusDetailed.confirmed 
                              ? Colors.blue.shade50 
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          b.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: b.status == BookingStatusDetailed.confirmed 
                                ? Colors.blue 
                                : Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _PanditBookingCard extends ConsumerStatefulWidget {
  final BookingDraft booking;
  final VoidCallback onRefresh;
  final String panditProfileId;
  const _PanditBookingCard({
    required this.booking,
    required this.onRefresh,
    required this.panditProfileId,
  });

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

  Future<void> _declineRequest() async {
    setState(() => _isUpdating = true);
    try {
      final action = await ref.read(bookingRepositoryProvider).rejectAndReassignBooking(widget.booking.id!, widget.panditProfileId);
      widget.onRefresh();
      if (mounted) {
        String msg;
        if (action == 'reassigned') {
          msg = 'Booking declined and reassigned to another pandit.';
        } else {
          msg = 'Booking declined. No replacement pandit is currently available. The booking has been returned to the dispatch queue.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.saffron),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error declining booking: $e'), backgroundColor: Colors.red),
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
                Expanded(
                  child: Text(
                    booking.ritualName,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
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
            
            // Accept/Reject or Lifecycle Buttons
            if (booking.status == BookingStatusDetailed.created || 
                booking.status == BookingStatusDetailed.assigned ||
                booking.status == BookingStatusDetailed.paid) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Accept Request',
                      loading: _isUpdating,
                      onTap: () => _updateStatus(BookingStatusDetailed.confirmed),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Decline',
                      onTap: _declineRequest,
                    ),
                  ),
                ],
              ),
            ] else if (booking.status == BookingStatusDetailed.confirmed) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Start Trip',
                loading: _isUpdating,
                onTap: () => _updateStatus(BookingStatusDetailed.onWay),
              ),
            ] else if (booking.status == BookingStatusDetailed.onWay || 
                       booking.status == BookingStatusDetailed.inProgress) ...[
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
      case BookingStatusDetailed.paid:
        color = Colors.teal;
        break;
      case BookingStatusDetailed.confirmed:
        color = Colors.blue;
        break;
      case BookingStatusDetailed.completed:
        color = Colors.green;
        break;
      case BookingStatusDetailed.cancelled:
      case BookingStatusDetailed.rejected:
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
