enum BookingType {
  home,
  temple,
  tirth,
  shop,
}

class BookingDraft {
  // Common
  String? id; // Unique ID from Supabase
  BookingType bookingType;
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
    required this.bookingType,
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
}
