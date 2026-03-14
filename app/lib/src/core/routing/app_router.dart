import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/state/booking_session_notifier.dart';

import '../../features/booking/application/booking_session.dart';
import '../supabase/supabase_client.dart';

import '../../features/splash/presentation/splash_page.dart';
import '../../features/landing/presentation/landing_page.dart';
import '../../theme/components/app_colors.dart';
import '../../theme/components/app_text_styles.dart';
import '../../core/widgets/design_system.dart';
import '../../features/services/presentation/services_page.dart';
import '../../features/services/presentation/pooja_details_page.dart';
import '../../features/location/presentation/pages/location_page.dart';
import '../../features/services/presentation/booking_mode_page.dart'; // [NEW]
import '../../features/services/presentation/location_selection_page.dart'; // [NEW]

import '../../features/pooja_flow/presentation/at_home_or_temple/at_home_or_temple_page.dart';

import '../../features/home_booking/presentation/address/home_address_page.dart';
import '../../features/home_booking/presentation/date_time/home_date_time_page.dart';
import '../../features/home_booking/presentation/summary/booking_summary_page.dart';

import '../../features/samagri_flow/presentation/requirement/samagri_requirement_page.dart';
import '../../features/samagri_flow/presentation/list/samagri_list_page.dart';

import '../../features/samagri_flow/presentation/summary/samagri_summary_page.dart';
import '../../features/samagri_flow/presentation/address/samagri_address_page.dart';

import '../../features/booking/presentation/payment_page.dart';
import '../../features/booking/presentation/booking_success_page.dart';

import '../../features/temple/presentation/pages/temple_list_page.dart';
import '../../features/temple/presentation/pages/temple_details_page.dart';
import '../../features/temple/presentation/pages/temple_city_page.dart';
import '../../features/temple/presentation/pages/temple_selection_page.dart';
import '../../features/temple/presentation/pages/temple_ritual_page.dart';
import '../../features/temple/presentation/pages/temple_date_page.dart';
import '../../features/temple/presentation/pages/temple_summary_page.dart';

import '../../features/pandit/presentation/pages/pandit_selection_page.dart';
import '../../features/pandit/presentation/pages/pandit_details_page.dart';

import '../../features/services/domain/explore_service.dart';
import '../../features/services/presentation/explore_service_detail_page.dart';
import '../../features/booking/domain/booking_draft.dart';
import '../../features/bookings/presentation/booking_detail_page.dart';
import '../../features/bookings/presentation/my_bookings_page.dart';
import '../../features/samagri_flow/presentation/success/samagri_success_page.dart';
import '../../features/samagri_flow/presentation/address/samagri_delivery_address_page.dart';
import '../../features/auth/presentation/login_page.dart';


import '../../features/landing/presentation/landing_enhanced_page.dart';
import '../../features/main/presentation/pages/main_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
            onPressed: () => context.go('/'),
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

    // LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final redirectTo = state.uri.queryParameters['redirectTo'];
        return LoginPage(redirectTo: redirectTo);
      },
    ),
    // LANDING
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainPage(),
    ),

    // SHOP REDIRECT
    GoRoute(
      path: '/shop',
      redirect: (context, state) => '/landing',
    ),

    // SERVICES
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesPage(),
    ),

    // BOOKING MODE (NEW)
    GoRoute(
      path: '/booking-mode',
      builder: (context, state) => const BookingModePage(),
    ),

    // LOCATION SELECTION (NEW)
    GoRoute(
      path: '/location-selection',
      builder: (context, state) {
        final mode = state.uri.queryParameters['type'] ?? 'home';
        return LocationSelectionPage(mode: mode);
      },
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

    // SERVICE DETAILS (BY NAME)
    GoRoute(
      path: '/ritual/:name',
      name: 'ritual-detail',
      builder: (context, state) {
        final name = Uri.decodeComponent(state.pathParameters['name']!);
        return PoojaDetailsPage(
          poojaSlug: name.toLowerCase().replaceAll(' ', '-'),
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
        final booking = ref.read(bookingSessionProvider).current;
        if (booking == null) {
          return '/landing';
        }
        return '/services';
      },
    ),

    // AT HOME / AT TEMPLE
    GoRoute(
      path: '/at-home-or-temple',
      builder: (context, state) {
        final booking = ref.read(bookingSessionProvider).current;
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
        final booking = ref.read(bookingSessionProvider).current;
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

    // BOOKING PAYMENT (GUARDED)
    GoRoute(
      path: '/payment',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous || (user.email?.isEmpty ?? true)) {
          return '/login?redirectTo=/payment';
        }
        return null;
      },
      builder: (context, state) => const PaymentPage(),
    ),

    // BOOKING SUCCESS (GUARDED)
    GoRoute(
      path: '/booking-success',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous || (user.email?.isEmpty ?? true)) {
          return '/login';
        }
        return null;
      },
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
        final booking = ref.read(bookingSessionProvider).current;
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
      path: '/bookings',
      name: 'bookings',
      builder: (context, state) => const MyBookingsPage(),
    ),
    GoRoute(
      path: '/booking-detail',
      name: 'booking-detail',
      builder: (context, state) {
        final booking = state.extra as BookingDraft;
        return BookingDetailPage(booking: booking);
      },
    ),
    // SAMAGRI SUCCESS (GUARDED)
    GoRoute(
      path: '/samagri-success',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous || (user.email?.isEmpty ?? true)) {
          return '/login?redirectTo=/samagri-summary';
        }
        return null;
      },
      builder: (context, state) => const SamagriSuccessPage(),
    ),
    GoRoute(
      path: '/samagri-delivery-address',
      builder: (context, state) => const SamagriDeliveryAddressPage(),
    ),



    // EXPLORE SERVICES
    GoRoute(
      path: '/explore-services',
      builder: (context, state) {
        return AppScaffold(
          title: 'Explore Offerings',
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: exploreServices.length,
            itemBuilder: (context, index) {
              final service = exploreServices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PrimaryCard(
                  padding: const EdgeInsets.all(20),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      service.title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        service.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.softGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded, color: AppColors.saffron),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ExploreServiceDetailPage(service: service),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
    // TEMPLE FLOW
    GoRoute(
      path: '/temple-services',
      builder: (context, state) => const TempleCityPage(),
    ),
    GoRoute(
      path: '/temple-select',
      builder: (context, state) {
        final city = state.uri.queryParameters['city'] ?? 'Ghaziabad';
        return TempleSelectionPage(city: city);
      },
    ),
    GoRoute(
      path: '/temple-ritual',
      builder: (context, state) {
        final temple = state.uri.queryParameters['temple'] ?? '';
        final city = state.uri.queryParameters['city'] ?? '';
        return TempleRitualPage(temple: temple, city: city);
      },
    ),
    GoRoute(
      path: '/temple-date',
      builder: (context, state) {
        final temple = state.uri.queryParameters['temple'] ?? '';
        final city = state.uri.queryParameters['city'] ?? '';
        final ritual = state.uri.queryParameters['ritual'] ?? '';
        return TempleDatePage(temple: temple, city: city, ritual: ritual);
      },
    ),
    GoRoute(
      path: '/temple-summary',
      builder: (context, state) {
        final temple = state.uri.queryParameters['temple'] ?? '';
        final city = state.uri.queryParameters['city'] ?? '';
        final ritual = state.uri.queryParameters['ritual'] ?? '';
        final date = state.uri.queryParameters['date'] ?? '';
        final slot = state.uri.queryParameters['slot'] ?? '';
        return TempleSummaryPage(temple: temple, city: city, ritual: ritual, date: date, slot: slot);
      },
    ),
  ],
);
});
