import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/core/routing/app_router.dart';
import 'src/theme/components/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xzmeksjsjitxvknfbfkx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6bWVrY2pzaml4dHZrbmZiZmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYxNDU0MzcsImV4cCI6MjA4MTcyMTQzN30.JhwtwgCpsABdiO6M6MTzpd2jYzA8MBe2ZJajaree7kc',
  );

  runApp(
    const ProviderScope(
      child: PoojaHavanApp(),
    ),
  );
}

class PoojaHavanApp extends StatelessWidget {
  const PoojaHavanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pooja Havan App',
      routerConfig: appRouter,
      theme: buildAppTheme(),
    );
  }
}
