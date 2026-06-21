import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/booking_draft.dart';
import 'booking_repository.dart';
import '../../samagri_flow/application/samagri_session.dart' as session;
import '../../../core/utils/logger.dart';
import '../../samagri_flow/data/samagri_repository.dart';
import '../../samagri_flow/data/samagri_repository_provider.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/config/whatsapp_config.dart';
import '../../../core/utils/ritual_category_mapper.dart';
import '../../../core/utils/ritual_slug_mapper.dart';
import '../../pandit_dashboard/presentation/state/pandit_time_slots_provider.dart';

class BookingRepositoryImpl implements BookingRepository {
  final WhatsAppService _whatsApp;
  
  BookingRepositoryImpl(this._whatsApp);

  @override
  Future<Map<String, String>> createBooking(BookingDraft booking, {List<session.SamagriItem>? samagriItems}) async {
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
    String? matchedVendorId;

    final bool isSamagriRequired = booking.samagriRequired || (samagriItems != null && samagriItems.isNotEmpty);

    // 🕐 TIME-SLOT CONFLICT CHECK: Prevent double booking
    if (pId != null && booking.selectedDate != null && booking.selectedTime != null) {
      try {
        final dateStr = "${booking.selectedDate!.year}-${booking.selectedDate!.month.toString().padLeft(2, '0')}-${booking.selectedDate!.day.toString().padLeft(2, '0')}";
        
        final conflictResult = await supabase.rpc('check_pandit_time_conflict', params: {
          'p_id': pId,
          'p_date': dateStr,
          'p_time': booking.selectedTime,
        });
        
        if (conflictResult == true) {
          // Fetch available slots for the error message
          final bookedSlotsResponse = await supabase.rpc('get_pandit_booked_slots', params: {
            'p_id': pId,
            'p_date': dateStr,
          });
          
          final bookedSlots = (bookedSlotsResponse as List? ?? [])
              .map((r) => BookedSlot.fromJson(Map<String, dynamic>.from(r)))
              .toList();
          final availableSlots = TimeSlotConfig.getAvailableSlots(bookedSlots);
          
          final availableStr = availableSlots.isNotEmpty 
              ? 'Available times: ${availableSlots.join(", ")}'
              : 'Pandit ji is fully booked on this date.';
          
          throw Exception(
            'Time conflict! Pandit ji already has a booking near ${booking.selectedTime} on $dateStr. $availableStr'
          );
        }
      } catch (e) {
        if (e.toString().contains('Time conflict!')) rethrow;
        AppLogger.warn('Time conflict RPC check failed: $e. Running client-side fallback check...');
        try {
          final dateStr = "${booking.selectedDate!.year}-${booking.selectedDate!.month.toString().padLeft(2, '0')}-${booking.selectedDate!.day.toString().padLeft(2, '0')}";
          
          final response = await supabase
              .from('bookings')
              .select('selected_time, ritual_name, status')
              .eq('pandit_id', pId)
              .gte('selected_date', '${dateStr}T00:00:00')
              .lte('selected_date', '${dateStr}T23:59:59')
              .neq('status', 'CANCELLED');

          final bookedSlots = (response as List? ?? []).map((row) => BookedSlot(
            startTime: row['selected_time'] as String? ?? '',
            endTime: '', // Calculated client-side
            ritualName: row['ritual_name'] ?? 'Pooja',
            status: row['status'] ?? 'PAID',
          )).toList();

          if (TimeSlotConfig.isSlotConflicting(booking.selectedTime!, bookedSlots)) {
            final availableSlots = TimeSlotConfig.getAvailableSlots(bookedSlots);
            final availableStr = availableSlots.isNotEmpty 
                ? 'Available times: ${availableSlots.join(", ")}'
                : 'Pandit ji is fully booked on this date.';
            
            throw Exception(
              'Time conflict! Pandit ji already has a booking near ${booking.selectedTime} on $dateStr. $availableStr'
            );
          }
        } catch (fallbackError) {
          if (fallbackError.toString().contains('Time conflict!')) rethrow;
          AppLogger.error('Client-side fallback conflict check also failed: $fallbackError');
        }
      }
    }

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
      'samagri_required': isSamagriRequired,
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
        if (booking.latitude != null && booking.longitude != null) {
          try {
            // Re-using the logic from SamagriRepository
            final samagriRepo = SupabaseSamagriRepository(_whatsApp); 
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

    // 3. WHATSAPP NOTIFICATIONS ARE NOW TRIGGERED AFTER PAYMENT SUCCESS
    // Removed premature call to _sendBookingNotifications

    return {
      'bookingId': bookingId,
      'referenceId': refId ?? 'PHM-PENDING',
    };
  }

  /// 🚀 INTERNAL HELPER: ORCHESTRATE NOTIFICATIONS
  Future<void> _sendBookingNotifications(
    String userId, 
    String? refId, 
    BookingDraft booking, 
    String? panditId,
    String? vendorId,
  ) async {
    AppLogger.debug('🔴 NOTIF-ORCHESTRATOR START');
    AppLogger.debug('Params: User=$userId, Pandit=$panditId, Vendor=$vendorId');
    AppLogger.debug('Ritual: ${booking.ritualName}');
    
    // Safety check: is userId null? (Shouldn't be)
    if (userId == null || userId.isEmpty) {
      AppLogger.error('NOTIF-ERROR: userId is NULL! Cannot proceed with notifications.');
      return;
    }

    final dateStr = booking.selectedDate != null 
        ? "${booking.selectedDate!.day}/${booking.selectedDate!.month}/${booking.selectedDate!.year} ${booking.selectedTime ?? ''}"
        : "TBD";

    // A. Alert the Customer
    try {
      String? customerPhone = supabase.auth.currentUser?.phone;
      
      if (customerPhone == null || customerPhone.isEmpty) {
        customerPhone = supabase.auth.currentUser?.userMetadata?['whatsapp_number'] as String?;
      }
      
      if (customerPhone == null || customerPhone.isEmpty) {
        try {
          final userResponse = await supabase.from('profiles').select('phone').eq('id', userId).maybeSingle();
          customerPhone = userResponse?['phone'];
        } catch (e) {
          AppLogger.debug('Note: Profile lookup failed (Table likely missing). Continuing...');
        }
      }
      
      if (customerPhone == null && WhatsAppConfig.useMockApi) {
        AppLogger.debug('Customer phone is NULL. Using DEV_TEST fallback for mock alerts.');
        customerPhone = '+910000000000'; 
      }

      if (customerPhone != null) {
        final String displayName = booking.samagriRequired 
            ? "${booking.ritualName} (with Samagri)" 
            : booking.ritualName;
            
        AppLogger.debug('✅ TRIGGERING Customer Conf for: $customerPhone');
        await _whatsApp.sendBookingConfirmation(customerPhone, displayName, dateStr);
        // ⏱️ Delay to allow SnackBar to be seen before next one
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        AppLogger.warn('❌ SKIPPING customer notification: No phone number available.');
      }
    } catch (e) {
      AppLogger.error('Customer Notification Logic Error', e);
    }

    // B. Alert the Pandit (if assigned)
    if (panditId != null) {
      try {
        final panditResponse = await supabase.from('pandit_profiles').select('phone_number').eq('id', panditId).maybeSingle();
        final panditPhone = panditResponse?['phone_number'];
        if (panditPhone != null) {
          AppLogger.debug('Triggering Pandit Assignment: $panditPhone');
          await _whatsApp.sendPanditAssignment(panditPhone, booking.ritualName, booking.address ?? 'Client Location', dateStr);
          await Future.delayed(const Duration(milliseconds: 1500));
        } else {
          AppLogger.warn('Skipping pandit notification: Pandit phone number not found.');
        }
      } catch (e) {
        AppLogger.error('Pandit Notification Logic Error', e);
      }
    }

    // C. Alert the Vendor (if assigned)
    if (vendorId != null) {
      try {
        final vendorResponse = await supabase.from('samagri_vendors').select('phone_number').eq('id', vendorId).maybeSingle();
        final vendorPhone = vendorResponse?['phone_number'];
        if (vendorPhone != null) {
          AppLogger.debug('Triggering Vendor Notification: $vendorPhone');
          final addressWithDetails = "${booking.address ?? 'Client Location'} (Pooja Date: $dateStr - Deliver 1 day before)";
          await _whatsApp.sendVendorNewOrder(vendorPhone, booking.ritualName, addressWithDetails, booking.samagriCharges);
        } else {
          AppLogger.warn('Skipping vendor notification: Vendor phone number not found.');
        }
      } catch (e) {
        AppLogger.error('Vendor Notification Logic Error', e);
      }
    }
  }

  @override
  Future<List<BookingDraft>> getBookings() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // 1. Fetch all bookings for this user
    final bookingsResponse = await supabase
        .from('bookings')
        .select('*')
        .eq('user_id', userId!)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> rawBookings = bookingsResponse != null 
        ? List<Map<String, dynamic>>.from(bookingsResponse) 
        : [];
        
    final samagriResponse = await supabase
        .from('samagri_orders')
        .select('*')
        .eq('user_id', userId!)
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

    // The pandit_id in bookings table is the pandit_profiles.id,
    // which may differ from auth ID (anonymous → email re-auth case).
    // So first resolve the actual profile ID.
    String panditProfileId = userId;
    try {
      var profileRow = await supabase
          .from('pandit_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      // Fallback: look up by email if id doesn't match
      if (profileRow == null) {
        final email = supabase.auth.currentUser?.email;
        if (email != null && email.isNotEmpty) {
          profileRow = await supabase
              .from('pandit_profiles')
              .select('id')
              .eq('email_address', email)
              .maybeSingle();
        }
      }

      if (profileRow != null) {
        panditProfileId = profileRow['id'] as String;
      }
    } catch (e) {
      debugPrint('getAssignedBookings: profile lookup failed: $e');
    }

    // 1. Fetch bookings assigned to this Pandit using resolved profile ID
    final bookingsResponse = await supabase
        .from('bookings')
        .select('*')
        .eq('pandit_id', panditProfileId)
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

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatusDetailed status) async {
    try {
      // PROVEN DB LABELS: CREATED, PAID, CONFIRMED, COMPLETED, CANCELLED
      String dbStatus;
      switch (status) {
        case BookingStatusDetailed.completed:
          dbStatus = 'COMPLETED';
          break;
        case BookingStatusDetailed.cancelled:
          dbStatus = 'CANCELLED';
          break;
        case BookingStatusDetailed.paid:
          dbStatus = 'PAID';
          break;
        case BookingStatusDetailed.created:
          dbStatus = 'CREATED';
          break;
        default:
          // Map all intermediate "active" states (assigned, onWay, inProgress) to CONFIRMED
          dbStatus = 'CONFIRMED';
      }

      await supabase
          .from('bookings')
          .update({'status': dbStatus})
          .eq('id', bookingId);
          
      // Trigger notifications if paid
      if (dbStatus == 'PAID') {
        try {
          final bookingData = await supabase.from('bookings').select('*').eq('id', bookingId).single();
          final samagriData = await supabase.from('samagri_orders').select('vendor_id').eq('booking_id', bookingId).maybeSingle();
          
          final dummyDraft = BookingDraft(
            ritualName: bookingData['ritual_name'] ?? 'Pooja',
            selectedDate: bookingData['selected_date'] != null ? DateTime.parse(bookingData['selected_date']) : null,
            selectedTime: bookingData['selected_time'],
            address: bookingData['address'],
            city: bookingData['city'] ?? 'Delhi',
            samagriCharges: (bookingData['samagri_charges'] ?? 0.0).toDouble(),
            bookingType: BookingType.home,
            samagriRequired: bookingData['samagri_required'] == true,
          );

          await _sendBookingNotifications(
            bookingData['user_id'],
            bookingData['reference_id'],
            dummyDraft,
            bookingData['pandit_id'],
            samagriData?['vendor_id']
          );
        } catch (e) {
          AppLogger.error('Error triggering notifications post-payment', e);
        }
      }
    } catch (e) {
      AppLogger.error('Error updating booking status', e);
      rethrow;
    }
  }

  @override
  Future<void> rejectAndReassignBooking(String bookingId, String currentPanditId) async {
    try {
      AppLogger.debug('🚨 REJECT AND REASSIGN START for Booking: $bookingId, currentPandit: $currentPanditId');
      
      // 1. Fetch booking details
      final bookingData = await supabase.from('bookings').select('*').eq('id', bookingId).single();
      final String? cityId = bookingData['city_id'];
      final String ritualName = bookingData['ritual_name'] ?? '';
      final String? ritualId = bookingData['ritual_id'];
      
      // Get city name
      String cityName = 'Delhi';
      if (cityId != null) {
        final cityResponse = await supabase.from('cities').select('name').eq('id', cityId).maybeSingle();
        cityName = cityResponse?['name'] ?? 'Delhi';
      }

      // Map ritual to category
      final ritualSlug = RitualSlugMapper.getSlug(id: ritualId, name: ritualName);
      final mappedCategory = RitualCategoryMapper.getCategoryForSlug(ritualSlug);

      AppLogger.debug('Searching fallback pandits in City: $cityName, Category: $mappedCategory');

      // 2. Fetch all verified pandits in the city who specialize in the same category
      final panditsResponse = await supabase
          .from('pandit_profiles')
          .select('''
            id,
            pandit_specializations!inner(ritual_slug),
            pandit_service_areas!inner(city)
          ''')
          .eq('verification_status', 'VERIFIED')
          .inFilter('pandit_specializations.ritual_slug', [ritualSlug, mappedCategory])
          .ilike('pandit_service_areas.city', cityName.trim());

      final List<dynamic> rawPandits = panditsResponse != null ? List<dynamic>.from(panditsResponse) : [];
      
      // Filter out the current rejecting pandit
      final candidates = rawPandits
          .map((row) => row['id'] as String)
          .where((id) => id != currentPanditId)
          .toList();

      if (candidates.isNotEmpty) {
        final nextPanditId = candidates.first;
        AppLogger.debug('Reassigning to next Pandit: $nextPanditId');
        
        await supabase
            .from('bookings')
            .update({
              'pandit_id': nextPanditId,
              'status': 'PAID', // reset status so new pandit can accept
            })
            .eq('id', bookingId);
            
        // Trigger WABA notification to the new Pandit!
        try {
          final samagriData = await supabase.from('samagri_orders').select('vendor_id').eq('booking_id', bookingId).maybeSingle();
          final dummyDraft = BookingDraft(
            ritualName: bookingData['ritual_name'] ?? 'Pooja',
            selectedDate: bookingData['selected_date'] != null ? DateTime.parse(bookingData['selected_date']) : null,
            selectedTime: bookingData['selected_time'],
            address: bookingData['address'],
            city: cityName,
            samagriCharges: (bookingData['samagri_charges'] ?? 0.0).toDouble(),
            bookingType: BookingType.home,
            samagriRequired: bookingData['samagri_required'] == true,
          );

          await _sendBookingNotifications(
            bookingData['user_id'],
            bookingData['reference_id'],
            dummyDraft,
            nextPanditId, // Alert new pandit
            samagriData?['vendor_id']
          );
        } catch (e) {
          AppLogger.error('Failed to notify reassigned pandit', e);
        }
      } else {
        AppLogger.debug('No other pandits found. Releasing pandit assignment for admin manual dispatch.');
        await supabase
            .from('bookings')
            .update({
              'pandit_id': null,
              'status': 'PAID',
            })
            .eq('id', bookingId);
      }
    } catch (e) {
      AppLogger.error('Error in rejectAndReassignBooking', e);
      rethrow;
    }
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
