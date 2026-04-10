import 'dart:math';

class SamagriItem {
  final String itemId;
  final String name;
  final int unitPrice;
  final int quantity;

  SamagriItem({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  int get lineTotal => unitPrice * quantity;
}

enum SamagriOrderStatus {
  draft,
  summary,
  paid,
}

class SamagriSession {
  static SamagriSession? current;

  final String sessionId;
  final List<SamagriItem> items;
  final int totalAmount;
  final int deliveryFee;
  final int platformFee;
  final String vendorLabel;

  /// ✅ RAW ADDRESS TEXT
  final String? addressText;
  final String? addressId;
  final double? latitude;
  final double? longitude;

  /// ✅ VERY IMPORTANT FLAG
  /// true = booking ke saath samagri
  /// false = standalone buy samagri
  final bool isPartOfBooking;

  final SamagriOrderStatus status;
  final DateTime createdAt;

  int get finalTotal => totalAmount + deliveryFee + platformFee;

  SamagriSession._internal({
    required this.sessionId,
    required this.items,
    required this.totalAmount,
    this.deliveryFee = 50,
    this.platformFee = 20,
    required this.vendorLabel,
    required this.status,
    required this.createdAt,
    required this.isPartOfBooking,
    this.addressText,
    this.addressId,
    this.latitude,
    this.longitude,
  });

  static void createFromCart({
    required List<SamagriItem> items,
    bool isPartOfBooking = false,
  }) {
    final total = items.fold(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    current = SamagriSession._internal(
      sessionId: _generateSessionId(),
      items: items,
      totalAmount: total,
      deliveryFee: 50, // Standard centralized fee
      platformFee: 20, // Standard centralized fee
      vendorLabel: 'Trusted Samagri Store',
      addressText: null,
      addressId: null,
      latitude: null,
      longitude: null,
      status: SamagriOrderStatus.summary,
      createdAt: DateTime.now(),
      isPartOfBooking: isPartOfBooking,
    );
  }

  static void attachAddress(String addressText, {String? addressId, double? latitude, double? longitude}) {
    if (current == null) return;

    current = SamagriSession._internal(
      sessionId: current!.sessionId,
      items: current!.items,
      totalAmount: current!.totalAmount,
      deliveryFee: current!.deliveryFee,
      platformFee: current!.platformFee,
      vendorLabel: current!.vendorLabel,
      addressText: addressText,
      addressId: addressId,
      latitude: latitude,
      longitude: longitude,
      status: current!.status,
      createdAt: current!.createdAt,
      isPartOfBooking: current!.isPartOfBooking,
    );
  }

  static void markPaid() {
    if (current == null) return;

    current = SamagriSession._internal(
      sessionId: current!.sessionId,
      items: current!.items,
      totalAmount: current!.totalAmount,
      deliveryFee: current!.deliveryFee,
      platformFee: current!.platformFee,
      vendorLabel: current!.vendorLabel,
      addressText: current!.addressText,
      addressId: current!.addressId,
      latitude: current!.latitude,
      longitude: current!.longitude,
      status: SamagriOrderStatus.paid,
      createdAt: current!.createdAt,
      isPartOfBooking: current!.isPartOfBooking,
    );
  }

  static void clear() {
    current = null;
  }

  static String _generateSessionId() {
    final rand = Random().nextInt(999999);
    return 'SMG-${DateTime.now().millisecondsSinceEpoch}-$rand';
  }
}
