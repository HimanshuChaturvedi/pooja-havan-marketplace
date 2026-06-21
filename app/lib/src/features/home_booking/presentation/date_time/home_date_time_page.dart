import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../../../pandit_dashboard/presentation/state/pandit_availability_provider.dart';
import '../../../pandit_dashboard/presentation/state/pandit_time_slots_provider.dart';

class HomeDateTimePage extends ConsumerStatefulWidget {
  const HomeDateTimePage({super.key});

  @override
  ConsumerState<HomeDateTimePage> createState() => _HomeDateTimePageState();
}

class _HomeDateTimePageState extends ConsumerState<HomeDateTimePage> with SingleTickerProviderStateMixin {
  DateTime? selectedDate;
  String? selectedTimeSlot; // Now stores the slot string like "5:00 AM"
  late final AnimationController _animController;

  bool get isValid => selectedDate != null && selectedTimeSlot != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(List<String> blockedDates) async {
    final today = DateTime.now();
    
    // Safety check: ensure initialDate starts on a selectable day to prevent showDatePicker crash
    DateTime initialDate = today;
    for (int i = 0; i < 60; i++) {
      final dateStr = "${initialDate.year}-${initialDate.month.toString().padLeft(2, '0')}-${initialDate.day.toString().padLeft(2, '0')}";
      if (!blockedDates.contains(dateStr)) {
        break;
      }
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
      selectableDayPredicate: (DateTime day) {
        // Only block manually blocked dates (pandit's days off)
        final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
        return !blockedDates.contains(dateStr);
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.saffron,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkCharcoal,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _getDateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final currentDraft = ref.watch(bookingSessionProvider).current;
    final panditId = currentDraft?.panditId;
    
    // Blocked dates = only manually blocked (pandit's days off)
    final List<String> blockedDates = (panditId != null)
        ? (ref.watch(panditBlockedDatesProvider(panditId)).value ?? [])
        : [];

    // Booked slots for selected date (if date is picked and pandit is selected)
    final bookedSlotsAsync = (panditId != null && selectedDate != null)
        ? ref.watch(panditBookedSlotsProvider((panditId: panditId, dateStr: _getDateStr(selectedDate!))))
        : null;

    return AppScaffold(
      title: 'Select Date & Time',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a divine moment for your pooja',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.saffron,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (currentDraft?.panditName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Pooja will be led by Pandit ${currentDraft!.panditName}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (blockedDates.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.saffron),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Days marked as off by Pandit ${currentDraft?.panditName ?? "partner"} are disabled.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 36),

            // DATE CARD
            _StaggeredFade(
              controller: _animController,
              delay: 300,
              child: _SelectionCard(
                label: 'Preferred Date',
                value: selectedDate == null
                    ? 'Tap to select date'
                    : _formatDate(selectedDate!),
                icon: Icons.calendar_today_rounded,
                isSelected: selectedDate != null,
                onTap: () => _pickDate(blockedDates),
              ),
            ),

            const SizedBox(height: 24),

            // TIME SLOT SELECTOR (replaces old showTimePicker)
            if (selectedDate != null) ...[
              _StaggeredFade(
                controller: _animController,
                delay: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: AppColors.saffron, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'AUSPICIOUS TIME',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.softGrey,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Loading / Error / Slots Grid
                    if (bookedSlotsAsync == null)
                      const _TimeSlotPlaceholder()
                    else
                      bookedSlotsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: AppColors.saffron),
                          ),
                        ),
                        error: (e, __) => _buildSlotGrid([], panditId),
                        data: (bookedSlots) {
                          return _buildSlotGrid(bookedSlots, panditId);
                        },
                      ),
                  ],
                ),
              ),
            ] else ...[
              _StaggeredFade(
                controller: _animController,
                delay: 500,
                child: _SelectionCard(
                  label: 'Auspicious Time',
                  value: 'Select a date first',
                  icon: Icons.access_time_filled_rounded,
                  isSelected: false,
                  onTap: () => _pickDate(blockedDates),
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Continue to Samagri Selection →',
          onTap: isValid
              ? () {
                  final current = ref.read(bookingSessionProvider).current;
                  if (current != null) {
                    final updated = current.copyWith(
                      selectedDate: selectedDate,
                      selectedTime: selectedTimeSlot,
                    );
                    ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
                  }
                  context.push('/samagri-required');
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildSlotGrid(List<BookedSlot> bookedSlots, String? panditId) {
    final allSlots = TimeSlotConfig.fixedSlots;
    final availableSlots = TimeSlotConfig.getAvailableSlots(bookedSlots);

    if (availableSlots.isEmpty) {
      return PrimaryCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.event_busy, color: AppColors.saffron, size: 40),
            const SizedBox(height: 12),
            Text(
              'Pandit ji is fully booked on this date!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please choose another date.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slot Grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allSlots.map((slot) {
            final isAvailable = availableSlots.contains(slot);
            final isSelected = selectedTimeSlot == slot;
            final conflicting = TimeSlotConfig.getConflictingBooking(slot, bookedSlots);

            return GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() {
                        selectedTimeSlot = slot;
                      });
                    }
                  : () {
                      // Show conflict info
                      if (conflicting != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '⏰ Pandit ji has "${conflicting.ritualName}" from ${conflicting.startTime} to ${conflicting.endTime}',
                            ),
                            backgroundColor: AppColors.saffron,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: (MediaQuery.of(context).size.width - 70) / 3,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.saffron
                      : isAvailable
                          ? Colors.white
                          : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.saffron
                        : isAvailable
                            ? Colors.grey.shade200
                            : Colors.red.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.saffron.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      isAvailable
                          ? (isSelected ? Icons.check_circle : Icons.schedule)
                          : Icons.block,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : isAvailable
                              ? AppColors.saffron
                              : Colors.red.shade300,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      slot,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                                ? AppColors.darkCharcoal
                                : Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAvailable ? 'Available' : 'Booked',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : isAvailable
                                ? Colors.green.shade600
                                : Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Booked slots info
        if (bookedSlots.isNotEmpty) ...[
          const SizedBox(height: 16),
          PrimaryCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'Pandit ji\'s schedule on this date:',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...bookedSlots.map((slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slot.startTime} – ${slot.endTime}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          slot.ritualName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.softGrey,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeSlotPlaceholder extends StatelessWidget {
  const _TimeSlotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: AppColors.softGrey, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select a date above to see available time slots',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.softGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrimaryCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.saffron : AppColors.softGrey).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: isSelected ? AppColors.saffron : AppColors.softGrey, 
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.softGrey,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.darkCharcoal : AppColors.softGrey.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: isSelected ? AppColors.saffron : AppColors.softGrey.withOpacity(0.3),
            ),
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
        final start = (delay / 1200).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1200).clamp(0, 1.0).toDouble();
        
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
