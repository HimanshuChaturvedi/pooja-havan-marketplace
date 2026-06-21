import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pandit_onboarding/data/pandit_repository_provider.dart';

final panditBlockedDatesProvider = StateNotifierProvider.family<PanditAvailabilityNotifier, AsyncValue<List<String>>, String>((ref, panditId) {
  final repository = ref.read(panditRepositoryProvider);
  return PanditAvailabilityNotifier(repository, panditId);
});

class PanditAvailabilityNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final dynamic _repository;
  final String _panditId;

  PanditAvailabilityNotifier(this._repository, this._panditId) : super(const AsyncValue.loading()) {
    loadBlockedDates();
  }

  Future<void> loadBlockedDates() async {
    try {
      final dates = await _repository.getBlockedDates(_panditId);
      state = AsyncValue.data(List<String>.from(dates));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleDate(String dateStr) async {
    final currentDates = state.value ?? [];
    final isBlocked = currentDates.contains(dateStr);
    
    // Optimistic Update: Refresh UI instantly
    final newDates = List<String>.from(currentDates);
    if (isBlocked) {
      newDates.remove(dateStr);
    } else {
      newDates.add(dateStr);
    }
    state = AsyncValue.data(newDates);

    try {
      if (isBlocked) {
        await _repository.unblockDate(_panditId, dateStr);
      } else {
        await _repository.blockDate(_panditId, dateStr);
      }
    } catch (e) {
      // Revert state on error
      state = AsyncValue.data(currentDates);
      rethrow;
    }
  }
}
