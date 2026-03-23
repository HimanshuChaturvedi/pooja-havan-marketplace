import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Inspect FK constraint details deeply', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- Fetching all columns and constraints meta-info ---');
    try {
      // Since we can't run raw SQL, we'll try to use the build-in information schema 
      // via a view if it exists, or just try to trigger failures for OTHER columns.
      
      final String validPanditId = '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d';
      
      print('TEST 1: Inserting with valid Pandit ID but invalid Ritual ID (UUID)');
      try {
        await supabase.from('bookings').insert({
          'user_id': validPanditId,
          'pandit_id': validPanditId,
          'ritual_id': '00000000-0000-0000-0000-000000000002', // Invalid UUID for ritual
        }).select();
      } on PostgrestException catch (e) {
        print('Postgres Error on ritual_id: ${e.message}');
      }

      print('\nTEST 2: Inserting with valid Pandit ID but invalid City ID (UUID)');
      try {
        await supabase.from('bookings').insert({
          'user_id': validPanditId,
          'pandit_id': validPanditId,
          'city_id': '00000000-0000-0000-0000-000000000003', // Invalid UUID for city
        }).select();
      } on PostgrestException catch (e) {
        print('Postgres Error on city_id: ${e.message}');
      }

    } catch (e) {
      print('Generic error: $e');
    }
  });
}
