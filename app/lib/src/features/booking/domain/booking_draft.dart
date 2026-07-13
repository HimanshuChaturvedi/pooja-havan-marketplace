enum BookingType {
  home,
  temple,
  tirth,
  shop,
}
 
enum BookingStatusDetailed {
  created,
  paid,      // New DB state
  confirmed, // New DB state
  assigned, 
  onWay,    
  inProgress,
  completed,
  cancelled,
  rejected,
}

class BookingDraft {
  // Common
  String? id; // Unique ID from Supabase
  String? referenceId; // Human readable ID (e.g. PHM-2024-XXX)
  String? panditId; // UUID of assigned Pandit
  BookingType bookingType;
  BookingStatusDetailed status;
  String ritualName;
  String? ritualId; // UUID from Supabase
  String city;
  String? cityId; // UUID from Supabase

  // Home specific
  String? address;

  // Temple specific
  String? templeName;
  String? templeId; // UUID from Supabase
  String? panditName;

  // Date & time
  DateTime? selectedDate;
  String? selectedTime;

  // Location Metadata (Crucial for Pandit selection & Pricing)
  double? latitude;
  double? longitude;
  String? area; // e.g. Indirapuram, Raj Nagar

  // Pricing
  double poojaDakshina;
  double samagriCharges;
  double deliveryFee;
  double platformFee;

  double get totalAmount => poojaDakshina + samagriCharges + deliveryFee + platformFee;

  // Samagri
  bool samagriRequired;
  List<String> samagriItems;

  BookingDraft({
    this.id,
    this.referenceId,
    this.panditId,
    required this.bookingType,
    this.status = BookingStatusDetailed.created,
    required this.ritualName,
    this.ritualId,
    required this.city,
    this.cityId,
    this.address,
    this.templeName,
    this.templeId,
    this.panditName,
    this.selectedDate,
    this.selectedTime,
    this.latitude,
    this.longitude,
    this.area,
    this.poojaDakshina = 0.0,
    this.samagriCharges = 0.0,
    this.deliveryFee = 0.0,
    this.platformFee = 0.0,
    this.samagriRequired = false,
    List<String>? samagriItems,
  }) : samagriItems = samagriItems ?? [];

  BookingDraft copyWith({
    String? id,
    String? referenceId,
    String? panditId,
    BookingType? bookingType,
    BookingStatusDetailed? status,
    String? ritualName,
    String? ritualId,
    String? city,
    String? cityId,
    String? address,
    String? templeName,
    String? templeId,
    String? panditName,
    DateTime? selectedDate,
    String? selectedTime,
    double? latitude,
    double? longitude,
    String? area,
    double? poojaDakshina,
    double? samagriCharges,
    double? deliveryFee,
    double? platformFee,
    bool? samagriRequired,
    List<String>? samagriItems,
  }) {
    return BookingDraft(
      id: id ?? this.id,
      referenceId: referenceId ?? this.referenceId,
      panditId: panditId ?? this.panditId,
      bookingType: bookingType ?? this.bookingType,
      status: status ?? this.status,
      ritualName: ritualName ?? this.ritualName,
      ritualId: ritualId ?? this.ritualId,
      city: city ?? this.city,
      cityId: cityId ?? this.cityId,
      address: address ?? this.address,
      templeName: templeName ?? this.templeName,
      templeId: templeId ?? this.templeId,
      panditName: panditName ?? this.panditName,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      poojaDakshina: poojaDakshina ?? this.poojaDakshina,
      samagriCharges: samagriCharges ?? this.samagriCharges,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      platformFee: platformFee ?? this.platformFee,
      samagriRequired: samagriRequired ?? this.samagriRequired,
      samagriItems: samagriItems ?? this.samagriItems,
    );
  }
}
