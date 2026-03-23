import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Inspect bookings table schema', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- Columns in bookings ---');
    try {
      final columns = await supabase.rpc('get_table_columns', params: {'table_name': 'bookings'});
      print(columns);
    } catch (e) {
      print('RPC get_table_columns failed or not found. Trying raw select.');
      try {
         final firstRow = await supabase.from('bookings').select('*').limit(1);
         print('First row keys: ${firstRow.isNotEmpty ? firstRow.first.keys : "Empty table"}');
      } catch (e2) {
         print('Raw select failed: $e2');
      }
    }

    print('\n--- Testing insertions for 7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d ---');
    try {
      // Check if this pandit ID exists in pandit_profiles
      final pandit = await supabase.from('pandit_profiles').select('id').eq('id', '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d').maybeSingle();
      print('Pandit exists in profiles: ${pandit != null}');
    } catch (e) {
      print('Check pandit failed: $e');
    }
  });
}
