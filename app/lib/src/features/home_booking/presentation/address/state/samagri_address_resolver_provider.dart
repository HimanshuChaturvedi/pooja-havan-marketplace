import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../samagri_flow/application/samagri_session.dart';
import '../domain/address.dart';
import 'address_provider.dart';

/// Resolves address attached to SamagriSession (read-only)
final samagriAddressProvider = Provider<Address?>((ref) {
  final session = SamagriSession.current;

  if (session == null || session.addressId == null) {
    return null;
  }

  final addresses = ref.watch(addressBookProvider);

  try {
    return addresses.firstWhere(
      (a) => a.id == session.addressId,
    );
  } catch (_) {
    return null;
  }
});
