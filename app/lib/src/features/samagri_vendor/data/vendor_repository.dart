import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/logger.dart';
import '../state/vendor_order.dart';

abstract class SamagriVendorRepository {
  Future<List<VendorOrder>> getVendorOrders();
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> registerVendor({
    required String shopName,
    required String phoneNumber,
    required String address,
    required double latitude,
    required double longitude,
    double radius = 3.0,
  });
  Future<bool> getVendorActiveStatus();
  Future<void> updateVendorActiveStatus(bool isActive);
  Future<Map<String, dynamic>?> getVendorProfile();
  Future<List<VendorOrder>> getUnassignedOrders();
  Future<void> claimOrder(String orderId);
}

class SupabaseSamagriVendorRepository implements SamagriVendorRepository {
  @override
  Future<List<VendorOrder>> getVendorOrders() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // 1. Get ALL vendor records for this user (handles case where duplicates exist)
      final vendorsResponse = await supabase
          .from('samagri_vendors')
          .select('id')
          .eq('owner_id', userId);

      final List<dynamic> vendorDataList = vendorsResponse;
      if (vendorDataList.isEmpty) return [];
      
      final vendorIds = vendorDataList.map((v) => v['id'] as String).toList();

      final ordersResponse = await supabase
          .from('samagri_orders')
          .select('*, bookings(selected_date, selected_time), samagri_order_items(*, samagri_items(name))')
          .filter('vendor_id', 'in', '(${vendorIds.join(",")})')
          .order('created_at', ascending: false);
      
      final List<dynamic> ordersData = ordersResponse;
      AppLogger.debug('RAW ORDERS FETCHED: ${ordersData.length}');
      for (var d in ordersData) {
        AppLogger.debug('Order in response: ${d['reference_id']}, booking_id: ${d['booking_id']}');
      }

      return ordersData.map((data) {
        try {
          final List<dynamic> itemsData = data['samagri_order_items'] ?? [];
          final items = itemsData.map((i) => VendorOrderItem(
            name: i['samagri_items']?['name'] ?? 'Unknown Item',
            quantity: i['quantity'] ?? 1,
            unitPrice: (i['unit_price'] as num?)?.toDouble() ?? 0.0,
          )).toList();

          return VendorOrder.fromJson(data, items);
        } catch (e) {
          AppLogger.error('Failed to map order: ${data['reference_id']}', e);
          return null;
        }
      }).whereType<VendorOrder>().toList();
    } catch (e) {
      AppLogger.error('Error fetching vendor orders', e);
      return [];
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await supabase
          .from('samagri_orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      AppLogger.error('Error updating vendor order status', e);
      rethrow;
    }
  }

  @override
  Future<void> registerVendor({
    required String shopName,
    required String phoneNumber,
    required String address,
    required double latitude,
    required double longitude,
    double radius = 3.0,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      await supabase.from('samagri_vendors').upsert({
        'owner_id': userId,
        'shop_name': shopName,
        'phone_number': phoneNumber,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'delivery_radius_km': radius,
        'verification_status': 'PENDING',
      }, onConflict: 'owner_id');
    } catch (e) {
      AppLogger.error('Error registering vendor', e);
      rethrow;
    }
  }

  @override
  Future<bool> getVendorActiveStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final response = await supabase
          .from('samagri_vendors')
          .select('is_active')
          .eq('owner_id', userId)
          .maybeSingle();
      
      return response?['is_active'] ?? false;
    } catch (e) {
      AppLogger.error('Error fetching vendor active status', e);
      return false;
    }
  }

  @override
  Future<void> updateVendorActiveStatus(bool isActive) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase
          .from('samagri_vendors')
          .update({'is_active': isActive})
          .eq('owner_id', userId);
    } catch (e) {
      AppLogger.error('Error updating vendor active status', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getVendorProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await supabase
          .from('samagri_vendors')
          .select('*')
          .eq('owner_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      AppLogger.error('Error fetching vendor profile', e);
      return null;
    }
  }

  @override
  Future<List<VendorOrder>> getUnassignedOrders() async {
    try {
      final ordersResponse = await supabase
          .from('samagri_orders')
          .select('*, bookings(selected_date, selected_time), samagri_order_items(*, samagri_items(name))')
          .filter('vendor_id', 'is', 'null')
          .order('created_at', ascending: false)
          .limit(10);

      final List<dynamic> ordersData = ordersResponse;
      
      return ordersData.map((data) {
        final List<dynamic> itemsData = data['samagri_order_items'] ?? [];
        final items = itemsData.map((i) => VendorOrderItem(
          name: i['samagri_items']?['name'] ?? 'Unknown Item',
          quantity: i['quantity'] ?? 1,
          unitPrice: (i['unit_price'] as num).toDouble(),
        )).toList();

        return VendorOrder.fromJson(data, items);
      }).toList();
    } catch (e) {
      AppLogger.error('Error fetching unassigned orders', e);
      return [];
    }
  }

  @override
  Future<void> claimOrder(String orderId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      // 1. Get the vendor's ID for this user
      final vendorProfile = await getVendorProfile();
      if (vendorProfile == null) throw Exception('Vendor profile not found');
      final vendorId = vendorProfile['id'];

      // 2. Claim the order by setting vendor_id and status to 'accepted'
      await supabase
          .from('samagri_orders')
          .update({
            'vendor_id': vendorId,
            'status': 'accepted'
          })
          .eq('id', orderId)
          .filter('vendor_id', 'is', 'null'); // Safety check to ensure it's still unassigned
    } catch (e) {
      AppLogger.error('Error claiming order', e);
      rethrow;
    }
  }
}

final samagriVendorRepositoryProvider = Provider<SamagriVendorRepository>((ref) {
  return SupabaseSamagriVendorRepository();
});

final vendorOrdersProvider = FutureProvider.autoDispose<List<VendorOrder>>((ref) async {
  final repo = ref.watch(samagriVendorRepositoryProvider);
  return repo.getVendorOrders();
});

final vendorActiveStatusProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(samagriVendorRepositoryProvider);
  return repo.getVendorActiveStatus();
});

final vendorProfileFutureProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(samagriVendorRepositoryProvider);
  return repo.getVendorProfile();
});

final unassignedOrdersProvider = FutureProvider.autoDispose<List<VendorOrder>>((ref) async {
  final repo = ref.watch(samagriVendorRepositoryProvider);
  return repo.getUnassignedOrders();
});
