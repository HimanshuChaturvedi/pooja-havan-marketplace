import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/pandit_draft.dart';
import '../domain/pandit_profile.dart';
import '../../../core/utils/ritual_category_mapper.dart';
import '../../pandit_dashboard/presentation/state/pandit_time_slots_provider.dart';
import '../../../core/utils/phone_helper.dart';

class PanditRepository {
  final SupabaseClient _supabase;

  PanditRepository(this._supabase);

  Future<PanditProfile?> getPanditProfile(String userId) async {
    try {
      // First try by id (normal case)
      var response = await _supabase
          .from('pandit_profiles')
          .select('''
            *,
            pandit_service_areas(city),
            pandit_specializations(ritual_slug)
          ''')
          .eq('id', userId)
          .maybeSingle();

      // Fallback: if not found by id, try by email (handles ID mismatch after re-auth)
      if (response == null) {
        final email = _supabase.auth.currentUser?.email;
        if (email != null && email.isNotEmpty) {
          response = await _supabase
              .from('pandit_profiles')
              .select('''
                *,
                pandit_service_areas(city),
                pandit_specializations(ritual_slug)
              ''')
              .eq('email_address', email)
              .maybeSingle();
        }
      }

      if (response == null) return null;

      final cities = (response['pandit_service_areas'] as List?)
              ?.map((e) => e['city'] as String)
              .toList() ??
          [];
          
      final rituals = (response['pandit_specializations'] as List?)
              ?.map((e) => e['ritual_slug'] as String)
              .toList() ??
          [];

      return PanditProfile.fromJson(response).copyWith(
        serviceCities: cities,
        ritualSlugs: rituals,
      );
    } catch (e) {
      // Return null rather than crashing, as they might not have a profile yet
      return null;
    }
  }

  Future<void> submitPanditProfile(String userId, PanditDraft draft) async {
    String? profileUrl;
    String? aadharFrontUrl;
    String? aadharBackUrl;

    // 1. Upload Profile Photo if exists
    if (draft.profileImagePath != null) {
      final file = File(draft.profileImagePath!);
      final extension = file.path.split('.').last;
      final fileName = '$userId.${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _supabase.storage.from('profile-photos').upload(fileName, file);
      profileUrl = _supabase.storage.from('profile-photos').getPublicUrl(fileName);
    }

    // 2. Upload Aadhar Front if exists
    if (draft.aadharFrontPath != null) {
      final file = File(draft.aadharFrontPath!);
      final extension = file.path.split('.').last;
      final fileName = '$userId.aadhar_front.${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _supabase.storage.from('aadhar-copies').upload(fileName, file);
      aadharFrontUrl = _supabase.storage.from('aadhar-copies').getPublicUrl(fileName);
    }

    // 3. Upload Aadhar Back if exists
    if (draft.aadharBackPath != null) {
      final file = File(draft.aadharBackPath!);
      final extension = file.path.split('.').last;
      final fileName = '$userId.aadhar_back.${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      await _supabase.storage.from('aadhar-copies').upload(fileName, file);
      aadharBackUrl = _supabase.storage.from('aadhar-copies').getPublicUrl(fileName);
    }

    // 4. Insert Core Profile
    final String normalizedPhone;
    try {
      normalizedPhone = normalizePhoneNumber(draft.phoneNumber);
    } on FormatException catch (e) {
      throw Exception(e.message);
    }

    try {
      final existingProfile = await _supabase
          .from('pandit_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      final profileData = {
        'id': userId,
        'first_name': draft.firstName,
        'last_name': draft.lastName,
        'phone_number': normalizedPhone,
        'email_address': draft.emailAddress,
        'aadhar_number': draft.aadharNumber,
        'aadhar_front_url': aadharFrontUrl,
        'aadhar_back_url': aadharBackUrl,
        'pan_number': draft.panNumber.isEmpty ? null : draft.panNumber,
        'address_line_1': draft.addressLine1,
        'address_line_2': draft.addressLine2,
        'city': draft.city,
        'state': draft.state,
        'pin_code': draft.pinCode,
        'experience_years': draft.experienceYears,
        'bio': draft.bio,
        'profile_image_url': profileUrl,
        'verification_status': 'PENDING',
      };

      if (existingProfile == null) {
        await _supabase.from('pandit_profiles').insert(profileData);
      } else {
        await _supabase
            .from('pandit_profiles')
            .update(profileData)
            .eq('id', userId);
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505' && (e.message.contains('phone_number') || e.details.toString().contains('phone_number'))) {
        throw const PostgrestException(
          message: 'This mobile number is already registered as a Pandit.',
          code: '409',
        );
      }
      rethrow;
    }

    // 2. Insert Service Areas (Delete old ones first if any, or just insert new ones)
    if (draft.serviceCities.isNotEmpty) {
      await _supabase.from('pandit_service_areas').delete().eq('pandit_id', userId);
      final areaInserts = draft.serviceCities.map((city) => {
        'pandit_id': userId,
        'city': city,
      }).toList();
      await _supabase.from('pandit_service_areas').insert(areaInserts);
    }

    // 3. Insert Specializations
    if (draft.ritualSlugs.isNotEmpty) {
      await _supabase.from('pandit_specializations').delete().eq('pandit_id', userId);
      final specInserts = draft.ritualSlugs.map((slug) => {
        'pandit_id': userId,
        'ritual_slug': slug,
      }).toList();
      await _supabase.from('pandit_specializations').insert(specInserts);
    }
  }

