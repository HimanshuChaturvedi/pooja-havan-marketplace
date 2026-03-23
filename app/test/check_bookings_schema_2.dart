import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Check bookings table schema columns', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- Columns in bookings table ---');
    try {
      // We can't access information_schema directly via anon key usually,
      // so we use a trick: insert a null value into a column we know exists 
      // and check the error message if it fails, or just select all and look at keys.
      
      // Wait! I'll try to use the 'get_table_info' if I have it. 
      // Since I don't, I'll just select.
      final result = await supabase.from('bookings').select().limit(1);
      print('First row (to see keys): $result');
      
      if (result.isNotEmpty) {
        print('Keys: ${result.first.keys.toList()}');
      } else {
        print('Table is empty. Attempting to get metadata via RPC if possible...');
      }

    } catch (e) {
      print('Schema check failed: $e');
    }
  });
}
