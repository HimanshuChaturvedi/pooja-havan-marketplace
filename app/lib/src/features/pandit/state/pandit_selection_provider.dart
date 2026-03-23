import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pandit_onboarding/data/pandit_repository_provider.dart';
import '../../pandit_onboarding/domain/pandit_profile.dart';

final panditsByRitualProvider = FutureProvider.family<List<PanditProfile>, String>((ref, ritualSlug) async {
  final repository = ref.watch(panditRepositoryProvider);
  return repository.getPanditsByRitual(ritualSlug);
});
