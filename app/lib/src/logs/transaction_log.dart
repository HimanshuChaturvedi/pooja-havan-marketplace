import 'dart:collection';

enum TransactionType {
  booking,
  samagri,
}

enum TransactionStatus {
  created,
  paid,
  completed,
}

class TransactionLogEntry {
  final String id;
  final TransactionType type;
  final String title;
  final int amount;
  final TransactionStatus status;
  final DateTime createdAt;

  // USER (temporary)
  final String userLabel;

  // BOOKING-SPECIFIC
  final DateTime? bookedForDate;
  final String? bookedForTime;

  // BACKWARD COMPAT
  final String? samagriSessionId;
  final String? bookingId;

  const TransactionLogEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.userLabel,
    this.bookedForDate,
    this.bookedForTime,
    this.samagriSessionId,
    this.bookingId,
  });
}

class TransactionLogService {
  static final List<TransactionLogEntry> _logs = [];

  /// 🔒 APPEND-ONLY, DUPLICATE SAFE
  static void append(TransactionLogEntry entry) {
    final exists = _logs.any((e) => e.id == entry.id);
    if (exists) return;

    _logs.add(entry);
  }

  static UnmodifiableListView<TransactionLogEntry> all() {
    final sorted = List<TransactionLogEntry>.from(_logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return UnmodifiableListView(sorted);
  }

  /// ❌ NEVER CALL IN PROD FLOWS
  static void clear() {
    _logs.clear();
  }
}
