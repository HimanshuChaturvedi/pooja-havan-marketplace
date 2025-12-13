import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/pooja_flow/presentation/at_home_or_temple/at_home_or_temple_page.dart';
import '../../features/home_booking/presentation/home_booking_page.dart';
import '../../features/home_booking/presentation/address/home_address_page.dart';
import '../../features/home_booking/presentation/date_time/home_date_time_page.dart';
import '../../features/samagri_flow/presentation/requirement/samagri_requirement_page.dart';
import '../../features/samagri_flow/presentation/list/samagri_list_page.dart';
import '../../features/samagri_flow/presentation/cart/samagri_cart_page.dart';
import '../../features/home_booking/presentation/summary/booking_summary_page.dart';
import '../../features/payment/presentation/payment_page.dart';
import '../../features/payment/presentation/payment_success_page.dart';

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

    
// HOME OR TEMPLE CHOICE
GoRoute(
  path: '/at-home-or-temple',
  name: 'at-home-or-temple',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;

    return AtHomeOrTemplePage(
      city: extra['city'],
      ritualSlug: extra['ritualSlug'],
      ritualName: extra['ritualName'],
    );
  },
),

// HOME BOOKING (TEMP)
// HOME ADDRESS
GoRoute(
  path: '/home-address',
  name: 'home-address',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    return HomeAddressPage(
      city: extra['city'],
    );
  },
),


// HOME DATE & TIME
GoRoute(
  path: '/home-date-time',
  name: 'home-date-time',
  builder: (context, state) => const HomeDateTimePage(),
),

// SAMAGRI REQUIRED?
GoRoute(
  path: '/home-samagri',
  name: 'home-samagri',
  builder: (context, state) => const SamagriRequirementPage(),
),

// SAMAGRI LIST
GoRoute(
  path: '/samagri-list',
  name: 'samagri-list',
  builder: (context, state) => const SamagriListPage(),
),

// SAMAGRI CART
GoRoute(
  path: '/samagri-cart',
  name: 'samagri-cart',
  builder: (context, state) => const SamagriCartPage(),
),


// BOOKING SUMMARY
GoRoute(
  path: '/home-summary',
  name: 'home-summary',
  builder: (context, state) => const BookingSummaryPage(),
),

// PAYMENT
GoRoute(
  path: '/payment',
  name: 'payment',
  builder: (context, state) => const PaymentPage(),
),

// PAYMENT SUCCESS
GoRoute(
  path: '/payment-success',
  name: 'payment-success',
  builder: (context, state) => const PaymentSuccessPage(),
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
