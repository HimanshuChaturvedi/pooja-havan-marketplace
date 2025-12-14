import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'samagri_cart_session.dart';
import 'samagri_item.dart';

final samagriCartProvider =
    StateNotifierProvider<SamagriCartNotifier, SamagriCartSession>(
  (ref) => SamagriCartNotifier(),
);

class SamagriCartNotifier extends StateNotifier<SamagriCartSession> {
  SamagriCartNotifier() : super(const SamagriCartSession());

  void addItem(SamagriItem item) {
    final items = Map<SamagriItem, int>.from(state.items);

    items[item] = (items[item] ?? 0) + 1;

    state = state.copyWith(items: items);
  }

  void removeItem(SamagriItem item) {
    final items = Map<SamagriItem, int>.from(state.items);

    if (!items.containsKey(item)) return;

    if (items[item]! > 1) {
      items[item] = items[item]! - 1;
    } else {
      items.remove(item);
    }

    state = state.copyWith(items: items);
  }

  void clearCart() {
    state = const SamagriCartSession();
  }

  void setAddress(String address) {
    state = state.copyWith(address: address);
  }
}
