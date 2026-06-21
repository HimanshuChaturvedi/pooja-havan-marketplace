import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pandit_onboarding/data/pandit_repository_provider.dart';

/// Model representing a booked time slot for a Pandit
class BookedSlot {
  final String startTime;
  final String endTime;
  final String ritualName;
  final String status;

  BookedSlot({
    required this.startTime,
    required this.endTime,
    required this.ritualName,
    required this.status,
  });

  factory BookedSlot.fromJson(Map<String, dynamic> json) {
    final start = json['start_time'] ?? '';
    var end = json['end_time'] ?? '';
    if (end.isEmpty && start.isNotEmpty) {
      end = TimeSlotConfig.calculateEndTime(start);
    }
    return BookedSlot(
      startTime: start,
      endTime: end,
      ritualName: json['ritual_name'] ?? 'Pooja',
      status: json['booking_status'] ?? 'PAID',
    );
  }
}

/// Predefined time slots from 5:00 AM to 8:00 PM
/// Each slot is 2.5 hours apart (90 min pooja + 60 min buffer)
class TimeSlotConfig {
  static const int poojaDurationMinutes = 90;
  static const int bufferMinutes = 60;
  static const int totalWindowMinutes = poojaDurationMinutes + bufferMinutes; // 150

  static const int startHour = 5;  // 5:00 AM
  static const int endHour = 20;   // 8:00 PM

  /// Generate fixed time slots for the day (spaced by 1.5 hours)
  static List<String> get fixedSlots => [
    '5:00 AM',
    '6:30 AM',
    '8:00 AM',
    '9:30 AM',
    '11:00 AM',
    '12:30 PM',
    '2:00 PM',
    '3:30 PM',
    '5:00 PM',
    '6:30 PM',
    '8:00 PM',
  ];

  /// Calculate the end time string (including buffer) for a start time string
  static String calculateEndTime(String startTimeStr) {
    final startMinutes = _timeToMinutes(startTimeStr);
    if (startMinutes == null) return '';

    final endMinutes = startMinutes + totalWindowMinutes;
    final endHour24 = (endMinutes ~/ 60) % 24;
    final endMinute = endMinutes % 60;

    final period = endHour24 >= 12 ? 'PM' : 'AM';
    var hour12 = endHour24 % 12;
    if (hour12 == 0) hour12 = 12;

    final minuteStr = endMinute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  /// Check if a given slot conflicts with any booked slot
  static bool isSlotConflicting(String slotTime, List<BookedSlot> bookedSlots) {
    final slotMinutes = _timeToMinutes(slotTime);
    if (slotMinutes == null) return false;

    for (final booked in bookedSlots) {
      final bookedStart = _timeToMinutes(booked.startTime);
      if (bookedStart == null) continue;

      final bookedEnd = bookedStart + totalWindowMinutes;
      final slotEnd = slotMinutes + totalWindowMinutes;

      // Check bidirectional overlap
      if (slotMinutes < bookedEnd && slotEnd > bookedStart) {
        return true;
      }
    }
    return false;
  }

  /// Get the conflicting booking info for a slot (for tooltip display)
  static BookedSlot? getConflictingBooking(String slotTime, List<BookedSlot> bookedSlots) {
    final slotMinutes = _timeToMinutes(slotTime);
    if (slotMinutes == null) return null;

    for (final booked in bookedSlots) {
      final bookedStart = _timeToMinutes(booked.startTime);
      if (bookedStart == null) continue;

      final bookedEnd = bookedStart + totalWindowMinutes;
      final slotEnd = slotMinutes + totalWindowMinutes;

      if (slotMinutes < bookedEnd && slotEnd > bookedStart) {
        return booked;
      }
    }
    return null;
  }

  /// Get list of available slots (not conflicting with any booked slot)
  static List<String> getAvailableSlots(List<BookedSlot> bookedSlots) {
    return fixedSlots.where((slot) => !isSlotConflicting(slot, bookedSlots)).toList();
  }

  /// Convert time string like "5:00 AM", "12:30 PM", "10:00 AM" to minutes since midnight
  static int? _timeToMinutes(String timeStr) {
    try {
      final cleaned = timeStr.trim().toUpperCase();
      
      // Handle HH:MM AM/PM format
      final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)').firstMatch(cleaned);
      if (match != null) {
        var hours = int.parse(match.group(1)!);
        final minutes = int.parse(match.group(2)!);
        final period = match.group(3)!;

        if (period == 'PM' && hours != 12) hours += 12;
        if (period == 'AM' && hours == 12) hours = 0;

        return hours * 60 + minutes;
      }

      // Handle 24h format HH:MM
      final match24 = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(cleaned);
      if (match24 != null) {
        final hours = int.parse(match24.group(1)!);
        final minutes = int.parse(match24.group(2)!);
        return hours * 60 + minutes;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Provider to fetch booked slots for a pandit on a specific date
final panditBookedSlotsProvider = FutureProvider.autoDispose.family<List<BookedSlot>, ({String panditId, String dateStr})>(
  (ref, params) async {
    final repository = ref.read(panditRepositoryProvider);
    final rawSlots = await repository.getBookedSlots(params.panditId, params.dateStr);
    return rawSlots.map((m) => BookedSlot.fromJson(m)).toList();
  },
);

