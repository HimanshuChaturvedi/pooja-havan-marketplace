class PanditDraft {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String emailAddress;
  final String aadharNumber;
  final String panNumber;
  final int experienceYears;
  final String bio;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pinCode;
  final List<String> serviceCities;
  final List<String> ritualSlugs;
  final String? profileImagePath;
  final String? aadharFrontPath;
  final String? aadharBackPath;

  const PanditDraft({
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.aadharNumber = '',
    this.panNumber = '',
    this.experienceYears = 0,
    this.bio = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
    this.serviceCities = const [],
    this.ritualSlugs = const [],
    this.profileImagePath,
    this.aadharFrontPath,
    this.aadharBackPath,
  });

  bool get isIdentityComplete => 
      emailAddress.trim().isNotEmpty && 
      aadharNumber.trim().length == 12 &&
      aadharFrontPath != null &&
      aadharBackPath != null;

  bool get isPersonalDetailsComplete => 
      firstName.trim().isNotEmpty && 
      phoneNumber.trim().length >= 10 &&
      addressLine1.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      pinCode.trim().length == 6 &&
      profileImagePath != null;

  bool get isAreasComplete => serviceCities.isNotEmpty;
  bool get isSpecializationsComplete => ritualSlugs.isNotEmpty;

  bool get isSubmittable => isIdentityComplete && isPersonalDetailsComplete && isAreasComplete && isSpecializationsComplete;

  PanditDraft copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? emailAddress,
    String? aadharNumber,
    String? panNumber,
    int? experienceYears,
    String? bio,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    List<String>? serviceCities,
    List<String>? ritualSlugs,
    String? profileImagePath,
    String? aadharFrontPath,
    String? aadharBackPath,
  }) {
    return PanditDraft(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      serviceCities: serviceCities ?? this.serviceCities,
      ritualSlugs: ritualSlugs ?? this.ritualSlugs,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      aadharFrontPath: aadharFrontPath ?? this.aadharFrontPath,
      aadharBackPath: aadharBackPath ?? this.aadharBackPath,
    );
  }
}
