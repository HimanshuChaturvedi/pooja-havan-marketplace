import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pandit_onboarding/data/pandit_repository.dart';
import '../../pandit_onboarding/domain/pandit_profile.dart';
import '../../location/state/location_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final panditRepositoryProvider = Provider<PanditRepository>((ref) {
  return PanditRepository(Supabase.instance.client);
});

final recommendationsProvider = FutureProvider.autoDispose<List<PanditProfile>>((ref) async {
  final location = ref.watch(currentLocationProvider);
  final repository = ref.read(panditRepositoryProvider);
  
  return repository.getRecommendedPandits(location.city);
});
