enum PanditVerificationStatus {
  pending,
  verified,
  rejected,
}

PanditVerificationStatus _parseStatus(String? status) {
  switch (status?.toUpperCase()) {
    case 'VERIFIED':
      return PanditVerificationStatus.verified;
    case 'REJECTED':
      return PanditVerificationStatus.rejected;
    case 'PENDING':
    default:
      return PanditVerificationStatus.pending;
  }
}

class PanditProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? emailAddress;
  final String aadharNumber;
  final String? panNumber;
  final int experienceYears;
  final String? bio;
  final String? profileImageUrl;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? aadharFrontUrl;
  final String? aadharBackUrl;
  final PanditVerificationStatus verificationStatus;
  final DateTime? createdAt;

  // Virtual fields joined from junction tables
  final List<String> serviceCities;
  final List<String> ritualSlugs;

  const PanditProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.emailAddress,
    required this.aadharNumber,
    this.panNumber,
    required this.experienceYears,
    this.bio,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pinCode,
    this.profileImageUrl,
    this.aadharFrontUrl,
    this.aadharBackUrl,
    this.verificationStatus = PanditVerificationStatus.pending,
    this.createdAt,
    this.serviceCities = const [],
    this.ritualSlugs = const [],
  });

  factory PanditProfile.fromJson(Map<String, dynamic> json) {
    return PanditProfile(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      emailAddress: json['email_address'] as String?,
      aadharNumber: json['aadhar_number'] as String? ?? '',
      aadharFrontUrl: json['aadhar_front_url'] as String?,
      aadharBackUrl: json['aadhar_back_url'] as String?,
      panNumber: json['pan_number'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      bio: json['bio'] as String?,
      addressLine1: json['address_line_1'] as String?,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: json['pin_code'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      verificationStatus: _parseStatus(json['verification_status'] as String?),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      serviceCities: (json['serviceCities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ritualSlugs: (json['ritualSlugs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  PanditProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? emailAddress,
    String? aadharNumber,
    String? aadharFrontUrl,
    String? aadharBackUrl,
    String? panNumber,
    int? experienceYears,
    String? bio,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    String? profileImageUrl,
    PanditVerificationStatus? verificationStatus,
    DateTime? createdAt,
    List<String>? serviceCities,
    List<String>? ritualSlugs,
  }) {
    return PanditProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      aadharFrontUrl: aadharFrontUrl ?? this.aadharFrontUrl,
      aadharBackUrl: aadharBackUrl ?? this.aadharBackUrl,
      panNumber: panNumber ?? this.panNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      serviceCities: serviceCities ?? this.serviceCities,
      ritualSlugs: ritualSlugs ?? this.ritualSlugs,
    );
  }
}
