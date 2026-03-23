import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import 'pandit_repository.dart';
import '../domain/pandit_profile.dart';

final panditRepositoryProvider = Provider<PanditRepository>((ref) {
  return PanditRepository(supabase);
});

final panditProfileFutureProvider = FutureProvider.family<PanditProfile?, String>((ref, userId) async {
  final repo = ref.read(panditRepositoryProvider);
  return await repo.getPanditProfile(userId);
});
