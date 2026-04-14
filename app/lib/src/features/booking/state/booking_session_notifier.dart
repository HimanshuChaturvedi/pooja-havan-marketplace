import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/pricing/pricing_service.dart';

enum BookingStatus {
  draft,
  paymentPending,
  confirmed,
}

enum ActiveFlow {
  booking,
  samagri,
}

class BookingSessionState {
  final BookingDraft? current;
  final BookingStatus status;
  final bool samagriDecisionTaken;
  final ActiveFlow? activeFlow;
  final String? transactionId;
  final String? bookingId;
  final String? referenceId;
  final double ritualDakshina;
  final double samagriTotal;
  final double deliveryFee;
  // platformFee is now a getter

  BookingSessionState({
    this.current,
    this.status = BookingStatus.draft,
    this.samagriDecisionTaken = false,
    this.activeFlow,
    this.transactionId,
    this.bookingId,
    this.referenceId,
    this.ritualDakshina = 0,
    this.samagriTotal = 0,
    this.deliveryFee = 0,
  });

  double get platformFee => PricingService.calculatePlatformFee(
        ritualDakshina: ritualDakshina,
        samagriTotal: samagriTotal,
      );

  double get totalAmount => PricingService.calculateTotal(
        ritualDakshina: ritualDakshina,
        samagriTotal: samagriTotal,
        deliveryFee: deliveryFee,
        platformFee: platformFee,
      );

  BookingSessionState copyWith({
    BookingDraft? current,
    BookingStatus? status,
    bool? samagriDecisionTaken,
    ActiveFlow? activeFlow,
    String? transactionId,
    String? bookingId,
    String? referenceId,
    double? ritualDakshina,
    double? samagriTotal,
    double? deliveryFee,
  }) {
    return BookingSessionState(
      current: current ?? this.current,
      status: status ?? this.status,
      samagriDecisionTaken: samagriDecisionTaken ?? this.samagriDecisionTaken,
      activeFlow: activeFlow ?? this.activeFlow,
      transactionId: transactionId ?? this.transactionId,
      bookingId: bookingId ?? this.bookingId,
      referenceId: referenceId ?? this.referenceId,
      ritualDakshina: ritualDakshina ?? this.ritualDakshina,
      samagriTotal: samagriTotal ?? this.samagriTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}

class BookingSessionNotifier extends StateNotifier<BookingSessionState> {
  BookingSessionNotifier() : super(BookingSessionState());

  void updateBookingDraft(BookingDraft draft) {
    state = state.copyWith(current: draft);
  }

  void updateStatus(BookingStatus status) {
    state = state.copyWith(status: status);
  }

  void updateBookingStatus(BookingStatus status) => updateStatus(status);

  void setSamagriDecision(bool taken) {
    state = state.copyWith(samagriDecisionTaken: taken);
  }

  void setActiveFlow(ActiveFlow flow) {
    state = state.copyWith(activeFlow: flow);
  }

  void setTransactionId(String id) {
    state = state.copyWith(transactionId: id);
  }

  void setBookingId(String id) {
    state = state.copyWith(bookingId: id);
  }

  void setReferenceId(String id) {
    state = state.copyWith(referenceId: id);
  }

  void updatePricing({
    double? ritualDakshina,
    double? samagriTotal,
    double? deliveryFee,
  }) {
    final newDakshina = ritualDakshina ?? state.ritualDakshina;
    final newSamagriTotal = samagriTotal ?? state.samagriTotal;
    final newPlatformFee = PricingService.calculatePlatformFee(
      ritualDakshina: newDakshina,
      samagriTotal: newSamagriTotal,
    );

    final updatedDraft = state.current?.copyWith(
      poojaDakshina: newDakshina,
      samagriCharges: newSamagriTotal,
      deliveryFee: deliveryFee ?? state.deliveryFee,
      platformFee: newPlatformFee,
    );

    state = state.copyWith(
      current: updatedDraft,
      ritualDakshina: newDakshina,
      samagriTotal: newSamagriTotal,
      deliveryFee: deliveryFee ?? state.deliveryFee,
    );
  }

  void reset() {
    state = BookingSessionState();
  }

  void clearIfBookingFlow() {
    if (state.activeFlow == ActiveFlow.booking) {
      reset();
    }
  }
}

final bookingSessionProvider = StateNotifierProvider<BookingSessionNotifier, BookingSessionState>((ref) {
  return BookingSessionNotifier();
});
