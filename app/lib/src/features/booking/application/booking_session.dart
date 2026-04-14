import 'package:app/src/core/pricing/pricing_service.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';

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

  // --- 💰 CENTRALIZED PRICING STATE ---
  static double ritualDakshina = 0;
  static double samagriTotal = 0;
  static double deliveryFee = 0; // Default to 0, sets to 50 if samagri used
  static double get platformFee => PricingService.calculatePlatformFee(
        ritualDakshina: ritualDakshina,
        samagriTotal: samagriTotal,
      );

  static double get totalAmount => PricingService.calculateTotal(
        ritualDakshina: ritualDakshina,
        samagriTotal: samagriTotal,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
      );

  /// 🔒 FULL RESET (USED AFTER BOOKING COMPLETION)
  static void reset() {
    current = null;
    status = BookingStatus.draft;
    samagriDecisionTaken = false;
    activeFlow = null;
    transactionId = null;
    
    // Reset pricing
    ritualDakshina = 0;
    samagriTotal = 0;
    deliveryFee = 0;
    // platformFee is a getter, no reset needed
  }

  /// ✅ SAFE AUTO-CLEAR (BOOKING FLOW ONLY)
  static void clearIfBookingFlow() {
    if (activeFlow == ActiveFlow.booking) {
      reset();
    }
  }
}
