import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Test actual booking insertion', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    final String verifiedPanditId = '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d';
    final String testUserId = '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d'; // Using the same ID as customer for test

    print('--- Attempting Insertion ---');
    try {
      final response = await supabase.from('bookings').insert({
        'user_id': testUserId,
        'booking_type': 'HOME',
        'ritual_name': 'Test Ritual',
        'city_id': 'VARANASI', 
        'address': 'Test Address',
        'status': 'CREATED',
        'reference_id': 'TEST-FK-001',
        'total_amount': 1000.0,
        'pandit_id': verifiedPanditId,
      }).select();
      
      print('Insert success: $response');
    } catch (e) {
      print('Insert failed: $e');
    }
  });
}
