import '../domain/booking_draft.dart';

abstract class BookingRepository {
  Future<String> createBooking(BookingDraft booking);
}
