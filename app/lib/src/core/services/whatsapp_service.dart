import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app/src/core/config/whatsapp_config.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final whatsappServiceProvider = Provider((ref) => WhatsAppService(ref));

/// 📣 Provider to show mock messages in UI during testing
final lastMockMessageProvider = StateProvider<String?>((ref) => null);

class WhatsAppService {
  final Ref _ref;
  WhatsAppService(this._ref);
  /// 📲 SENDS OTP VIA WHATSAPP (MOCKED FOR NOW)
  Future<bool> sendOtp(String phone, String code) async {
    // 1. Log to Database for Verification
    try {
      await supabase.from('otp_verifications').insert({
        'phone': phone,
        'code': code,
        'expires_at': DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
      });
    } catch (e) {
      print('DEBUG: OTP DB Log error: $e');
      rethrow; // Throw the actual error (e.g. "Table not found")
    }
    // 2. Send via WhatsApp API
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Your Bharat Pooja Setu verification code is: $code';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone');
      AppLogger.debug('💬 Message: $msg');
      
      // Update provider to show in app UI
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      AppLogger.debug('Updating lastMockMessageProvider...');
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to $phone] ($timestamp)\n$msg';
      
      return true;
    }

    final url = Uri.parse('https://graph.facebook.com/v17.0/${WhatsAppConfig.phoneNumberId}/messages');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${WhatsAppConfig.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "messaging_product": "whatsapp",
        "to": phone,
        "type": "template",
        "template": {
          "name": "authentication_otp", // Needs to match your Meta template name
          "language": {"code": "en_US"},
          "components": [
            {
              "type": "body",
              "parameters": [
                {"type": "text", "text": code}
              ]
            },
            {
              "type": "button",
              "sub_type": "url",
              "index": "0",
              "parameters": [
                {"type": "text", "text": code}
              ]
            }
          ]
        }
      }),
    );

    return response.statusCode == 200;
  }

  /// ✅ VERIFIES OTP AGAINST DATABASE
  Future<bool> verifyOtp(String phone, String code) async {
    try {
      final response = await supabase
          .from('otp_verifications')
          .select()
          .eq('phone', phone)
          .eq('code', code)
          .eq('is_verified', false)
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response != null) {
        // Mark as verified to prevent reuse
        await supabase
            .from('otp_verifications')
            .update({'is_verified': true})
            .eq('id', response['id']);
        return true;
      }
      return false;
    } catch (e) {
      print('DEBUG: OTP Verification error: $e');
      return false;
    }
  }

  /// 📦 SENDS TRANSACTIONAL UPDATE (BOOKING CONFIRMATION)
  Future<bool> sendBookingConfirmation(String phone, String ritualName, String date) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! Your $ritualName booking is confirmed for $date. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to $phone] ($timestamp)\n$msg';
      return true;
    }

    // Logic for Meta template "booking_confirmation" would go here
    return true;
  }

  /// 🎓 SENDS ASSIGNMENT ALERT TO PANDIT
  Future<bool> sendPanditAssignment(String phone, String ritualName, String address, String dateTime) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! New Booking Assigned: $ritualName at $address on $dateTime. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Pandit)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Pandit $phone] ($timestamp)\n$msg';
      return true;
    }

    // Logic for Meta template "pandit_assignment" would go here
    return true;
  }
  /// 🏪 SENDS ORDER ALERT TO VENDOR
  Future<bool> sendVendorNewOrder(String phone, String ritualName, String address, double amount) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! New Samagri Order for $ritualName. Delivery to $address. Total: ₹$amount. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Vendor)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Vendor $phone] ($timestamp)\n$msg';
      return true;
    }

    // Logic for Meta template "vendor_new_order" would go here
    return true;
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
