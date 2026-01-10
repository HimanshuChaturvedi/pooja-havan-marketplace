import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/application/booking_session.dart';

import '../../features/splash/presentation/splash_page.dart';
import '../../features/landing/presentation/landing_page.dart';
import '../../features/services/presentation/services_page.dart';
import '../../features/services/presentation/pooja_details_page.dart';
import '../../features/location/presentation/pages/location_page.dart';

import '../../features/pooja_flow/presentation/at_home_or_temple/at_home_or_temple_page.dart';

import '../../features/home_booking/presentation/address/home_address_page.dart';
import '../../features/home_booking/presentation/date_time/home_date_time_page.dart';
import '../../features/home_booking/presentation/summary/booking_summary_page.dart';

import '../../features/samagri_flow/presentation/requirement/samagri_requirement_page.dart';
import '../../features/samagri_flow/presentation/list/samagri_list_page.dart';
import '../../features/samagri_flow/presentation/cart/samagri_cart_page.dart';
import '../../features/samagri_flow/presentation/summary/samagri_summary_page.dart';
import '../../features/samagri_flow/presentation/address/samagri_address_page.dart';

import '../../features/booking/presentation/payment_page.dart';
import '../../features/booking/presentation/booking_success_page.dart';

import '../../features/temple/presentation/pages/temple_list_page.dart';
import '../../features/temple/presentation/pages/temple_details_page.dart';

import '../../features/pandit/presentation/pages/pandit_selection_page.dart';
import '../../features/pandit/presentation/pages/pandit_details_page.dart';

import '../../features/services/domain/explore_service.dart';
import '../../features/services/presentation/explore_service_detail_page.dart';
import '../../features/activity/presentation/my_activity_page.dart';
import '../../features/samagri_flow/presentation/success/samagri_success_page.dart';



final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/splash',

  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Oops! That page doesn't exist."),
          TextButton(
            onPressed: () => context.go('/landing'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),

  routes: [
    // SPLASH
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),

    // LANDING
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),

    // SERVICES
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesPage(),
    ),

    // SERVICE DETAILS
    GoRoute(
      path: '/service/:slug/:name',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final name = Uri.decodeComponent(state.pathParameters['name']!);
        return PoojaDetailsPage(
          poojaSlug: slug,
          poojaName: name,
        );
      },
    ),

    // LOCATION
    GoRoute(
      path: '/location/:slug/:name',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final name = Uri.decodeComponent(state.pathParameters['name']!);
        return LocationPage(
          ritualSlug: slug,
          ritualName: name,
        );
      },
    ),

    // START BOOKING (SAFE)
    GoRoute(
      path: '/start-booking',
      redirect: (context, state) {
        if (BookingSession.current == null) {
          return '/landing';
        }
        return '/services';
      },
    ),

    // AT HOME / AT TEMPLE
    GoRoute(
      path: '/at-home-or-temple',
      builder: (context, state) {
        final booking = BookingSession.current;
        if (booking == null) {
          return const Scaffold(
            body: Center(child: Text('No booking found')),
          );
        }
        return AtHomeOrTemplePage(
          city: booking.city,
          ritualSlug: booking.ritualName,
          ritualName: booking.ritualName,
        );
      },
    ),

    // HOME ADDRESS
    GoRoute(
      path: '/home-address',
      builder: (context, state) {
        final booking = BookingSession.current;
        if (booking == null) {
          return const Scaffold(
            body: Center(child: Text('No booking found')),
          );
        }
        return HomeAddressPage(city: booking.city);
      },
    ),

    // DATE & TIME
    GoRoute(
      path: '/home-date-time',
      builder: (context, state) => const HomeDateTimePage(),
    ),

    // BOOKING SUMMARY
    GoRoute(
      path: '/home-summary',
      builder: (context, state) => const BookingSummaryPage(),
    ),

    // BOOKING PAYMENT
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentPage(),
    ),

    // BOOKING SUCCESS
    GoRoute(
      path: '/booking-success',
      builder: (context, state) => const BookingSuccessPage(),
    ),

    // SAMAGRI REQUIRED
    GoRoute(
      path: '/samagri-required',
      builder: (context, state) => const SamagriRequirementPage(),
    ),

    // SAMAGRI LIST
    GoRoute(
      path: '/samagri-list',
      builder: (context, state) => const SamagriListPage(),
    ),

    // SAMAGRI CART
    GoRoute(
      path: '/samagri-cart',
      builder: (context, state) => const SamagriCartPage(),
    ),

    // SAMAGRI SUMMARY (NO GUARDS)
    GoRoute(
      path: '/samagri-summary',
      builder: (context, state) => const SamagriSummaryPage(),
    ),

    // SAMAGRI ADDRESS (NO GUARDS)
    GoRoute(
      path: '/samagri-address',
      builder: (context, state) => const SamagriAddressPage(),
    ),

    // TEMPLE LIST
    GoRoute(
      path: '/temples/:city',
      builder: (context, state) {
        final city = Uri.decodeComponent(state.pathParameters['city']!);
        return TempleListPage(city: city);
      },
    ),

    // TEMPLE DETAILS
    GoRoute(
      path: '/temple-details',
      builder: (context, state) => const TempleDetailsPage(),
    ),

    // TEMPLE DATE & TIME
    GoRoute(
      path: '/temple-date-time',
      builder: (context, state) => const HomeDateTimePage(),
    ),

    // PANDIT SELECTION
    GoRoute(
      path: '/pandit-selection',
      builder: (context, state) {
        final booking = BookingSession.current;
        if (booking == null) {
          return const Scaffold(
            body: Center(child: Text('No booking found')),
          );
        }
        return PanditSelectionPage(
          templeName: booking.templeName ?? '',
        );
      },
    ),

    GoRoute(
      path: '/pandit-details',
      builder: (context, state) {
        final panditName = state.extra as String;
        return PanditDetailsPage(panditName: panditName);
      },
    ),

    GoRoute(
  path: '/my-activity',
  builder: (context, state) => const MyActivityPage(),
),
GoRoute(
  path: '/samagri-success',
  builder: (context, state) =>
      const SamagriSuccessPage(),
),



    // EXPLORE SERVICES
    GoRoute(
      path: '/explore-services',
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Explore Services')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exploreServices.length,
            itemBuilder: (context, index) {
              final service = exploreServices[index];
              return Card(
                child: ListTile(
                  title: Text(service.title),
                  subtitle: Text(service.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ExploreServiceDetailPage(service: service),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    ),
  ],
);
