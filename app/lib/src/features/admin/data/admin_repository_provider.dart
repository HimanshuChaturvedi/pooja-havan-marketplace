import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

final pendingPanditsProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchPendingPandits();
});

final allPanditsProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchAllPandits();
});

final pendingVendorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchPendingVendors();
});

final allVendorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchAllVendors();
});
