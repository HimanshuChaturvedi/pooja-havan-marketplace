import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pandit_onboarding/data/pandit_repository_provider.dart';
import '../../pandit_onboarding/domain/pandit_profile.dart';

typedef PanditSelectionParams = ({String ritualSlug, String city});

final panditsByRitualProvider = FutureProvider.family<List<PanditProfile>, PanditSelectionParams>((ref, params) async {
  final repository = ref.watch(panditRepositoryProvider);
  return repository.getPanditsByRitual(params.ritualSlug, params.city);
});
