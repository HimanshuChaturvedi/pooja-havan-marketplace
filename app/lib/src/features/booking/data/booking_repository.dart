import '../domain/booking_draft.dart';
import '../../samagri_flow/application/samagri_session.dart';

abstract class BookingRepository {
  Future<Map<String, String>> createBooking(BookingDraft booking, {List<SamagriItem>? samagriItems});
  Future<List<BookingDraft>> getBookings();
  Future<List<BookingDraft>> getAssignedBookings();
  Future<void> updateBookingStatus(String bookingId, BookingStatusDetailed status);
  Future<String> rejectAndReassignBooking(String bookingId, String currentPanditId);
}
