import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/booking_draft.dart';
import 'booking_repository.dart';
import '../../samagri_flow/application/samagri_session.dart' as session;
import '../../../core/utils/logger.dart';
import '../../samagri_flow/data/samagri_repository.dart';
import '../../samagri_flow/data/samagri_repository_provider.dart';

class BookingRepositoryImpl implements BookingRepository {
  @override
  Future<String> createBooking(BookingDraft booking, {List<session.SamagriItem>? samagriItems}) async {
    final user = supabase.auth.currentUser;
    final String? userId = user?.id;
    final String? email = user?.email;
    
    AppLogger.debug('--- BOOKING ATTEMPT ---');
    AppLogger.debug('User ID: $userId');
    AppLogger.debug('User Email: $email');
    AppLogger.debug('Is Anonymous: ${user?.isAnonymous ?? "Unknown"}');
    AppLogger.debug('-----------------------');

    if (userId == null) {
      throw Exception('Unauthenticated: No active user session found. Please log in.');
    }

    if (user!.isAnonymous || (email?.isEmpty ?? true)) {
      throw Exception('Security: Anonymous/guest users cannot create bookings. Please sign in with email.');
    }

    // Helper to ensure valid UUID or null
    String? toUuid(String? input) {
      if (input == null || input.trim().isEmpty) return null;
      final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
      return uuidRegex.hasMatch(input.trim()) ? input.trim() : null;
    }

    final rId = toUuid(booking.ritualId);
    final cId = toUuid(booking.cityId);
    final pId = toUuid(booking.panditId);

    // 1. Insert the main booking (Matching User Schema exactly)
    final response = await supabase.from('bookings').insert({
      'user_id': userId, // Scoped to verified user
      'booking_type': booking.bookingType.name.toUpperCase(),
      'ritual_id': rId,
      'ritual_name': booking.ritualName,
      'city_id': cId,
      'address': booking.address,
      'selected_date': booking.selectedDate?.toIso8601String(),
      'selected_time': booking.selectedTime,
      'samagri_required': booking.samagriRequired,
      'status': 'CREATED',
      'reference_id': _generateReferenceId(),
      'total_amount': booking.totalAmount, 
      'pooja_dakshina': booking.poojaDakshina,
      'samagri_charges': booking.samagriCharges,
      'delivery_fee': booking.deliveryFee,
      'platform_fee': booking.platformFee,
      'latitude': booking.latitude,
      'longitude': booking.longitude,
      'pandit_id': pId,
    }).select('id, reference_id').single();

    final String bookingId = response['id'].toString();
    final String? refId = response['reference_id']?.toString();
    
    // Save reference ID to session for success page display
    if (refId != null && booking.referenceId == null) {
      booking.referenceId = refId;
    }

    // 2. Insert linked samagri if any (Using samagri_orders table for consistency)
    if (samagriItems != null && samagriItems.isNotEmpty) {
      try {
        final samagriItemsTotal = samagriItems.fold<double>(0, (sum, i) => sum + (i.unitPrice * i.quantity));
        
        // FIND NEAREST VENDOR FOR LINKED ORDER
        String? matchedVendorId;
        if (booking.latitude != null && booking.longitude != null) {
          try {
            // Re-using the logic from SamagriRepository
            final samagriRepo = SupabaseSamagriRepository(); 
            matchedVendorId = await samagriRepo.findNearestVendor(booking.latitude!, booking.longitude!);
          } catch (e) {
            AppLogger.error('Failed to match vendor for linked order', e);
          }
        }

        final orderResponse = await supabase.from('samagri_orders').insert({
          'user_id': userId,
          'booking_id': bookingId,
          'vendor_id': matchedVendorId,
          'total_amount': samagriItemsTotal + 50.0,
          'delivery_fee': 50.0,
          'platform_fee': 0.0,
          'delivery_address': booking.address,
          'latitude': booking.latitude,
          'longitude': booking.longitude,
          'status': 'pending',
          'reference_id': '$refId-S',
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

    // 1. Fetch all bookings
    final bookingsResponse = await supabase
        .from('bookings')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> rawBookings = bookingsResponse != null 
        ? List<Map<String, dynamic>>.from(bookingsResponse) 
        : [];
        
    final samagriResponse = await supabase
        .from('samagri_orders')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    final List<Map<String, dynamic>> rawSamagri = samagriResponse != null
        ? List<Map<String, dynamic>>.from(samagriResponse)
        : [];

    return _mapBookings(rawBookings, rawSamagri);
  }

  @override
  Future<List<BookingDraft>> getAssignedBookings() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // 1. Fetch bookings assigned to this Pandit
    final bookingsResponse = await supabase
        .from('bookings')
        .select('*')
        .eq('pandit_id', userId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> rawBookings = bookingsResponse != null 
        ? List<Map<String, dynamic>>.from(bookingsResponse) 
        : [];
        
    // 2. Fetch all samagri orders to link them
    final samagriResponse = await supabase
        .from('samagri_orders')
        .select('*')
        .order('created_at', ascending: false);
    
    final List<Map<String, dynamic>> rawSamagri = samagriResponse != null
        ? List<Map<String, dynamic>>.from(samagriResponse)
        : [];

    return _mapBookings(rawBookings, rawSamagri, isAssignedView: true);
  }

  List<BookingDraft> _mapBookings(
    List<Map<String, dynamic>> rawBookings, 
    List<Map<String, dynamic>> rawSamagri,
    {bool isAssignedView = false}
  ) {
    final Map<String, Map<String, dynamic>> samagriByBookingId = {
      for (var s in rawSamagri) 
        if (s['booking_id'] != null)
          s['booking_id'].toString().toLowerCase().trim(): s
    };

    final List<BookingDraft> unifiedHistory = [];

    // Process Bookings (Pooja + optional Samagri)
    for (var data in rawBookings) {
      final String bid = data['id'].toString();
      final rituals = data['rituals'] as Map<String, dynamic>?;
      
      final linkedSamagri = samagriByBookingId[bid.toLowerCase().trim()];
      final double samagriTotal = (linkedSamagri?['total_amount'] ?? 0.0).toDouble();
      final bool hasSamagri = samagriTotal > 0;
      final double poojaDakshina = (data['pooja_dakshina'] ?? 0.0).toDouble();

      unifiedHistory.add(BookingDraft(
        id: bid,
        referenceId: data['reference_id']?.toString() ?? 'PHM-PENDING',
        bookingType: _parseBookingType(data['booking_type']),
        status: _parseBookingStatus(data['status']),
        ritualName: rituals?['name'] ?? data['ritual_name'] ?? 'Pooja',
        ritualId: data['ritual_id'],
        panditId: data['pandit_id'],
        city: 'Varanasi',
        cityId: data['city_id'],
        address: data['address'],
        templeName: data['temple_name'],
        templeId: data['temple_id'],
        panditName: data['pandit_name'],
        selectedDate: data['selected_date'] != null ? DateTime.parse(data['selected_date']) : null,
        selectedTime: data['selected_time'],
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        poojaDakshina: (data['pooja_dakshina'] ?? 0.0).toDouble(),
        samagriCharges: (data['samagri_charges'] ?? 0.0).toDouble(),
        deliveryFee: (data['delivery_fee'] ?? 0.0).toDouble(),
        platformFee: (data['platform_fee'] ?? 20.0).toDouble(), // Default 20 for legacy
        samagriRequired: (data['samagri_required'] == true) || hasSamagri,
      ));
    }

    // Only process standalone shop orders in the main history view
    if (!isAssignedView) {
      final Set<String> linkedBookingIds = rawBookings.map((b) => b['id'].toString()).toSet();
      for (var s in rawSamagri) {
        final String? bid = s['booking_id']?.toString().toLowerCase().trim();
        if (bid == null || !linkedBookingIds.any((id) => id.toLowerCase().trim() == bid)) {
          final createdAt = s['created_at'] != null 
              ? DateTime.parse(s['created_at']).toLocal() 
              : null;
          final timeString = createdAt != null 
              ? "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}"
              : null;

          unifiedHistory.add(BookingDraft(
             id: s['id'].toString(),
             bookingType: BookingType.shop,
             ritualName: 'Samagri Order',
             address: s['delivery_address'] ?? 'No Address',
             city: s['delivery_address']?.toString().split(',').last.trim() ?? 'Unknown City',
             samagriCharges: ((s['total_amount'] ?? 0.0).toDouble() - (s['delivery_fee'] ?? 50.0) - (s['platform_fee'] ?? 20.0)).toDouble().clamp(0.0, double.infinity),
             samagriRequired: true,
             poojaDakshina: 0.0,
             deliveryFee: (s['delivery_fee'] ?? 50.0).toDouble(),
             platformFee: (s['platform_fee'] ?? 20.0).toDouble(),
             referenceId: s['reference_id']?.toString() ?? 'PHM-PENDING',
             selectedDate: createdAt,
             selectedTime: timeString,
           ));
        }
      }
    }

    unifiedHistory.sort((a, b) => (b.selectedDate ?? DateTime(1970)).compareTo(a.selectedDate ?? DateTime(1970)));
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
 
  BookingStatusDetailed _parseBookingStatus(String? status) {
    if (status == null) return BookingStatusDetailed.created;
    final normalized = status.toLowerCase().trim().replaceAll('_', '');
    return BookingStatusDetailed.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => BookingStatusDetailed.created,
    );
  }
 
  String _generateReferenceId() {
    final year = DateTime.now().year;
    final random = (DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');
    return 'PHM-$year-$random';
  }

  String _generateSamagriReferenceId() {
    final year = DateTime.now().year;
    final random = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'PHM-SMG-$year-$random';
  }
}