  Future<List<PanditProfile>> getRecommendedPandits(String city) async {
    try {
      final response = await _supabase
          .from('pandit_profiles')
          .select('''
            *,
            pandit_service_areas!inner(city),
            pandit_specializations(ritual_slug)
          ''')
          .eq('verification_status', 'VERIFIED')
          .ilike('pandit_service_areas.city', city.trim())
          .limit(10);

      return (response as List).map((data) {
        final cities = (data['pandit_service_areas'] as List?)
                ?.map((e) => e['city'] as String)
                .toList() ?? [];
        
        final rituals = (data['pandit_specializations'] as List?)
                ?.map((e) => e['ritual_slug'] as String)
                .toList() ?? [];

        return PanditProfile.fromJson(data).copyWith(
          serviceCities: cities,
          ritualSlugs: rituals,
        );
      }).toList();
    } catch (e) {
      debugPrint('PanditRepository Recommended ERROR: $e');
      return [];
    }
  }

  Future<List<PanditProfile>> getPanditsByRitual(String ritualSlug, String city) async {
    try {
      final mappedCategory = RitualCategoryMapper.getCategoryForSlug(ritualSlug);
      debugPrint('Filtering pandits for Category: $mappedCategory, Slug: $ritualSlug, City: $city');

      // Step 1: Try exact ritual slug + city match
      var response = await _supabase
          .from('pandit_profiles')
          .select('''
            id,
            first_name,
            last_name,
            experience_years,
            profile_image_url,
            verification_status,
            pandit_specializations!inner(ritual_slug),
            pandit_service_areas!inner(city)
          ''')
          .eq('verification_status', 'VERIFIED')
          .inFilter('pandit_specializations.ritual_slug', [ritualSlug, mappedCategory])
          .ilike('pandit_service_areas.city', city.trim());

      // Step 2: Fallback — if no exact ritual match, show all verified pandits in same city
      if ((response as List).isEmpty && city.trim().isNotEmpty) {
        debugPrint('No exact ritual match. Falling back to city-only query for: $city');
        response = await _supabase
            .from('pandit_profiles')
            .select('''
              id,
              first_name,
              last_name,
              experience_years,
              profile_image_url,
              verification_status,
              pandit_specializations(ritual_slug),
              pandit_service_areas!inner(city)
            ''')
            .eq('verification_status', 'VERIFIED')
            .ilike('pandit_service_areas.city', city.trim());
      }

      return (response as List).map((data) {
        final cities = (data['pandit_service_areas'] as List?)
                ?.map((e) => e['city'] as String)
                .toList() ?? [];
        
        final rituals = (data['pandit_specializations'] as List?)
                ?.map((e) => e['ritual_slug'] as String)
                .toList() ?? [];

        return PanditProfile.fromJson(data).copyWith(
          serviceCities: cities,
          ritualSlugs: rituals,
        );
      }).toList();
    } catch (e) {
      debugPrint('PanditRepository ERROR: $e');
      return [];
    }
  }

