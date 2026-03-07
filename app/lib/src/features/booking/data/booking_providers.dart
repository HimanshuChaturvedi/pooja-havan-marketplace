import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booking_repository.dart';
import 'booking_repository_impl.dart';
import '../domain/booking_draft.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl();
});

// autoDispose: cache clears when MyBookingsPage is unmounted
// so every time user navigates to Bookings tab → fresh fetch from DB
final bookingsProvider = FutureProvider.autoDispose<List<BookingDraft>>((ref) {
  return ref.read(bookingRepositoryProvider).getBookings();
});
