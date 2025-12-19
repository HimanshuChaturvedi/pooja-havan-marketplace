import '../../../core/supabase/supabase_client.dart';
import '../domain/booking_draft.dart';
import 'booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  @override
  Future<String> createBooking(BookingDraft booking) async {
    final response = await supabase.from('bookings').insert({
      'city_id': booking.city, // abhi string, baad me FK
      'booking_type': booking.bookingType.name,
      'address': booking.address,
      'temple_name': booking.templeName,
      'pandit_name': booking.panditName,
      'selected_date': booking.selectedDate?.toIso8601String(),
      'selected_time': booking.selectedTime,
      'samagri_required': booking.samagriRequired,
      'status': 'created',
    }).select('id').single();

    return response['id'].toString();
  }
}
