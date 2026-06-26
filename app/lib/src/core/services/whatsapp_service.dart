import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/src/core/config/whatsapp_config.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/core/utils/logger.dart';
import 'package:app/src/core/utils/phone_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpResponse {
  final bool success;
  final String? errorMessage;
  final int? attemptsLeft;

  OtpResponse({
    required this.success,
    this.errorMessage,
    this.attemptsLeft,
  });

  factory OtpResponse.success() => OtpResponse(success: true);
  factory OtpResponse.failure(String message, {int? attemptsLeft}) => OtpResponse(
        success: false,
        errorMessage: message,
        attemptsLeft: attemptsLeft,
      );
}

final whatsappServiceProvider = Provider((ref) => WhatsAppService(ref));

/// 📣 Provider to show mock messages in UI during testing
final lastMockMessageProvider = StateProvider<String?>((ref) => null);

class WhatsAppService {
  final Ref _ref;
  WhatsAppService(this._ref);
  /// 📲 SENDS OTP VIA WHATSAPP
  Future<OtpResponse> sendOtp(String phone, String purpose) async {
    try {
      final formattedPhone = normalizePhoneNumberForWhatsApp(phone);
      final response = await supabase.functions.invoke(
        'whatsapp-otp',
        body: {
          'action': 'send',
          'phone': formattedPhone,
          'purpose': purpose,
        },
      );

      if (response.status == 200 || response.status == 201) {
        AppLogger.info('✅ Secure OTP sent successfully to: $formattedPhone for $purpose');
        return OtpResponse.success();
      } else {
        final errorMsg = response.data?['error'] ?? 'Failed to send OTP';
        AppLogger.error('❌ Failed to send secure OTP: $errorMsg');
        return OtpResponse.failure(errorMsg);
      }
    } catch (e) {
      AppLogger.error('❌ sendOtp Edge Function error: $e');
      String errorMsg = 'Failed to connect to verification server';
      int? attemptsLeft;

      if (e is FormatException) {
        errorMsg = e.message;
      } else if (e is FunctionException) {
        try {
          final data = e.details is String ? jsonDecode(e.details) : e.details;
          errorMsg = data?['error'] ?? (e.reasonPhrase ?? 'Edge Function error');
          attemptsLeft = data?['attemptsLeft'];
        } catch (_) {
          errorMsg = e.reasonPhrase ?? 'Edge Function error';
        }
      } else {
        errorMsg = e.toString();
      }
      return OtpResponse.failure(errorMsg, attemptsLeft: attemptsLeft);
    }
  }

