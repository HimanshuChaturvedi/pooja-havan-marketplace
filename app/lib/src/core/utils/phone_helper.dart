/// Normalizes an Indian mobile number to the canonical `+91XXXXXXXXXX` format.
///
/// Accepts common user input variants such as `9876543210`,
/// `919876543210`, `+919876543210`, and `09876543210`.
String normalizePhoneNumber(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  String nationalNumber;

  if (digits.length == 10) {
    nationalNumber = digits;
  } else if (digits.length == 11 && digits.startsWith('0')) {
    nationalNumber = digits.substring(1);
  } else if (digits.length == 12 && digits.startsWith('91')) {
    nationalNumber = digits.substring(2);
  } else {
    throw const FormatException('Enter a valid 10-digit Indian mobile number.');
  }

  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(nationalNumber)) {
    throw const FormatException('Enter a valid 10-digit Indian mobile number.');
  }

  return '+91$nationalNumber';
}

/// Returns the WhatsApp/Meta-friendly digits-only format, e.g. `919876543210`.
String normalizePhoneNumberForWhatsApp(String phone) {
  return normalizePhoneNumber(phone).replaceAll(RegExp(r'\D'), '');
}
