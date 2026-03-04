import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class HomeDateTimePage extends StatefulWidget {
  const HomeDateTimePage({super.key});

  @override
  State<HomeDateTimePage> createState() => _HomeDateTimePageState();
}

class _HomeDateTimePageState extends State<HomeDateTimePage> with SingleTickerProviderStateMixin {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late final AnimationController _animController;

  bool get isValid => selectedDate != null && selectedTime != null;

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

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
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
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
        selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatTime(TimeOfDay time) => time.format(context);

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                'Choose a divine moment for your pooja',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 48),

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
                onTap: _pickDate,
              ),
            ),

            const SizedBox(height: 16),

            // TIME CARD
            _StaggeredFade(
              controller: _animController,
              delay: 500,
              child: _SelectionCard(
                label: 'Auspicious Time',
                value: selectedTime == null
                    ? 'Tap to select time'
                    : _formatTime(selectedTime!),
                icon: Icons.access_time_filled_rounded,
                isSelected: selectedTime != null,
                onTap: _pickTime,
              ),
            ),
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
                  BookingSession.current?.selectedDate = selectedDate;
                  BookingSession.current?.selectedTime =
                      selectedTime!.format(context);
                  context.push('/samagri-required');
                }
              : null,
        ),
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
