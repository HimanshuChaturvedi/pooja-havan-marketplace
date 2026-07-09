class WhatsAppConfig {
  /// 🔒 MOCK MODE: Set to false to use real Meta Business API
  static const bool useMockApi = false;

  /// 🔒 ADMIN / PLATFORM WHATSAPP NUMBER
  static const String adminNumber = '+918287966676';

  /// 🌐 TEMPLATE LANGUAGE CODES
  static const String otpLanguage = 'en';
  static const String bookingLanguage = 'en'; // Changed back to 'en' since Hinglish templates are registered in English in Meta

}
