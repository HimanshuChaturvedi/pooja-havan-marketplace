import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('List all verified pandits', () async {
    final supabase = SupabaseClient(
      'https://xzmekcjsjixtvknfbfkx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
    );

    print('--- ALL VERIFIED PANDITS ---');
    try {
      final pandits = await supabase
          .from('pandit_profiles')
          .select('id, first_name, last_name, verification_status')
          .eq('verification_status', 'VERIFIED');
      
      for (var p in pandits) {
        print('ID: ${p['id']} | Name: ${p['first_name']} ${p['last_name']}');
      }
      
      print('\n--- ALL PANDITS (ANY STATUS) ---');
      final allPandits = await supabase
          .from('pandit_profiles')
          .select('id, first_name, last_name, verification_status');
      
      for (var p in allPandits) {
         print('ID: ${p['id']} | Name: ${p['first_name']} ${p['last_name']} | Status: ${p['verification_status']}');
      }

    } catch (e) {
      print('Error: $e');
    }
  });
}
