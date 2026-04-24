import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booking_repository.dart';
import 'booking_repository_impl.dart';
import '../domain/booking_draft.dart';

import '../../../core/services/whatsapp_service.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final whatsApp = ref.read(whatsappServiceProvider);
  return BookingRepositoryImpl(whatsApp);
});

// autoDispose: cache clears when MyBookingsPage is unmounted
// so every time user navigates to Bookings tab → fresh fetch from DB
final bookingsProvider = FutureProvider.autoDispose<List<BookingDraft>>((ref) {
  return ref.read(bookingRepositoryProvider).getBookings();
});

final assignedBookingsProvider = FutureProvider.autoDispose<List<BookingDraft>>((ref) {
  return ref.read(bookingRepositoryProvider).getAssignedBookings();
});
