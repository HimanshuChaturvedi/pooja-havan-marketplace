import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeDateTimePage extends StatefulWidget {
  const HomeDateTimePage({super.key});

  @override
  State<HomeDateTimePage> createState() => _HomeDateTimePageState();
}

class _HomeDateTimePageState extends State<HomeDateTimePage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool get isValid => selectedDate != null && selectedTime != null;

  Future<void> _pickDate() async {
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
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
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  String _formatTime(TimeOfDay time) =>
      time.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a convenient date and time for the pooja.',
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            // DATE
            Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Select date'
                      : _formatDate(selectedDate!),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TIME
            Text(
              'Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedTime == null
                      ? 'Select time'
                      : _formatTime(selectedTime!),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid
                    ? () {
                        // Next step (not created yet)
                        context.push('/home-samagri');
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
