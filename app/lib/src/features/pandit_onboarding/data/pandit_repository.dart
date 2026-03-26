import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/pandit_draft.dart';
import '../domain/pandit_profile.dart';

class PanditRepository {
  final SupabaseClient _supabase;

  PanditRepository(this._supabase);

  Future<PanditProfile?> getPanditProfile(String userId) async {
    try {
      final response = await _supabase
          .from('pandit_profiles')
          .select('''
            *,
            pandit_service_areas(city),
            pandit_specializations(ritual_slug)
          ''')
          .eq('id', userId)
          .maybeSingle();

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
    await _supabase.from('pandit_profiles').upsert({
      'id': userId,
      'first_name': draft.firstName,
      'last_name': draft.lastName,
      'phone_number': draft.phoneNumber,
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
    });

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
      final response = await _supabase
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
}
