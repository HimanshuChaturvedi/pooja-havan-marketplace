import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Reproduce FK violation with random UUID', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    final String randomId = '00000000-0000-0000-0000-000000000000';
    final String testUserId = '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d'; // Valid user ID

    print('--- Attempting Insertion with Random Pandit ID ---');
    try {
      final response = await supabase.from('bookings').insert({
        'user_id': testUserId,
        'booking_type': 'HOME',
        'ritual_name': 'Test Ritual',
        'city_id': null, 
        'address': 'Test Address',
        'status': 'CREATED',
        'reference_id': 'REPRO-FK-002',
        'total_amount': 1000.0,
        'pandit_id': randomId, // THIS SHOULD FAIL FK
      }).select();
      
      print('Insert success (Wait, WHAT?!): $response');
    } catch (e) {
      print('Insert failed (Expected): $e');
    }
  });
}
