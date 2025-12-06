import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/services/presentation/services_page.dart';

import 'package:app/src/features/splash/presentation/splash_page.dart';
import 'package:app/src/features/landing/presentation/landing_page.dart';
import 'package:app/src/features/location/presentation/pages/location_page.dart';
import 'package:app/src/features/temple/presentation/pages/temple_list_page.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: false,
  initialLocation: SplashPage.routeName,
  routes: [
    GoRoute(
      path: SplashPage.routeName,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: LandingPage.routeName,
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),

    // ⭐⭐ INSERTED SERVICES ROUTE ⭐⭐
    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) => const ServicesPage(),
    ),
    // ⭐⭐ END INSERTION ⭐⭐

    // /location/pooja OR /location/samagri OR /location/temple
    GoRoute(
      path: '/location/:service',
      name: 'location',
      builder: (context, state) {
        final service = state.pathParameters['service'] ?? 'pooja';
        return LocationPage(serviceType: service);
      },
    ),

    // /temples/<cityName>
    GoRoute(
      path: '/temples/:city',
      name: 'temples',
      builder: (context, state) {
        final cityEncoded = state.pathParameters['city'] ?? '';
        final city = Uri.decodeComponent(cityEncoded);
        return TempleListPage(city: city);
      },
    ),

    // Placeholder Home
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(
            'Home / Dashboard (Coming Soon)',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    ),
  ],
);
