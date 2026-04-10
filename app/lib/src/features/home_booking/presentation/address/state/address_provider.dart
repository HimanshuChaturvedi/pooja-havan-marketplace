import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/src/features/home_booking/presentation/address/domain/address.dart';
import 'package:app/src/features/home_booking/presentation/address/application/address_controller.dart';
import 'package:app/src/features/home_booking/data/address_repository.dart';

final addressControllerProvider = Provider<AddressController>((ref) {
  return AddressController();
});

final addressBookProvider =
    StateNotifierProvider<AddressBookNotifier, List<Address>>(
  (ref) {
    final notifier = AddressBookNotifier(ref);
    notifier.loadAddresses(); // Auto-load on init
    return notifier;
  },
);

class AddressBookNotifier extends StateNotifier<List<Address>> {
  AddressBookNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> loadAddresses() async {
    final repo = ref.read(addressRepositoryProvider);
    final addresses = await repo.getAddresses();
    state = addresses;
  }

  Future<void> addAddress(Address address) async {
    final repo = ref.read(addressRepositoryProvider);
    try {
      final savedAddress = await repo.createAddress(address);
      state = [...state, savedAddress];
    } catch (e) {
      // Logic for fallback or error handling
    }
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
