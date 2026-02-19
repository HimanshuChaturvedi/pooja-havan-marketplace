import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Select Schedule",
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Text(
                  "Booking with ${widget.panditName}",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.maroon.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 24),

              _StaggeredFade(
                controller: _animController,
                delay: 250,
                child: Text(
                  "Choose Date",
                  style: AppTextStyles.title.copyWith(fontSize: 20, color: AppColors.maroon),
                ),
              ),
              const SizedBox(height: 16),

              _StaggeredFade(
                controller: _animController,
                delay: 400,
                child: DivineGlassCard(
                  padding: const EdgeInsets.all(8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.saffron,
                        onPrimary: Colors.white,
                        surface: Colors.transparent,
                        onSurface: AppColors.maroon,
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
                child: Text(
                  "Select Time Slot",
                  style: AppTextStyles.title.copyWith(fontSize: 20, color: AppColors.maroon),
                ),
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
                          color: isSelected ? AppColors.saffron : AppColors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.deepSaffron : AppColors.glassBorder,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.saffron.withOpacity(0.3), blurRadius: 10)]
                              : [],
                        ),
                        child: Text(
                          slot,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.maroon,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: (selectedDate != null && selectedTime != null)
                ? () {
                    context.push('/booking/details/${widget.panditName}');
                  }
                : null,
            child: Text(
              'Continue to Details →',
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
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
