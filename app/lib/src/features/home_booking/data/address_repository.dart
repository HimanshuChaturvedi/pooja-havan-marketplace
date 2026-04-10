import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/features/home_booking/presentation/address/domain/address.dart';
import 'package:app/src/core/utils/logger.dart';

class AddressRepository {
  Future<List<Address>> getAddresses() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final List<dynamic> data = await supabase
          .from('user_addresses')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map((json) => Address(
        id: json['id'],
        phone: '', // Can be extended if needed
        line1: json['line1'],
        line2: json['line2'],
        city: json['city'],
        state: json['state'],
        pincode: json['pincode'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        isDefault: json['is_default'] ?? false,
      )).toList();
    } catch (e) {
      AppLogger.error('Error fetching addresses', e);
      return [];
    }
  }

  Future<Address> createAddress(Address address) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      final response = await supabase.from('user_addresses').insert({
        'user_id': userId,
        'line1': address.line1,
        'line2': address.line2,
        'city': address.city,
        'state': address.state,
        'pincode': address.pincode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'is_default': address.isDefault,
      }).select().single();

      return Address(
        id: response['id'],
        phone: '',
        line1: response['line1'],
        line2: response['line2'],
        city: response['city'],
        state: response['state'],
        pincode: response['pincode'],
        latitude: response['latitude'],
        longitude: response['longitude'],
        isDefault: response['is_default'] ?? false,
      );
    } catch (e) {
      AppLogger.error('Error creating address', e);
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await supabase.from('user_addresses').delete().eq('id', addressId);
    } catch (e) {
      AppLogger.error('Error deleting address', e);
      rethrow;
    }
  }
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository();
});
