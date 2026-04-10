import 'samagri_item.dart';

class SamagriCartSession {
  final Map<SamagriItem, int> items;
  final String? address;
  final double? latitude;
  final double? longitude;
  
  const SamagriCartSession({
    this.items = const {},
    this.address,
    this.latitude,
    this.longitude,
  });

  double get totalAmount {
    double total = 0;
    items.forEach((item, qty) {
      total += item.price * qty;
    });
    return total;
  }

  SamagriCartSession copyWith({
    Map<SamagriItem, int>? items,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return SamagriCartSession(
      items: items ?? this.items,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
