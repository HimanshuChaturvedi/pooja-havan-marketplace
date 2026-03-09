import '../../../core/supabase/supabase_client.dart';
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
  });
}

class SupabaseSamagriRepository implements SamagriRepository {
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
  }) async {
    try {
      // 1. Create the order
      final orderResponse = await supabase.from('samagri_orders').insert({
        'user_id': supabase.auth.currentUser?.id,
        'booking_id': bookingId,
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'status': 'pending',
      }).select('id').single();

      final orderId = orderResponse['id'];

      // 2. Create order items (Using samagri_item_id and unit_price as per corrected schema)
      final List<Map<String, dynamic>> itemsToInsert = items.map((item) => {
        'order_id': orderId,
        'samagri_item_id': item.itemId,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      }).toList();

      await supabase.from('samagri_order_items').insert(itemsToInsert);

      return orderId.toString();
    } catch (e) {
      AppLogger.error('Error creating samagri order', e);
      rethrow;
    }
  }
}
