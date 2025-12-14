import 'samagri_item.dart';

class SamagriCartSession {
  final Map<SamagriItem, int> items;
  final String? address;

  const SamagriCartSession({
    this.items = const {},
    this.address,
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
  }) {
    return SamagriCartSession(
      items: items ?? this.items,
      address: address ?? this.address,
    );
  }
}
