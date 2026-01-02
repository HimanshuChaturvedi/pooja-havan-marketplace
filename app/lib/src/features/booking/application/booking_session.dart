import '../domain/booking_draft.dart';

/// 🔑 Booking lifecycle
enum BookingStatus {
  draft,
  paymentPending,
  confirmed,
}

/// 🔑 ONE AND ONLY ONE ACTIVE FLOW
enum ActiveFlow {
  booking,
  samagri,
}

class BookingSession {
  /// Active booking draft (ONLY for booking flow)
  static BookingDraft? current;

  /// Booking status
  static BookingStatus status = BookingStatus.draft;

  /// Whether samagri was chosen in booking
  static bool samagriDecisionTaken = false;

  /// 🔑 CRITICAL: which flow is currently active
  static ActiveFlow? activeFlow;

  /// Reset everything (used when switching flows)
  static void reset() {
    current = null;
    status = BookingStatus.draft;
    samagriDecisionTaken = false;
    activeFlow = null;
  }
}
