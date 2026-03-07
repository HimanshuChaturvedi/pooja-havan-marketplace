import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'temple_repository.dart';
import 'temple_data.dart';

final templeRepositoryProvider = Provider<TempleRepository>((ref) {
  return SupabaseTempleRepository();
});

final citiesProvider = FutureProvider<List<CityConfig>>((ref) async {
  final repository = ref.watch(templeRepositoryProvider);
  return repository.getCities();
});

final templesInCityProvider = FutureProvider.family<List<TempleModel>, String>((ref, cityId) async {
  final repository = ref.watch(templeRepositoryProvider);
  return repository.getTemples(cityId);
});
