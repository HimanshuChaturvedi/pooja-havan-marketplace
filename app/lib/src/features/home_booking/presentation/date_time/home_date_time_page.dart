import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

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
      duration: const Duration(milliseconds: 1500),
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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.saffron,
              onPrimary: Colors.white,
              surface: AppColors.midnight,
              onSurface: AppColors.cream,
            ),
            dialogBackgroundColor: AppColors.midnight,
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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.saffron,
              onPrimary: Colors.white,
              surface: AppColors.midnight,
              onSurface: AppColors.cream,
            ),
            dialogBackgroundColor: AppColors.midnight,
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Select Date & Time',
          style: AppTextStyles.title.copyWith(color: AppColors.maroon, fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFade(
                controller: _animController,
                delay: 100,
                child: Text(
                  'Choose a divine moment for your pooja',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.deepSaffron,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // DATE CARD
              _StaggeredFade(
                controller: _animController,
                delay: 300,
                child: _SelectionCard(
                  label: 'Preferred Date',
                  value: selectedDate == null
                      ? 'Tap to select date'
                      : _formatDate(selectedDate!),
                  icon: Icons.calendar_today_outlined,
                  isSelected: selectedDate != null,
                  onTap: _pickDate,
                ),
              ),

              const SizedBox(height: 20),

              // TIME CARD
              _StaggeredFade(
                controller: _animController,
                delay: 500,
                child: _SelectionCard(
                  label: 'Auspicious Time',
                  value: selectedTime == null
                      ? 'Tap to select time'
                      : _formatTime(selectedTime!),
                  icon: Icons.access_time_outlined,
                  isSelected: selectedTime != null,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.midnight.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppColors.saffron : Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: isValid ? 8 : 0,
              shadowColor: AppColors.deepSaffron.withOpacity(0.5),
            ),
            onPressed: isValid
                ? () {
                    BookingSession.current?.selectedDate = selectedDate;
                    BookingSession.current?.selectedTime =
                        selectedTime!.format(context);
                    context.push('/samagri-required');
                  }
                : null,
            child: Text(
              'Continue to Samagri Selection →',
              style: AppTextStyles.button.copyWith(
                color: isValid ? AppColors.maroon : AppColors.maroon.withOpacity(0.4),
                fontSize: 18,
              ),
            ),
          ),
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
    return Container(
      width: double.infinity,
      child: DivineGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.saffron : Colors.black).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppColors.deepSaffron : AppColors.maroon.withOpacity(0.4), size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.deepSaffron.withOpacity(0.5),
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 20,
                      color: isSelected ? AppColors.maroon : AppColors.maroon.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: isSelected ? AppColors.saffron : AppColors.maroon.withOpacity(0.2),
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
        final start = (delay / 1500).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1500).clamp(0, 1.0).toDouble();
        
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
