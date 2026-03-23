import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Check for singular booking table', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- Tables in public schema ---');
    try {
      // Use a trick to find tables: try to select from 'booking' and 'bookings'
      final b1 = await supabase.from('booking').select('id').limit(1).maybeSingle();
      print('Table "booking" exists and is queryable.');
    } catch (e) {
      print('Table "booking" does NOT exist or is NOT accessible: $e');
    }

    try {
      final b2 = await supabase.from('bookings').select('id').limit(1).maybeSingle();
      print('Table "bookings" exists and is queryable.');
    } catch (e) {
      print('Table "bookings" does NOT exist or is NOT accessible: $e');
    }
  });
}