  // For Automated Booking Notifications
  Future<bool> sendBookingConfirmation(String phone, String ritualName, String dateStr) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! Your $ritualName booking is confirmed for $dateStr. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to $phone] ($timestamp)\n$msg';
      return true;
    }
    // Parameters: {{1}} = Ritual Name, {{2}} = Date & Time
    return _sendTemplate(phone, 'booking_confirmation', [ritualName, dateStr], language: WhatsAppConfig.bookingLanguage);
  }

  Future<bool> sendPanditAssignment(String phone, String ritualName, String address, String dateStr) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! New Booking Assigned: $ritualName at $address on $dateStr. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Pandit)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Pandit $phone] ($timestamp)\n$msg';
      return true;
    }
    // Parameters: {{1}} = Ritual Name, {{2}} = Address, {{3}} = Date & Time
    return _sendTemplate(phone, 'new_assignment_alert', [ritualName, address, dateStr], language: WhatsAppConfig.bookingLanguage);
  }

  Future<bool> sendVendorNewOrder(String phone, String ritualName, String address, double amount) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! New Samagri Order for $ritualName. Delivery to $address. Total: ₹$amount. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Vendor)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Vendor $phone] ($timestamp)\n$msg';
      return true;
    }
    // Parameters: {{1}} = Ritual Name (or Order Type), {{2}} = Address, {{3}} = Amount
    return _sendTemplate(phone, 'new_samagri_order', [ritualName, address, amount.toStringAsFixed(0)], language: WhatsAppConfig.bookingLanguage);
  }

  Future<bool> _sendTemplate(String phone, String templateName, List<String> parameters, {String? language}) async {
    try {
      final formattedPhone = normalizePhoneNumberForWhatsApp(phone);
      final response = await supabase.functions.invoke(
        'whatsapp-notify',
        body: {
          'phone': formattedPhone,
          'template_name': templateName,
          'parameters': parameters, 
          if (language != null) 'language': language,
        },
      );

      if (response.status == 200 || response.status == 201) {
        AppLogger.info('✅ Message sent via Edge Function: $templateName');
        return true;
      } else {
        AppLogger.error('❌ Failed to send template $templateName: ${response.data}');
        return false;
      }
    } catch (e) {
      AppLogger.error('❌ Edge Function error: $e');
      return false;
    }
  }

  /// ✅ VERIFIES OTP VIA EDGE FUNCTION
  Future<OtpResponse> verifyOtp(String phone, String code, String purpose) async {
    try {
      final formattedPhone = normalizePhoneNumberForWhatsApp(phone);
      final response = await supabase.functions.invoke(
        'whatsapp-otp',
        body: {
          'action': 'verify',
          'phone': formattedPhone,
          'purpose': purpose,
          'code': code,
        },
      );

      if (response.status == 200 || response.status == 201) {
        AppLogger.info('✅ Secure OTP verified successfully for: $formattedPhone');
        return OtpResponse.success();
      } else {
        final errorMsg = response.data?['error'] ?? 'Invalid OTP code';
        AppLogger.error('❌ Secure OTP verification failed: $errorMsg');
        return OtpResponse.failure(errorMsg);
      }
    } catch (e) {
      AppLogger.error('❌ verifyOtp Edge Function error: $e');
      String errorMsg = 'Failed to connect to verification server';
      int? attemptsLeft;

      if (e is FormatException) {
        errorMsg = e.message;
      } else if (e is FunctionException) {
        try {
          final data = e.details is String ? jsonDecode(e.details) : e.details;
          errorMsg = data?['error'] ?? (e.reasonPhrase ?? 'Edge Function error');
          attemptsLeft = data?['attemptsLeft'];
        } catch (_) {
          errorMsg = e.reasonPhrase ?? 'Edge Function error';
        }
      } else {
        errorMsg = e.toString();
      }
      return OtpResponse.failure(errorMsg, attemptsLeft: attemptsLeft);
    }
  }


  /// 🛍️ SENDS SAMAGRI ORDER CONFIRMATION TO CUSTOMER
  Future<bool> sendSamagriOrderConfirmation(String phone, String refId, double amount) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! Your Samagri order ($refId) for ₹$amount is confirmed. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Customer)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Customer $phone] ($timestamp)\n$msg';
      return true;
    }

    // Logic for Meta template "samagri_confirmation" would go here
    return true;
  }

  /// 🧪 TEST CONNECTION (Using default Meta hello_world template)
  Future<bool> testConnection(String phone) async {
    // 🔥 SANITIZE: Meta API expects digits only (e.g., 918287966676)
    final sanitizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    final url = Uri.parse('https://graph.facebook.com/v25.0/${WhatsAppConfig.phoneNumberId}/messages');
    
    AppLogger.debug('🚀 [WHATSAPP LIVE TEST] To: $sanitizedPhone');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${WhatsAppConfig.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "messaging_product": "whatsapp",
        "to": sanitizedPhone,
        "type": "template",
        "template": {
          "name": "hello_world",
          "language": {"code": "en_US"}
        }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppLogger.info('✅ [WHATSAPP LIVE TEST] Success!');
      return true;
    } else {
      // 🔥 CRITICAL: Show the user exactly what Meta is saying
      final errorBody = response.body;
      AppLogger.error('❌ [WHATSAPP LIVE TEST] Failed!');
      AppLogger.error('   Status Code: ${response.statusCode}');
      AppLogger.error('   Error Details: $errorBody');
      
      // If the error message is visible in the console, it will explain everything
      return false;
    }
  }
}
