import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  // ----------------------------
  // SERIALIZATION
  // ----------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'amount': amount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'userLabel': userLabel,
      'bookedForDate': bookedForDate?.toIso8601String(),
      'bookedForTime': bookedForTime,
      'samagriSessionId': samagriSessionId,
      'bookingId': bookingId,
    };
  }

  factory TransactionLogEntry.fromJson(Map<String, dynamic> json) {
    return TransactionLogEntry(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'],
      amount: json['amount'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      userLabel: json['userLabel'],
      bookedForDate: json['bookedForDate'] != null
          ? DateTime.parse(json['bookedForDate'])
          : null,
      bookedForTime: json['bookedForTime'],
      samagriSessionId: json['samagriSessionId'],
      bookingId: json['bookingId'],
    );
  }
}

class TransactionLogService {
  static const String _storageKey =
      'shubh_pooja_transaction_logs_v1';

  static final List<TransactionLogEntry> _logs = [];

  static SharedPreferences? _prefs;

  // ----------------------------
  // INIT (CALL ON APP START)
  // ----------------------------

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
  }

  // ----------------------------
  // APPEND-ONLY, DUPLICATE SAFE
  // ----------------------------

  static void append(TransactionLogEntry entry) {
    final exists = _logs.any((e) => e.id == entry.id);
    if (exists) return;

    _logs.add(entry);
    _persist();
  }

  static UnmodifiableListView<TransactionLogEntry> all() {
    final sorted = List<TransactionLogEntry>.from(_logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return UnmodifiableListView(sorted);
  }

  // ----------------------------
  // INTERNAL STORAGE
  // ----------------------------

  static void _persist() {
    if (_prefs == null) return;

    final encoded = _logs
        .map((e) => e.toJson())
        .toList();

    _prefs!.setString(
      _storageKey,
      jsonEncode(encoded),
    );
  }

  static void _loadFromStorage() {
    if (_prefs == null) return;

    final raw = _prefs!.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final List decoded = jsonDecode(raw);

    _logs
      ..clear()
      ..addAll(
        decoded.map(
          (e) => TransactionLogEntry.fromJson(
            Map<String, dynamic>.from(e),
          ),
        ),
      );
  }

  /// ❌ NEVER CALL IN PROD FLOWS
  static void clear() {
    _logs.clear();
    _prefs?.remove(_storageKey);
  }
}
