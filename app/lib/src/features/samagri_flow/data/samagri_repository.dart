import '../../../core/supabase/supabase_client.dart';
import '../../../core/config/whatsapp_config.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../booking/domain/booking_draft.dart';
import '../application/samagri_session.dart' as session;
import '../state/samagri_item.dart';
import '../../../core/utils/logger.dart';

abstract class SamagriRepository {
  Future<List<SamagriItem>> getItems();
  Future<String> createOrder({
    required List<session.SamagriItem> items,
    required double totalAmount,
    String? bookingId,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
    String? referenceId,
    double? deliveryFee,
    double? platformFee,
  });
  Future<String?> findNearestVendor(double? lat, double? lon);
}

class SupabaseSamagriRepository implements SamagriRepository {
  final WhatsAppService _whatsApp;
  SupabaseSamagriRepository(this._whatsApp);

  @override
  Future<List<SamagriItem>> getItems() async {
    try {
      final List<dynamic> data = await supabase
          .from('samagri_items')
          .select('*');

      return data.map((json) => SamagriItem(
        id: json['id'],
        name: json['name'],
        price: ((json['base_price'] ?? json['price'] ?? 0.0) as num).toDouble(),
        categoryId: json['category'] ?? 'General',
      )).toList();
    } catch (e) {
      AppLogger.error('Error fetching samagri items', e);
      return [];
    }
  }

  @override
  Future<String> createOrder({
    required List<session.SamagriItem> items,
    required double totalAmount,
    String? bookingId,
    String? deliveryAddress,
    double? latitude,
    double? longitude,
    String? referenceId,
    double? deliveryFee,
    double? platformFee,
  }) async {
    final user = supabase.auth.currentUser;
    final String? userId = user?.id;
    final String? email = user?.email;

    AppLogger.debug('--- SAMAGRI ORDER ATTEMPT ---');
    AppLogger.debug('User ID: $userId');
    AppLogger.debug('User Email: $email');
    AppLogger.debug('----------------------------');

    if (userId == null) {
      throw Exception('Unauthenticated: User must be logged in to order Samagri.');
    }

    if (user!.isAnonymous || (email?.isEmpty ?? true)) {
      throw Exception('Security: Anonymous/guest users cannot order Samagri. Please sign in with email.');
    }

    try {
      // Match nearest vendor if coordinates are available (Ghaziabad Center fallback)
      final matchedVendorId = await findNearestVendor(
        latitude ?? 28.6692, 
        longitude ?? 77.4538,
      );

      // 1. Create the order
      final orderResponse = await supabase.from('samagri_orders').insert({
        'user_id': userId,
        'booking_id': bookingId,
        'vendor_id': matchedVendorId,
        'total_amount': totalAmount,
        'delivery_fee': deliveryFee ?? 50.0,
        'platform_fee': platformFee ?? 20.0,
        'delivery_address': deliveryAddress,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        'reference_id': referenceId ?? _generateReferenceId(),
      }).select('id').single();

      final orderId = orderResponse['id'];
      AppLogger.debug('Order created with ID: $orderId');

      // 2. Create order items 
      final List<Map<String, dynamic>> itemsToInsert = items.map((item) {
        AppLogger.debug('Mapping Item: ${item.name} (UUID: ${item.itemId})');
        return {
          'order_id': orderId,
          'samagri_item_id': item.itemId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
        };
      }).toList();

      AppLogger.debug('Inserting ${itemsToInsert.length} items into samagri_order_items');
      await supabase.from('samagri_order_items').insert(itemsToInsert);
      AppLogger.debug('Successfully inserted items.');

      // 3. Trigger Notifications (Async)
      _sendSamagriNotifications(userId, orderId.toString(), referenceId ?? 'PHM-SMG-TBD', totalAmount, matchedVendorId);

      return orderId.toString();
    } catch (e) {
      AppLogger.error('Error creating samagri order', e);
      rethrow;
    }
  }

  /// 🚀 INTERNAL HELPER: ORCHESTRATE SAMAGRI NOTIFICATIONS
  Future<void> _sendSamagriNotifications(
    String userId, 
    String orderId, 
    String refId, 
    double amount, 
    String? vendorId
  ) async {
    try {
      AppLogger.debug('ORCHESTRATING Samagri Notifs: User=$userId, Vendor=$vendorId');

      // A. Alert the Customer
      String? customerPhone = supabase.auth.currentUser?.phone;
      if (customerPhone == null) {
        try {
          final userResponse = await supabase.from('profiles').select('phone').eq('id', userId).maybeSingle();
          customerPhone = userResponse?['phone'];
        } catch (e) {
          AppLogger.debug('Note: Profile lookup failed for Samagri order. Using mock fallback.');
        }
      }

      if (customerPhone == null && WhatsAppConfig.useMockApi) {
        customerPhone = '+910000000000';
      }

      if (customerPhone != null) {
        AppLogger.debug('Triggering Samagri Confirmation: $customerPhone');
        await _whatsApp.sendSamagriOrderConfirmation(customerPhone, refId, amount);
        // Sequential Delay
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // B. Alert the Vendor
      if (vendorId != null) {
        try {
          final vendorResponse = await supabase.from('samagri_vendors').select('phone_number').eq('id', vendorId).maybeSingle();
          final vendorPhone = vendorResponse?['phone_number'];
          if (vendorPhone != null) {
            AppLogger.debug('Triggering Vendor Notification (Samagri): $vendorPhone');
            await _whatsApp.sendVendorNewOrder(vendorPhone, 'Standalone Samagri Order', 'See Order Details', amount);
          }
        } catch (e) {
          AppLogger.error('Vendor Notification Error (Samagri)', e);
        }
      }
    } catch (e) {
      AppLogger.error('FAILED to complete Samagri notifications', e);
    }
  }
 
  @override
  Future<String?> findNearestVendor(double? lat, double? lon) async {
    try {
      final List<dynamic> result = await supabase.rpc(
        'find_nearest_samagri_vendor',
        params: {
          'user_lat': lat ?? 28.6692,
          'user_lon': lon ?? 77.4538,
        },
      );

      if (result.isNotEmpty) {
        return result.first['vendor_id'] as String?;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error finding nearest vendor', e);
      return null;
    }
  }

  String _generateReferenceId() {
    final year = DateTime.now().year;
    final random = (DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return 'PHM-SMG-$year-$random';
  }
}
