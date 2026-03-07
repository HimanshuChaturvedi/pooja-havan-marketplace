import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ritual_repository.dart';

final ritualRepositoryProvider = Provider<RitualRepository>((ref) {
  return SupabaseRitualRepository();
});

final ritualsProvider = FutureProvider<List<Ritual>>((ref) async {
  final repository = ref.watch(ritualRepositoryProvider);
  return repository.getRituals();
});

final ritualPricingProvider = FutureProvider.family<Map<String, double>, PricingParams>((ref, params) async {
  final repository = ref.watch(ritualRepositoryProvider);
  return repository.getRitualPricing(params);
});

final ritualByIdProvider = FutureProvider.family<Ritual?, String>((ref, id) async {
  final repository = ref.watch(ritualRepositoryProvider);
  return repository.getRitualById(id);
});
