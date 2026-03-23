import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Diagnose FK constraint details', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- Running Diagnostic Query via RPC (if possible) ---');
    try {
      // We'll try to use the 'exec' or similar RPC if it exists, 
      // but since we don't know, we'll try to find any existing function.
      // Alternatively, we can try to guess the constraint by intentionally failing it 
      // and parsing the error more deeply.
      
      final String randomId = '00000000-0000-0000-0000-000000000001';
      final response = await supabase.from('bookings').insert({
        'user_id': '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d',
        'pandit_id': randomId,
      }).select();
      print('Insert success: $response');
    } on PostgrestException catch (e) {
      print('Error Caught: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
    } catch (e) {
      print('Generic error: $e');
    }
  });
}
