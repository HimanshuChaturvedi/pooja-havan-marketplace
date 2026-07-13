import 'dart:convert';

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

  /// 📋 new_samagri_order template: {{1}}=Pooja, {{2}}=CustomerName, {{3}}=Mobile, {{4}}=Address, {{5}}=Items
  Future<bool> sendVendorNewOrder(
    String phone,
    String ritualName,
    String address,
    double amount, {
    String customerName = '',
    String customerMobile = '',
    String samagriItems = '',
  }) async {
    if (WhatsAppConfig.useMockApi) {
      final msg = 'Jai Shree Ganesh! New Samagri Order for $ritualName. Delivery to $address. Total: ₹$amount. 🙏';
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Vendor)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Vendor $phone] ($timestamp)\n$msg';
      return true;
    }
    // Template: new_samagri_order — 5 params as per approved Meta template
    return _sendTemplate(
      phone,
      'new_samagri_order',
      [ritualName, customerName, customerMobile, address, samagriItems],
      language: WhatsAppConfig.bookingLanguage,
    );
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


  /// 🛍️ SENDS STANDALONE SAMAGRI ORDER CONFIRMATION TO CUSTOMER
  /// Uses approved Meta template: standalone_samagri_order_confirmation
  /// {{1}} = Customer Name, {{2}} = Samagri Items, {{3}} = Delivery Type, {{4}} = Total Amount
  Future<bool> sendSamagriOrderConfirmation(
    String phone, {
    required String customerName,
    required List<String> items,
    required String deliveryType,
    required double amount,
  }) async {
    if (WhatsAppConfig.useMockApi) {
      const msg = 'Namaste 🙏\n\n'
          'Aapka Samagri Order safaltapoorvak prapt ho gaya hai.\n\n'
          'Hamara Vendor jaldi hi aapse sampark karega aur aapke order ki delivery karega.\n\n'
          'Bharat Pooja Setu chunne ke liye dhanyavaad.';
          
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Customer)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Customer $phone] ($timestamp)\n$msg';
      return true;
    }

    final itemsText = items.join(', ');
    return _sendTemplate(
      phone,
      'standalone_samagri_order_confirmation',
      [customerName, itemsText, deliveryType, amount.toStringAsFixed(0)],
      language: WhatsAppConfig.bookingLanguage,
    );
  }

  /// 🛍️ SENDS STANDALONE SAMAGRI ORDER NOTIFICATION TO VENDOR
  Future<bool> sendVendorStandaloneSamagriOrder({
    required String vendorPhone,
    required String customerName,
    required String customerMobile,
    required String deliveryAddress,
    required List<String> orderedItems,
    required String deliveryType,
    required double totalBill,
  }) async {
    final itemsText = orderedItems.map((item) => '• $item').join('\n');

    if (WhatsAppConfig.useMockApi) {
      final msg = 'Hari Om Vendor Ji! 🙏\n\n'
          'Aapko ek naya Samagri Order mila hai.\n\n'
          'Customer Name:\n$customerName\n\n'
          'Customer Mobile:\n$customerMobile\n\n'
          'Delivery Address:\n$deliveryAddress\n\n'
          'Ordered Items:\n$itemsText\n\n'
          'Delivery Type:\n$deliveryType\n\n'
          'Total Bill:\n₹${totalBill.toStringAsFixed(0)}\n\n'
          'Kripya order samay par pack aur deliver karein.';
          
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $vendorPhone (Vendor)');
      AppLogger.debug('💬 Message: $msg');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Vendor $vendorPhone] ($timestamp)\n$msg';
      return true;
    }

    // Template: new_samagri_order — 5 params: {{1}}=OrderType, {{2}}=CustomerName, {{3}}=Mobile, {{4}}=Address, {{5}}=Items
    final cleanItemsText = orderedItems.join(', ');

    return _sendTemplate(
      vendorPhone,
      'new_samagri_order',
      [
        'Standalone Samagri Order',  // {{1}} Order type
        customerName,                // {{2}} Customer name
        customerMobile,              // {{3}} Mobile
        deliveryAddress,             // {{4}} Address
        cleanItemsText,              // {{5}} Items
      ],
      language: WhatsAppConfig.bookingLanguage,
    );
  }

  /// 🛍️ SENDS ORDER REJECTION NOTIFICATION TO CUSTOMER
  Future<bool> sendOrderRejectionToCustomer(String phone, String reason) async {
    final msg = 'Your order could not be fulfilled by the vendor. Our team will reassess your request. Reason: $reason';
    if (WhatsAppConfig.useMockApi) {
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: $phone (Customer Rejection)');
      AppLogger.debug('💬 Message: $msg');
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Customer $phone] ($timestamp)\n$msg';
      return true;
    }

    // 1. Try sending the new rejected_samagri_order template (expects reason in parameter {{1}})
    final success = await _sendTemplate(
      phone,
      'rejected_samagri_order',
      [reason],
      language: WhatsAppConfig.bookingLanguage,
    );

    if (success) {
      return true;
    }

    // 2. Fallback if new template fails (e.g., not yet approved by Meta)
    AppLogger.warn('⚠️ rejected_samagri_order template failed, falling back to booking_confirmation template');
    return _sendTemplate(
      phone,
      'booking_confirmation',
      ['Order Reassessment Alert', 'Your order could not be fulfilled by the vendor. Our team will reassess your request. (Reason: $reason)'],
      language: WhatsAppConfig.bookingLanguage,
    );
  }

  /// 🛍️ SENDS ORDER REJECTION NOTIFICATION TO ADMIN
  Future<bool> sendOrderRejectionToAdmin({
    required String orderRefId,
    required String reason,
    String? details,
  }) async {
    final reasonStr = details != null && details.isNotEmpty ? '$reason ($details)' : reason;
    final msg = 'Vendor rejected Order #$orderRefId. Reason: $reasonStr';
    
    if (WhatsAppConfig.useMockApi) {
      AppLogger.debug('🚀 [WHATSAPP MOCK] To: ${WhatsAppConfig.adminNumber} (Admin Alert)');
      AppLogger.debug('💬 Message: $msg');
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      _ref.read(lastMockMessageProvider.notifier).state = '[MOCK WhatsApp to Admin ${WhatsAppConfig.adminNumber}] ($timestamp)\n$msg';
      return true;
    }

    // 1. Try sending the new rejected_samagri_order template (expects reason in parameter {{1}})
    final success = await _sendTemplate(
      WhatsAppConfig.adminNumber,
      'rejected_samagri_order',
      ['Order #$orderRefId: $reasonStr'],
      language: WhatsAppConfig.bookingLanguage,
    );

    if (success) {
      return true;
    }

    // 2. Fallback if new template fails (e.g., not yet approved by Meta)
    AppLogger.warn('⚠️ rejected_samagri_order template failed for Admin, falling back to booking_confirmation template');
    return _sendTemplate(
      WhatsAppConfig.adminNumber,
      'booking_confirmation',
      ['Vendor Rejection Alert', 'Vendor rejected Order #$orderRefId. Reason: $reasonStr'],
      language: WhatsAppConfig.bookingLanguage,
    );
  }
}
