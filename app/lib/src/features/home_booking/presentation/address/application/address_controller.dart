import '../domain/address.dart';

class AddressController {
  List<Address> addAddress(
    List<Address> existing,
    Address newAddress,
  ) {
    if (existing.isEmpty) {
      return [newAddress.copyWith(isDefault: true)];
    }
    return [...existing, newAddress];
  }

  List<Address> setDefault(
    List<Address> existing,
    String addressId,
  ) {
    return existing
        .map((a) => a.copyWith(isDefault: a.id == addressId))
        .toList();
  }

  Address? getDefault(List<Address> addresses) {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return null;
    }
  }
}
