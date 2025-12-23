import 'dart:math';

/// Represents one Samagri item in the cart / order
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

/// Order lifecycle for Samagri
enum SamagriOrderStatus {
  draft,
  summary,
  paid,
}

/// In-memory Samagri session (Phase-2 ready)
/// Completely isolated from BookingSession
class SamagriSession {
  /// Current active session (null if none)
  static SamagriSession? current;

  final String sessionId;
  final List<SamagriItem> items;
  final int totalAmount;
  final String vendorLabel;

  /// ✅ Phase-2: Address linkage (only ID, not full object)
  final String? addressId;

  final SamagriOrderStatus status;
  final DateTime createdAt;

  SamagriSession._internal({
    required this.sessionId,
    required this.items,
    required this.totalAmount,
    required this.vendorLabel,
    required this.status,
    required this.createdAt,
    this.addressId,
  });

  /// Create a fresh Samagri session from cart items
  static void createFromCart({
    required List<SamagriItem> items,
  }) {
    final int total = items.fold(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    current = SamagriSession._internal(
      sessionId: _generateSessionId(),
      items: items,
      totalAmount: total,
      vendorLabel: 'Trusted Samagri Partner',
      addressId: null, // 🔒 Phase-2 default
      status: SamagriOrderStatus.summary,
      createdAt: DateTime.now(),
    );
  }

  /// 🔗 Phase-2: Attach selected address to session
  static void attachAddress(String addressId) {
    if (current == null) return;

    current = SamagriSession._internal(
      sessionId: current!.sessionId,
      items: current!.items,
      totalAmount: current!.totalAmount,
      vendorLabel: current!.vendorLabel,
      addressId: addressId,
      status: current!.status,
      createdAt: current!.createdAt,
    );
  }

  /// Mark order as paid (after mock payment)
  static void markPaid() {
    if (current == null) return;

    current = SamagriSession._internal(
      sessionId: current!.sessionId,
      items: current!.items,
      totalAmount: current!.totalAmount,
      vendorLabel: current!.vendorLabel,
      addressId: current!.addressId,
      status: SamagriOrderStatus.paid,
      createdAt: current!.createdAt,
    );
  }

  /// Clear session completely (after success or exit)
  static void clear() {
    current = null;
  }

  /// Simple unique id (Phase-1 & Phase-2 safe)
  static String _generateSessionId() {
    final rand = Random().nextInt(999999);
    return 'SMG-${DateTime.now().millisecondsSinceEpoch}-$rand';
  }
}
