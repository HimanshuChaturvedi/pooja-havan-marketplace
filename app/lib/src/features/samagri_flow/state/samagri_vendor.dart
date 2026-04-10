class SamagriVendor {
  final String id;
  final String ownerId;
  final String shopName;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final double deliveryRadiusKm;
  final bool isActive;
  final String verificationStatus;

  const SamagriVendor({
    required this.id,
    required this.ownerId,
    required this.shopName,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.deliveryRadiusKm,
    required this.isActive,
    required this.verificationStatus,
  });

  factory SamagriVendor.fromJson(Map<String, dynamic> json) {
    return SamagriVendor(
      id: json['id'],
      ownerId: json['owner_id'],
      shopName: json['shop_name'],
      phoneNumber: json['phone_number'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      deliveryRadiusKm: (json['delivery_radius_km'] as num).toDouble(),
      isActive: json['is_active'] ?? true,
      verificationStatus: json['verification_status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'shop_name': shopName,
      'phone_number': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_radius_km': deliveryRadiusKm,
      'is_active': isActive,
      'verification_status': verificationStatus,
    };
  }
}
