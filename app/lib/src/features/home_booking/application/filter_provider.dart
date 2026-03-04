import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PoojaFilter {
  withSamagri('With Samagri'),
  templeOnly('Temple Only'),
  under2000('Under ₹2000'),
  morningSlot('Morning Slot'),
  weekendAvailable('Weekend Available');

  final String label;
  const PoojaFilter(this.label);
}

class FilterNotifier extends StateNotifier<Set<PoojaFilter>> {
  FilterNotifier() : super({});

  void toggle(PoojaFilter filter) {
    if (state.contains(filter)) {
      state = state.where((f) => f != filter).toSet();
    } else {
      state = {...state, filter};
    }
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, Set<PoojaFilter>>((ref) {
  return FilterNotifier();
});
