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
  final String vendorLabel;

  /// ✅ RAW ADDRESS TEXT
  final String? addressText;
  final String? addressId;

  /// ✅ VERY IMPORTANT FLAG
  /// true = booking ke saath samagri
  /// false = standalone buy samagri
  final bool isPartOfBooking;

  final SamagriOrderStatus status;
  final DateTime createdAt;

  SamagriSession._internal({
    required this.sessionId,
    required this.items,
    required this.totalAmount,
    required this.vendorLabel,
    required this.status,
    required this.createdAt,
    required this.isPartOfBooking,
    this.addressText,
    this.addressId,
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
      vendorLabel: 'Trusted Samagri Partner',
      addressText: null,
      addressId: null,
      status: SamagriOrderStatus.summary,
      createdAt: DateTime.now(),
      isPartOfBooking: isPartOfBooking,
    );
  }

  static void attachAddress(String addressText, {String? addressId}) {
    if (current == null) return;

    current = SamagriSession._internal(
      sessionId: current!.sessionId,
      items: current!.items,
      totalAmount: current!.totalAmount,
      vendorLabel: current!.vendorLabel,
      addressText: addressText,
      addressId: addressId,
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
      vendorLabel: current!.vendorLabel,
      addressText: current!.addressText,
      addressId: current!.addressId,
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
