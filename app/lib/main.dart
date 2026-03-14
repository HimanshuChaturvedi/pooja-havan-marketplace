import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/core/routing/app_router.dart';
import 'src/theme/components/app_theme.dart';
import 'src/logs/transaction_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 INIT TRANSACTION LOG PERSISTENCE (STEP-2)
  await TransactionLogService.init();

  // 🔒 SUPABASE INIT with typo fix
  // Original: https://xzmeksjsjitxvknfbfkx.supabase.co
  // Correct (based on API Key ref): https://xzmekcjsjixtvknfbfkx.supabase.co
  await Supabase.initialize(
    url: 'https://xzmekcjsjixtvknfbfkx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
  );

  // 🔒 ANONYMOUS AUTH — gives each device a persistent real UUID
  // This fixes: RLS policies, user_id in inserts, and data scoping
  // Works silently — no login screen needed
  try {
    final existingSession = Supabase.instance.client.auth.currentSession;
    if (existingSession == null) {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint('✅ Anonymous session created: ${Supabase.instance.client.auth.currentUser?.id}');
    } else {
      debugPrint('✅ Existing session restored: ${Supabase.instance.client.auth.currentUser?.id}');
    }
  } catch (e) {
    debugPrint('⚠️ Anonymous auth failed (app still works): $e');
  }

  // 🧪 CONNECTION VERIFICATION
  try {
    debugPrint('⚡ Connecting to Supabase...');
    final response = await Supabase.instance.client.from('cities').select('id').limit(1);
    debugPrint('✅ Supabase Connection Verified: ${response.isNotEmpty ? "Success" : "Empty Table"}');
  } catch (e) {
    debugPrint('❌ Supabase Connection Failed: $e');
    if (e.toString().contains('Failed host lookup')) {
      debugPrint('👉 TIP: Check your Internet connection and verify the Project URL in main.dart');
    }
  }

  runApp(
    const ProviderScope(
      child: PoojaHavanApp(),
    ),
  );
}

class PoojaHavanApp extends ConsumerWidget {
  const PoojaHavanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pooja Havan App',
      routerConfig: router,
      theme: buildAppTheme(),
    );
  }
}
