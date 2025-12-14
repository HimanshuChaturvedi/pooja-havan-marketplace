enum BookingType {
  home,
  temple,
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
    this.samagriRequired = false,
    List<String>? samagriItems,
  }) : samagriItems = samagriItems ?? [];
}
