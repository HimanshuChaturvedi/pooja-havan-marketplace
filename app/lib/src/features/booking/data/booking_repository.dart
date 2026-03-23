import '../domain/booking_draft.dart';
import '../../samagri_flow/application/samagri_session.dart';

abstract class BookingRepository {
  Future<String> createBooking(BookingDraft booking, {List<SamagriItem>? samagriItems});
  Future<List<BookingDraft>> getBookings();
  Future<List<BookingDraft>> getAssignedBookings();
}
