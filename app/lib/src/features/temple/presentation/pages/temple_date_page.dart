import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class TempleDatePage extends StatefulWidget {
  final String temple;
  final String city;
  final String ritual;
  const TempleDatePage({super.key, required this.temple, required this.city, required this.ritual});

  @override
  State<TempleDatePage> createState() => _TempleDatePageState();
}

class _TempleDatePageState extends State<TempleDatePage> {
  DateTime? _selectedDate;
  String? _selectedSlot;

  static const List<String> _slots = [
    '6:00 AM – 7:00 AM',
    '7:30 AM – 8:30 AM',
    '9:00 AM – 10:00 AM',
    '11:00 AM – 12:00 PM',
    '5:00 PM – 6:00 PM',
    '6:30 PM – 7:30 PM',
  ];

  bool get _canContinue => _selectedDate != null && _selectedSlot != null;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select Date & Time',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When would you like\nto visit?',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.ritual} at ${widget.temple}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
            ),
            const SizedBox(height: 32),

            // DATE PICKER
            const SectionHeader(title: 'Select Date'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: AppColors.saffron),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: PrimaryCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.saffron, size: 22),
                    const SizedBox(width: 16),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                          : 'Tap to select a date',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _selectedDate != null ? AppColors.darkCharcoal : AppColors.softGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // TIME SLOTS
            const SectionHeader(title: 'Select Time Slot'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _slots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.saffron : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.saffron : Colors.black12,
                      ),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      slot,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.darkCharcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: PrimaryButton(
          label: 'Continue →',
          onTap: _canContinue
              ? () {
                  final dateStr = '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
                  context.push(
                    '/temple-summary?temple=${Uri.encodeComponent(widget.temple)}&city=${widget.city}&ritual=${Uri.encodeComponent(widget.ritual)}&date=${Uri.encodeComponent(dateStr)}&slot=${Uri.encodeComponent(_selectedSlot!)}',
                  );
                }
              : null,
        ),
      ),
    );
  }
}
