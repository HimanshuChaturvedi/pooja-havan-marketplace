import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booking_repository.dart';
import 'booking_repository_impl.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl();
});
