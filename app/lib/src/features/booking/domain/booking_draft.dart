enum BookingType {
  home,
  temple,
  tirth,
  other,
}

class BookingDraft {
  // Common
  BookingType bookingType;
  String ritualName;
  String city;

  // Home specific
  String? address;

  // Temple specific
  String? templeName;
  String? panditName;

  // Date & time
  DateTime? selectedDate;
  String? selectedTime;

  // Location Metadata (Crucial for Pandit selection & Pricing)
  double? latitude;
  double? longitude;
  String? area; // e.g. Indirapuram, Raj Nagar

  // Samagri
  bool samagriRequired;
  List<String> samagriItems;

  BookingDraft({
    required this.bookingType,
    required this.ritualName,
    required this.city,
    this.address,
    this.templeName,
    this.panditName,
    this.selectedDate,
    this.selectedTime,
    this.latitude,
    this.longitude,
    this.area,
    this.samagriRequired = false,
    List<String>? samagriItems,
  }) : samagriItems = samagriItems ?? [];
}
