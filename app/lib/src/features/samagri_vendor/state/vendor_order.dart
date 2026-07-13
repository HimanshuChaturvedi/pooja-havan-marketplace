class VendorOrder {
  final String id;
  final String? bookingId;
  final String? referenceId;
  final String deliveryAddress;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String? deliveryDate; // From joined booking
  final String? deliveryTime; // From joined booking
  final double deliveryFee; // Optional, defaults to 50 if missing
  final List<VendorOrderItem> items;
  final String? rejectReason;
  final String? rejectReasonDetails;
  final DateTime? updatedAt;

  const VendorOrder({
    required this.id,
    this.bookingId,
    this.referenceId,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveryDate,
    this.deliveryTime,
    this.deliveryFee = 50.0,
    this.items = const [],
    this.rejectReason,
    this.rejectReasonDetails,
    this.updatedAt,
  });

  factory VendorOrder.fromJson(Map<String, dynamic> json, [List<VendorOrderItem> items = const []]) {
    try {
      // Supabase might return join as a List or a Map
      final bookingRaw = json['bookings'];
      final Map<String, dynamic>? booking = (bookingRaw is List && bookingRaw.isNotEmpty) 
          ? bookingRaw.first 
          : (bookingRaw is Map<String, dynamic> ? bookingRaw : null);

      return VendorOrder(
        id: json['id']?.toString() ?? 'unknown-id',
        bookingId: json['booking_id']?.toString(),
        referenceId: json['reference_id']?.toString() ?? 'PHM-UNK',
        deliveryAddress: json['delivery_address']?.toString() ?? 'No Address',
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
        deliveryDate: booking?['selected_date']?.toString(),
        deliveryTime: booking?['selected_time']?.toString(),
        deliveryFee: (json['delivery_fee'] != null) ? (json['delivery_fee'] as num).toDouble() : 50.0,
        items: items,
        rejectReason: json['reject_reason']?.toString(),
        rejectReasonDetails: json['reject_reason_details']?.toString(),
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      );
    } catch (e) {
      // If one order fails, don't crash the list - but log it for debugging
      print('CRITICAL: Failed to parse VendorOrder ${json['reference_id']}: $e');
      rethrow; // For now rethrow so logs catch it
    }
  }
}

class VendorOrderItem {
  final String name;
  final int quantity;
  final double unitPrice;

  const VendorOrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}
