import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../config/whatsapp_config.dart';

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
    }
  }
}
