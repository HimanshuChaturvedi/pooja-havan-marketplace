import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'razorpay_service.dart';

final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final service = RazorpayService();
  ref.onDispose(() => service.dispose());
  return service;
});
