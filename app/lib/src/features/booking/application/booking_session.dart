import '../domain/booking_draft.dart';

enum BookingStatus {
  draft,
  paymentPending,
  confirmed,
}

enum ActiveFlow {
  booking,
  samagri,
}

class BookingSession {
  static BookingDraft? current;

  static BookingStatus status = BookingStatus.draft;

  static bool samagriDecisionTaken = false;

  static ActiveFlow? activeFlow;

  /// 🔑 STABLE TRANSACTION ID (CRITICAL)
  static String? transactionId;

  /// 🔒 FULL RESET (USED AFTER BOOKING COMPLETION)
  static void reset() {
    current = null;
    status = BookingStatus.draft;
    samagriDecisionTaken = false;
    activeFlow = null;
    transactionId = null;
  }

  /// ✅ SAFE AUTO-CLEAR (BOOKING FLOW ONLY)
  static void clearIfBookingFlow() {
    if (activeFlow == ActiveFlow.booking) {
      reset();
    }
  }
}
