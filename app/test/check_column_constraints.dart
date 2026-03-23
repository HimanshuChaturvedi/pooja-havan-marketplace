import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Exhaustive constraint check for bookings', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    final String validPanditId = '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d';
    
    print('--- Testing Various Insert Scenarios ---');

    // Scenario 1: Minimal valid insert (should WORK based on previous test)
    print('\nScenario 1: Full payload with valid Pandit ID');
    try {
      final res = await supabase.from('bookings').insert({
        'user_id': validPanditId,
        'booking_type': 'HOME',
        'ritual_name': 'Test',
        'status': 'CREATED',
        'reference_id': 'TEST-S1-${DateTime.now().millisecond}',
        'total_amount': 100,
        'pandit_id': validPanditId,
      }).select();
      print('S1 Success: ${res.first['id']}');
    } catch (e) {
      print('S1 Failed: $e');
    }

    // Scenario 2: Pandit ID as empty string (should FAIL or become null)
    print('\nScenario 2: Pandit ID as empty string');
    try {
      await supabase.from('bookings').insert({
        'user_id': validPanditId,
        'booking_type': 'HOME',
        'ritual_name': 'Test',
        'status': 'CREATED',
        'reference_id': 'TEST-S2-${DateTime.now().millisecond}',
        'total_amount': 100,
        'pandit_id': '', // EMPTY STRING
      });
    } catch (e) {
      print('S2 Failed (Expected if UUID): $e');
    }

    // Scenario 3: Missing reference_id (should FAIL if mandatory)
    print('\nScenario 3: Missing reference_id');
    try {
      await supabase.from('bookings').insert({
        'user_id': validPanditId,
        'booking_type': 'HOME',
        'pandit_id': validPanditId,
        // reference_id missing
      });
    } catch (e) {
      print('S3 Failed: $e');
    }

  });
}
