import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../application/samagri_session.dart' show SamagriItem, SamagriOrderStatus;

class SamagriSessionState {
  final String? sessionId;
  final List<SamagriItem> items;
  final int totalAmount;
  final int deliveryFee;
  final int platformFee;
  final String vendorLabel;
  final String? addressText;
  final String? addressId;
  final bool isPartOfBooking;
  final SamagriOrderStatus status;
  final DateTime? createdAt;

  SamagriSessionState({
    this.sessionId,
    this.items = const [],
    this.totalAmount = 0,
    this.deliveryFee = 50,
    this.platformFee = 20,
    this.vendorLabel = 'Trusted Samagri Partner',
    this.addressText,
    this.addressId,
    this.isPartOfBooking = false,
    this.status = SamagriOrderStatus.draft,
    this.createdAt,
  });

  int get finalTotal => totalAmount + deliveryFee + platformFee;

  SamagriSessionState copyWith({
    String? sessionId,
    List<SamagriItem>? items,
    int? totalAmount,
    int? deliveryFee,
    int? platformFee,
    String? vendorLabel,
    String? addressText,
    String? addressId,
    bool? isPartOfBooking,
    SamagriOrderStatus? status,
    DateTime? createdAt,
  }) {
    return SamagriSessionState(
      sessionId: sessionId ?? this.sessionId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      platformFee: platformFee ?? this.platformFee,
      vendorLabel: vendorLabel ?? this.vendorLabel,
      addressText: addressText ?? this.addressText,
      addressId: addressId ?? this.addressId,
      isPartOfBooking: isPartOfBooking ?? this.isPartOfBooking,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SamagriSessionNotifier extends StateNotifier<SamagriSessionState> {
  SamagriSessionNotifier() : super(SamagriSessionState());

  void createFromCart({
    required List<SamagriItem> items,
    bool isPartOfBooking = false,
  }) {
    final total = items.fold<int>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    state = SamagriSessionState(
      sessionId: _generateSessionId(),
      items: items,
      totalAmount: total,
      isPartOfBooking: isPartOfBooking,
      status: SamagriOrderStatus.summary,
      createdAt: DateTime.now(),
    );
  }

  void attachAddress(String addressText, {String? addressId}) {
    state = state.copyWith(
      addressText: addressText,
      addressId: addressId,
    );
  }

  void updateSamagriDraft({
    required List<SamagriItem> items,
    bool isPartOfBooking = false,
  }) {
    final total = items.fold<int>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    state = state.copyWith(
      items: items,
      totalAmount: total,
      isPartOfBooking: isPartOfBooking,
    );
  }

  void markPaid() {
    state = state.copyWith(status: SamagriOrderStatus.paid);
  }

  void clear() {
    state = SamagriSessionState();
  }

  String _generateSessionId() {
    final rand = Random().nextInt(999999);
    return 'SMG-${DateTime.now().millisecondsSinceEpoch}-$rand';
  }
}

final samagriSessionProvider = StateNotifierProvider<SamagriSessionNotifier, SamagriSessionState>((ref) {
  return SamagriSessionNotifier();
});
