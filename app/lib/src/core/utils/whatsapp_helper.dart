import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

// ✅ EXACT PACKAGE IMPORTS (MATCH REAL PATHS)
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/core/config/whatsapp_config.dart';

class WhatsAppHelper {
  static Future<void> openChat({
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);
    final number = WhatsAppConfig.adminNumber;

    final Uri uri = Platform.isAndroid
        ? Uri.parse(
            'https://wa.me/$number?text=$encodedMessage',
          )
        : Uri.parse(
            'https://api.whatsapp.com/send?phone=$number&text=$encodedMessage',
          );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // 🔒 STEP-3 FIX
      // Booking flow ke baad session clear
      BookingSession.clearIfBookingFlow();
    }
  }
}
