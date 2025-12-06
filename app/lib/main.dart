import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/routing/app_router.dart';
import 'src/theme/components/app_theme.dart';

void main() {
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
