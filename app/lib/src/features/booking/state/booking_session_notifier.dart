import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/booking_draft.dart';
import '../../../core/pricing/pricing_service.dart';

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
  final double ritualDakshina;
  final double samagriTotal;
  final double deliveryFee;
  final double platformFee;

  BookingSessionState({
    this.current,
    this.status = BookingStatus.draft,
    this.samagriDecisionTaken = false,
    this.activeFlow,
    this.transactionId,
    this.ritualDakshina = 0,
    this.samagriTotal = 0,
    this.deliveryFee = 0,
    this.platformFee = 20,
  });

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
    double? ritualDakshina,
    double? samagriTotal,
    double? deliveryFee,
    double? platformFee,
  }) {
    return BookingSessionState(
      current: current ?? this.current,
      status: status ?? this.status,
      samagriDecisionTaken: samagriDecisionTaken ?? this.samagriDecisionTaken,
      activeFlow: activeFlow ?? this.activeFlow,
      transactionId: transactionId ?? this.transactionId,
      ritualDakshina: ritualDakshina ?? this.ritualDakshina,
      samagriTotal: samagriTotal ?? this.samagriTotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      platformFee: platformFee ?? this.platformFee,
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

  void updatePricing({
    double? ritualDakshina,
    double? samagriTotal,
    double? deliveryFee,
    double? platformFee,
  }) {
    final updatedDraft = state.current?.copyWith(
      poojaDakshina: ritualDakshina ?? state.ritualDakshina,
      samagriCharges: samagriTotal ?? state.samagriTotal,
      deliveryFee: deliveryFee ?? state.deliveryFee,
      platformFee: platformFee ?? state.platformFee,
    );

    state = state.copyWith(
      current: updatedDraft,
      ritualDakshina: ritualDakshina,
      samagriTotal: samagriTotal,
      deliveryFee: deliveryFee,
      platformFee: platformFee,
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
