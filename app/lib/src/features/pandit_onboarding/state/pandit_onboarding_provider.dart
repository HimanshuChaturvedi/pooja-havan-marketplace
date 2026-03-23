import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pandit_onboarding_notifier.dart';

final panditOnboardingProvider = StateNotifierProvider<PanditOnboardingNotifier, PanditOnboardingState>((ref) {
  return PanditOnboardingNotifier(ref);
});
