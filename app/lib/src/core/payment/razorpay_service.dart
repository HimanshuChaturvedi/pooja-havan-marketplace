import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/logger.dart';

class RazorpayService {
  late Razorpay _razorpay;

  void Function(PaymentSuccessResponse)? onSuccess;
  void Function(PaymentFailureResponse)? onFailure;
  void Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String keyId,
    required double amount,
    required String contact,
    required String email,
    required String description,
    Map<String, dynamic>? notes,
  }) {
    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': 'Pooja Havan Marketplace',
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      },
      'notes': notes ?? {},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      AppLogger.error('Error opening Razorpay checkout', e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    AppLogger.info('Payment Success: ${response.paymentId}');
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppLogger.error('Payment Error: ${response.code} - ${response.message}');
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppLogger.info('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
