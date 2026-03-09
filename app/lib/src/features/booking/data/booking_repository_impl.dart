import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/booking_draft.dart';
import 'booking_repository.dart';
import '../../samagri_flow/application/samagri_session.dart' as session;
import '../application/booking_session.dart';
import '../../../core/utils/logger.dart';

class BookingRepositoryImpl implements BookingRepository {
  @override
  Future<String> createBooking(BookingDraft booking, {List<session.SamagriItem>? samagriItems}) async {
    // 1. Insert the main booking (Matching User Schema exactly)
    final response = await supabase.from('bookings').insert({
      'user_id': supabase.auth.currentUser?.id, // 🚀 NEW: Scoped to anonymous user
      'booking_type': booking.bookingType.name.toUpperCase(),
      'ritual_id': booking.ritualId,
      'ritual_name': booking.ritualName,
      'city_id': booking.cityId,
      'address': booking.address,
      'selected_date': booking.selectedDate?.toIso8601String(),
      'selected_time': booking.selectedTime,
      'samagri_required': booking.samagriRequired,
      'status': 'CREATED',
      // ✅ FIX: Save total amount for My Bookings display
      'total_amount': BookingSession.totalAmount,
    }).select('id').single();

    final String bookingId = response['id'].toString();

    // 2. Insert linked samagri if any (Using samagri_orders table for consistency)
    if (samagriItems != null && samagriItems.isNotEmpty) {
      try {
        final samagriItemsTotal = samagriItems.fold<double>(0, (sum, i) => sum + (i.unitPrice * i.quantity));
        final orderResponse = await supabase.from('samagri_orders').insert({
          'user_id': supabase.auth.currentUser?.id,
          'booking_id': bookingId,
          'total_amount': samagriItemsTotal,  // actual items total from cart
          'delivery_address': booking.address,
          'status': 'pending',
        }).select('id').single();

        final orderId = orderResponse['id'];

        final List<Map<String, dynamic>> samagriData = samagriItems.map((item) => {
          'order_id': orderId,
          'samagri_item_id': item.itemId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
        }).toList();

        await supabase.from('samagri_order_items').insert(samagriData);
      } catch (e) {
        // Log error but don't fail the entire booking if samagri order fails
        AppLogger.error('Error creating samagri order for booking', e);
      }
    }

    return bookingId;
  }

  @override
  Future<List<BookingDraft>> getBookings() async {
    final String? userId = supabase.auth.currentUser?.id;
    // 🚀 REMOVED: if (userId == null) return []; 
    // This was blocking history for users not logged into Supabase Auth.

    // 1. Fetch all bookings
    // We now fetch EVERYTHING because RLS filters by auth.uid() = user_id automatically
    final bookingsResponse = await supabase
        .from('bookings')
        .select('*')
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> rawBookings = bookingsResponse != null 
        ? List<Map<String, dynamic>>.from(bookingsResponse) 
        : [];
        
    AppLogger.debug('Fetched ${rawBookings.length} bookings for user: $userId');

    final samagriResponse = await supabase
        .from('samagri_orders')
        .select('*')
        .order('created_at', ascending: false);
    
    final List<Map<String, dynamic>> rawSamagri = samagriResponse != null
        ? List<Map<String, dynamic>>.from(samagriResponse)
        : [];

    AppLogger.debug('Fetched ${rawSamagri.length} samagri orders');

    final Map<String, Map<String, dynamic>> samagriByBookingId = {
      for (var s in rawSamagri) 
        if (s['booking_id'] != null)
          s['booking_id'].toString().toLowerCase().trim(): s
    };

    final List<BookingDraft> unifiedHistory = [];

    // 4. Process Bookings (Pooja + optional Samagri)
    for (var data in rawBookings) {
      final String bid = data['id'].toString();
      final rituals = data['rituals'] as Map<String, dynamic>?;
      
      // Look for linked samagri order (Case-insensitive match)
      final linkedSamagri = samagriByBookingId[bid.toLowerCase().trim()];
      final double samagriTotal = (linkedSamagri?['total_amount'] ?? 0.0).toDouble();
      final bool hasSamagri = samagriTotal > 0;
      
      final double poojaDakshina = (data['pooja_dakshina'] ?? 0.0).toDouble();

      unifiedHistory.add(BookingDraft(
        id: bid,
        bookingType: _parseBookingType(data['booking_type']),
        ritualName: rituals?['name'] ?? data['ritual_name'] ?? 'Pooja',
        ritualId: data['ritual_id'],
        city: 'Varanasi', // Placeholder or add city_name to join
        cityId: data['city_id'],
        address: data['address'],
        templeName: data['temple_name'],
        templeId: data['temple_id'],
        panditName: data['pandit_name'],
        selectedDate: data['selected_date'] != null ? DateTime.parse(data['selected_date']) : null,
        selectedTime: data['selected_time'],
        // 🚀 FIX: Use pooja_dakshina from DB. If no samagri linked, add standard fees.
        // 🚀 FIX: Separate fees from total_amount so they don't merge into Dakshina
        poojaDakshina: (data['total_amount'] ?? 0.0) > 0 
           ? ((data['total_amount'] as num).toDouble() - samagriTotal - 70.0).clamp(0.0, double.infinity)
           : poojaDakshina,
        samagriCharges: samagriTotal,
        samagriRequired: (data['samagri_required'] == true) || hasSamagri,
        // 🚀 BUG FIX: Delivery Fee ONLY if hasSamagri
        deliveryFee: hasSamagri ? 50.0 : 0.0,
        platformFee: 20.0,
      ));
    }

    // 5. Process Standalone Samagri Orders
    final Set<String> linkedBookingIds = rawBookings.map((b) => b['id'].toString()).toSet();
    
    for (var s in rawSamagri) {
      final String? bid = s['booking_id']?.toString().toLowerCase().trim();
      // If NOT linked to any booking FETCHED above, it's a standalone shop order
      if (bid == null || !linkedBookingIds.any((id) => id.toLowerCase().trim() == bid)) {
        // 🚀 FIX: Use .toLocal() so IST time is shown, not UTC
        final createdAt = s['created_at'] != null 
            ? DateTime.parse(s['created_at']).toLocal() 
            : null;
            
        final timeString = createdAt != null 
            ? "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}"
            : null;

        unifiedHistory.add(BookingDraft(
           id: s['id'].toString(),
           bookingType: BookingType.shop, // Representing Shop Order
           ritualName: 'Samagri Order',
           address: s['delivery_address'],
           city: 'Varanasi',
           // 🚀 FIX: Separate fees (70) from total so Detail Page shows breakdown
           samagriCharges: ((s['total_amount'] ?? 0.0).toDouble() - 70.0).clamp(0.0, double.infinity),
           samagriRequired: true,
           poojaDakshina: 0.0,
           deliveryFee: 50.0, 
           platformFee: 20.0,
           selectedDate: createdAt,
           selectedTime: timeString,
         ));
      }
    }

    // Sort again by date (since we merged)
    unifiedHistory.sort((a, b) => (b.selectedDate ?? DateTime(0)).compareTo(a.selectedDate ?? DateTime(0)));

    return unifiedHistory;
  }

  BookingType _parseBookingType(String? type) {
    if (type == null) return BookingType.home;
    final normalized = type.toLowerCase().trim();
    return BookingType.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => BookingType.home,
    );
  }
}
