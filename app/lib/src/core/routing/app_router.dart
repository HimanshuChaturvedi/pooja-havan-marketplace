import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_page.dart';
import '../../features/landing/presentation/landing_page.dart';
import '../../features/services/presentation/services_page.dart';
import '../../features/services/presentation/pooja_details_page.dart';
import '../../features/location/presentation/pages/location_page.dart';
import '../../features/temple/presentation/pages/temple_list_page.dart';
import '../../features/pandit/presentation/pages/pandit_list_page.dart';


final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/splash',

  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text("Page Not Found")),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Oops! That page doesn't exist."),
          TextButton(
            onPressed: () => context.go('/landing'),
            child: const Text("Go to Home"),
          ),
        ],
      ),
    ),
  ),

  routes: [
    // SPLASH
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // LANDING / HOME
    GoRoute(
      path: '/landing',
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),

    // SERVICES LIST
    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) => const ServicesPage(),
    ),

    // SERVICE DETAILS
    GoRoute(
      path: '/service/:slug/:name',
      name: 'service-details',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final name = Uri.decodeComponent(state.pathParameters['name']!);

        return PoojaDetailsPage(
          poojaSlug: slug,
          poojaName: name,
        );
      },
    ),

    // LOCATION (AFTER DETAILS PAGE)
    GoRoute(
      path: '/location/:slug/:name',
      name: 'location',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final name = Uri.decodeComponent(state.pathParameters['name']!);

        return LocationPage(
          ritualSlug: slug,
          ritualName: name,
        );
      },
    ),

    // TEMPLES LIST
    GoRoute(
      path: '/temples/:city',
      name: 'temples',
      builder: (context, state) {
        final city = Uri.decodeComponent(state.pathParameters['city']!);
        return TempleListPage(city: city);
      },
    ),
    GoRoute(
  path: '/pandits/:temple',
  name: 'pandits',
  builder: (context, state) {
    final temple = Uri.decodeComponent(state.pathParameters['temple']!);
    return PanditListPage(templeName: temple);
  },
),

  ],
);
