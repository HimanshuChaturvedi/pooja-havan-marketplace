import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl();
});
