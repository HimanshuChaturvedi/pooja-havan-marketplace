import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

// ✅ EXACT PACKAGE IMPORTS (MATCH REAL PATHS)
import 'package:app/src/core/config/whatsapp_config.dart';
import 'package:app/src/core/supabase/supabase_client.dart' as appSupabase;

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

  /// Sends an automated Meta WhatsApp API template message via Supabase Edge Function
  static Future<bool> sendTemplateMessage({
    required String phone,
    required String templateName,
    required List<String> parameters,
  }) async {
    try {
      // Lazy import supabase client to avoid cyclic dependency issues
      final supabase = appSupabase.supabase;
      
      final response = await supabase.functions.invoke(
        'whatsapp-notify',
        body: {
          'phone': phone,
          'template_name': templateName,
          'parameters': parameters,
        },
      );

      return response.status == 200;
    } catch (e) {
      print('Failed to send automated WhatsApp: $e');
      return false;
    }
  }
}

