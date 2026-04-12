import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/logger.dart';

abstract class PaymentRepository {
  Future<void> recordPayment({
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    required double amount,
    String? bookingId,
    String? samagriOrderId,
    String status = 'captured',
  });
}

class PaymentRepositoryImpl implements PaymentRepository {
  @override
  Future<void> recordPayment({
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    required double amount,
    String? bookingId,
    String? samagriOrderId,
    String status = 'captured',
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await supabase.from('payments').insert({
        'user_id': user.id,
        'booking_id': bookingId,
        'samagri_order_id': samagriOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
        'amount': amount,
        'status': status,
      });
      AppLogger.info('Payment recorded successfully: $razorpayPaymentId');
    } catch (e) {
      AppLogger.error('Failed to record payment', e);
      rethrow;
    }
  }
}
