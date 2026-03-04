import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<String?>((ref) => null);

class BookingStep1Page extends ConsumerStatefulWidget {
  final String panditName;
  const BookingStep1Page({super.key, required this.panditName});

  @override
  ConsumerState<BookingStep1Page> createState() => _BookingStep1PageState();
}

class _BookingStep1PageState extends ConsumerState<BookingStep1Page> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

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

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTime = ref.watch(selectedTimeProvider);

    return AppScaffold(
      title: "Select Schedule",
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StaggeredFade(
              controller: _animController,
              delay: 100,
              child: Text(
                "Booking with ${widget.panditName}",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
            ),
            const SizedBox(height: 32),

            _StaggeredFade(
              controller: _animController,
              delay: 250,
              child: const SectionHeader(title: "Choose Date"),
            ),
            const SizedBox(height: 16),

            _StaggeredFade(
              controller: _animController,
              delay: 400,
              child: PrimaryCard(
                padding: const EdgeInsets.all(8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.saffron,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.darkCharcoal,
                    ),
                  ),
                  child: CalendarDatePicker(
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    initialDate: selectedDate ?? DateTime.now(),
                    onDateChanged: (value) {
                      ref.read(selectedDateProvider.notifier).state = value;
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            _StaggeredFade(
              controller: _animController,
              delay: 600,
              child: const SectionHeader(title: "Select Time Slot"),
            ),
            const SizedBox(height: 16),

            _StaggeredFade(
              controller: _animController,
              delay: 800,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timeSlots.map((slot) {
                  final isSelected = selectedTime == slot;
                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedTimeProvider.notifier).state = slot;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.saffron : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.saffron : AppColors.softGrey.withOpacity(0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? AppColors.saffron.withOpacity(0.2) 
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        slot,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: PrimaryButton(
          label: 'Continue to Details →',
          onTap: () {
            context.push('/booking/details/${widget.panditName}');
          },
          loading: false,
          color: (selectedDate != null && selectedTime != null) ? null : AppColors.softGrey.withOpacity(0.3),
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

const List<String> _timeSlots = [
  "07:00 AM", "08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM",
  "12:00 PM", "02:00 PM", "03:00 PM", "04:00 PM", "06:00 PM",
];
