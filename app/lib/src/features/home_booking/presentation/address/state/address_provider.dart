import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/address.dart';
import '../application/address_controller.dart';

final addressControllerProvider = Provider<AddressController>((ref) {
  return AddressController();
});

final addressBookProvider =
    StateNotifierProvider<AddressBookNotifier, List<Address>>(
  (ref) => AddressBookNotifier(ref),
);

class AddressBookNotifier extends StateNotifier<List<Address>> {
  AddressBookNotifier(this.ref) : super([]);

  final Ref ref;

  void addAddress(Address address) {
    final controller = ref.read(addressControllerProvider);
    state = controller.addAddress(state, address);
  }

  void setDefault(String addressId) {
    final controller = ref.read(addressControllerProvider);
    state = controller.setDefault(state, addressId);
  }

  void clear() {
    state = [];
  }
}

final defaultAddressProvider = Provider<Address?>((ref) {
  final addresses = ref.watch(addressBookProvider);
  try {
    return addresses.firstWhere((a) => a.isDefault);
  } catch (_) {
    return null;
  }
});