  /// 📅 CALENDAR BLOCKED DATES SUPPORT
  Future<List<String>> getBlockedDates(String panditId) async {
    try {
      final response = await _supabase.rpc('get_pandit_blocked_dates', params: {'p_id': panditId});
      if (response != null) {
        return (response as List)
            .map((row) => row.toString())
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ RPC get_pandit_blocked_dates failed: $e');
    }

    try {
      final response = await _supabase
          .from('pandit_unavailability')
          .select('blocked_date')
          .eq('pandit_id', panditId);

      return (response as List)
          .map((row) => row['blocked_date'] as String)
          .toList();
    } catch (e) {
      debugPrint('⚠️ getBlockedDates failed (Table might not exist yet): $e');
      return [];
    }
  }

  Future<void> blockDate(String panditId, String dateStr) async {
    try {
      await _supabase.from('pandit_unavailability').insert({
        'pandit_id': panditId,
        'blocked_date': dateStr,
      });
    } catch (e) {
      debugPrint('❌ blockDate failed: $e');
      rethrow;
    }
  }

  Future<void> unblockDate(String panditId, String dateStr) async {
    try {
      await _supabase
          .from('pandit_unavailability')
          .delete()
          .eq('pandit_id', panditId)
          .eq('blocked_date', dateStr);
    } catch (e) {
      debugPrint('❌ unblockDate failed: $e');
      rethrow;
    }
  }

  /// 🕐 TIME-SLOT BASED BOOKING SUPPORT

  /// Get all booked time slots for a Pandit on a specific date
  /// Returns list of BookedSlot objects from the pandit_time_slots_provider
  Future<List<Map<String, dynamic>>> getBookedSlots(String panditId, String dateStr) async {
    try {
      // Primary: query bookings table directly for the most accurate and real-time status check
      final response = await _supabase
          .from('bookings')
          .select('selected_time, ritual_name, status')
          .eq('pandit_id', panditId)
          .gte('selected_date', '${dateStr}T00:00:00')
          .lte('selected_date', '${dateStr}T23:59:59')
          .neq('status', 'CANCELLED');

      return (response as List).map((row) => {
        'start_time': row['selected_time'] as String?,
        'end_time': '', // Calculated client-side
        'ritual_name': row['ritual_name'] ?? 'Pooja',
        'booking_status': row['status'] ?? 'PAID',
      }).toList();
    } catch (e) {
      debugPrint('⚠️ getBookedSlots direct query failed: $e. Falling back to RPC...');
      try {
        final response = await _supabase.rpc('get_pandit_booked_slots', params: {
          'p_id': panditId,
          'p_date': dateStr,
        });
        if (response != null) {
          return List<Map<String, dynamic>>.from(
            (response as List).map((row) => Map<String, dynamic>.from(row)),
          );
        }
      } catch (rpcErr) {
        debugPrint('⚠️ RPC get_pandit_booked_slots failed: $rpcErr');
      }
      return [];
    }
  }

  /// Check if a requested time conflicts with existing bookings
  /// Returns true if there IS a conflict
  Future<bool> checkTimeConflict(String panditId, String dateStr, String timeStr) async {
    try {
      final response = await _supabase.rpc('check_pandit_time_conflict', params: {
        'p_id': panditId,
        'p_date': dateStr,
        'p_time': timeStr,
      });
      return response == true;
    } catch (e) {
      debugPrint('⚠️ RPC check_pandit_time_conflict failed: $e. Using fallback...');
      try {
        final booked = await getBookedSlots(panditId, dateStr);
        final bookedSlots = booked.map((m) => BookedSlot.fromJson(m)).toList();
        return TimeSlotConfig.isSlotConflicting(timeStr, bookedSlots);
      } catch (err) {
        debugPrint('⚠️ fallback checkTimeConflict failed: $err');
        return false;
      }
    }
  }

  /// Get count of bookings for a pandit on a given date (for calendar dots)
  Future<int> getBookingCountForDate(String panditId, String dateStr) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('id')
          .eq('pandit_id', panditId)
          .gte('selected_date', '${dateStr}T00:00:00')
          .lte('selected_date', '${dateStr}T23:59:59')
          .neq('status', 'CANCELLED');
      return (response as List).length;
    } catch (e) {
      debugPrint('⚠️ getBookingCountForDate failed: $e');
      return 0;
    }
  }
}
