import '../domain/booking_draft.dart';

class BookingSession {
  static BookingDraft? current;

  // 🔑 SAMAGRI FLOW FLAG
  static bool samagriDecisionTaken = false;
}
