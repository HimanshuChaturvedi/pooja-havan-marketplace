import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

final pendingPanditsProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchPendingPandits();
});
