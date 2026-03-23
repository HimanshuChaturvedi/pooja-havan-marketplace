import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('List constraints for bookings', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- Foreign Keys on bookings ---');
    try {
      final query = '''
        SELECT
            tc.table_name, 
            kcu.column_name, 
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name,
            tc.constraint_name
        FROM 
            information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = 'bookings';
      ''';
      
      // Since I can't run raw SQL easily via anon key without an RPC, 
      // I'll try to find an RPC that might help or just guess.
      print('Unable to run raw information_schema query without RPC. Testing assumption...');
      
      // TEST: Try inserting a booking with NULL pandit_id to see if it works.
      // Actually, I'll try to fetch the pandit profile again with MORE DETAIL.
      final p = await supabase.from('pandit_profiles').select('*').eq('id', '7130fd4d-9ef1-49b5-b5cf-d46ac4d7802d').single();
      print('Pandit Detail: $p');
      
    } catch (e) {
      print('Error: $e');
    }
  });
}
