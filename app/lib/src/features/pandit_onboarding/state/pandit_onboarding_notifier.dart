import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pandit_draft.dart';
import '../data/pandit_repository_provider.dart';

class PanditOnboardingState {
  final PanditDraft draft;
  final bool isSubmitting;
  final String? error;

  const PanditOnboardingState({
    this.draft = const PanditDraft(),
    this.isSubmitting = false,
    this.error,
  });

  PanditOnboardingState copyWith({
    PanditDraft? draft,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return PanditOnboardingState(
      draft: draft ?? this.draft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PanditOnboardingNotifier extends StateNotifier<PanditOnboardingState> {
  final Ref _ref;

  PanditOnboardingNotifier(this._ref) : super(const PanditOnboardingState());

  void updateIdentity({
    String? emailAddress,
    String? aadharNumber,
    String? panNumber,
    String? aadharFrontPath,
    String? aadharBackPath,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        emailAddress: emailAddress,
        aadharNumber: aadharNumber,
        panNumber: panNumber,
        aadharFrontPath: aadharFrontPath,
        aadharBackPath: aadharBackPath,
      ),
      clearError: true,
    );
  }

  void updatePersonalDetails({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    int? experienceYears,
    String? bio,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? addressState,
    String? pinCode,
    String? profileImagePath,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        experienceYears: experienceYears,
        bio: bio,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: addressState,
        pinCode: pinCode,
        profileImagePath: profileImagePath,
      ),
      clearError: true,
    );
  }

  void toggleServiceCity(String city) {
    final current = List<String>.from(state.draft.serviceCities);
    if (current.contains(city)) {
      current.remove(city);
    } else {
      current.add(city);
    }
    state = state.copyWith(
      draft: state.draft.copyWith(serviceCities: current),
      clearError: true,
    );
  }

  void toggleSpecialization(String slug) {
    final current = List<String>.from(state.draft.ritualSlugs);
    if (current.contains(slug)) {
      current.remove(slug);
    } else {
      current.add(slug);
    }
    state = state.copyWith(
      draft: state.draft.copyWith(ritualSlugs: current),
      clearError: true,
    );
  }

  Future<bool> submitProfile(String userId) async {
    if (!state.draft.isSubmittable) {
      state = state.copyWith(error: 'Please complete all required fields.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repository = _ref.read(panditRepositoryProvider);
      await repository.submitPanditProfile(userId, state.draft);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}
