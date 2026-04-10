import 'package:supabase_flutter/supabase_flutter.dart';
import '../../pandit_onboarding/domain/pandit_profile.dart';

class AdminRepository {
  final SupabaseClient _supabase;

  AdminRepository(this._supabase);

  Future<List<PanditProfile>> fetchPendingPandits() async {
    final response = await _supabase
        .from('pandit_profiles')
        .select()
        .eq('verification_status', 'PENDING')
        .order('created_at', ascending: true);

    return (response as List).map((json) => PanditProfile.fromJson(json)).toList();
  }

  Future<void> updateStatus(String id, PanditVerificationStatus status) async {
    final statusStr = status.name.toUpperCase();
    await _supabase
        .from('pandit_profiles')
        .update({'verification_status': statusStr})
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchPendingVendors() async {
    final response = await _supabase
        .from('samagri_vendors')
        .select()
        .eq('verification_status', 'PENDING')
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchAllVendors() async {
    final response = await _supabase
        .from('samagri_vendors')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateVendorStatus(String id, String status) async {
    await _supabase
        .from('samagri_vendors')
        .update({'verification_status': status.toUpperCase()})
        .eq('id', id);
  }
}
