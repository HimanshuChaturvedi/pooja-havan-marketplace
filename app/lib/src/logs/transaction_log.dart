import 'dart:collection';

/// 🔒 TYPE OF TRANSACTION
enum TransactionType {
  booking,
  samagri,
}

/// 🔒 STATUS
enum TransactionStatus {
  created,
  paid,
  completed,
}

/// 🔒 SINGLE LOG ENTRY (IMMUTABLE)
class TransactionLogEntry {
  final String id;
  final TransactionType type;
  final String title;
  final int amount;
  final TransactionStatus status;
  final DateTime createdAt;

  /// Optional references (no dependency)
  final String? bookingId;
  final String? samagriSessionId;

  const TransactionLogEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.bookingId,
    this.samagriSessionId,
  });
}

/// 🔒 APPEND-ONLY, IN-MEMORY LOG
/// ❌ No delete
/// ❌ No update
/// ❌ No backend
class TransactionLogService {
  static final List<TransactionLogEntry> _logs = [];

  /// ADD NEW ENTRY (APPEND ONLY)
  static void append(TransactionLogEntry entry) {
    _logs.add(entry);
  }

  /// READ-ONLY ACCESS (LATEST FIRST)
  static UnmodifiableListView<TransactionLogEntry> all() {
    final sorted = List<TransactionLogEntry>.from(_logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return UnmodifiableListView(sorted);
  }

  /// CLEAR ALL (ONLY FOR DEV / RESET)
  static void clear() {
    _logs.clear();
  }
}
