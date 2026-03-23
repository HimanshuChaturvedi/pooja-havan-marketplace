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
}
