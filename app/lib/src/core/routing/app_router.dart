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
import '../../features/pandit_onboarding/presentation/pandit_onboarding_page.dart'; // [NEW]
import '../../features/pandit_onboarding/presentation/pandit_pending_approval_page.dart'; // [NEW]
import '../../features/pandit_dashboard/presentation/pandit_dashboard_page.dart'; // [NEW]
import '../../features/admin/presentation/admin_verification_page.dart'; // [NEW]
import '../../features/samagri_vendor/presentation/vendor_dashboard_page.dart'; // [NEW]
import '../../features/samagri_vendor/presentation/vendor_registration_page.dart'; // [NEW]
import '../../features/samagri_vendor/presentation/vendor_pending_page.dart'; // [NEW]
import '../../features/auth/presentation/state/auth_provider_impl.dart'; // [NEW]
import '../../features/landing/presentation/landing_enhanced_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/pandit_onboarding/data/pandit_repository_provider.dart';
import '../../features/main/presentation/pages/personal_details_page.dart';
import '../../features/main/presentation/pages/saved_addresses_page.dart';
import '../../features/main/presentation/pages/notifications_settings_page.dart';
import '../../features/main/presentation/pages/support_help_page.dart';

Future<String?> _panditGuard(BuildContext context, GoRouterState state, ProviderRef ref) async {
  final user = supabase.auth.currentUser;
  if (user != null) {
      final repo = ref.read(panditRepositoryProvider);
      final profile = await repo.getPanditProfile(user.id);
      if (profile != null) {
          if (profile.verificationStatus.name.toUpperCase() == 'PENDING') {
              return '/pandit-pending';
          } else if (profile.verificationStatus.name.toUpperCase() == 'VERIFIED') {
              // If they explicitly want to go to /home, allow it maybe? 
              // Actually, force them to Dashboard for now to keep the MVP role separated.
              // If we are already on /pandit-dashboard, don't redirect again in a loop!
              if (state.uri.path != '/pandit-dashboard') {
                return '/pandit-dashboard';
              }
          }
      }
  }
  return null;
}

Future<String?> _vendorGuard(BuildContext context, GoRouterState state, ProviderRef ref) async {
  final user = supabase.auth.currentUser;
  if (user != null) {
      // Check if user has a shop in samagri_vendors
      final shop = await supabase.from('samagri_vendors').select('verification_status').eq('owner_id', user.id).maybeSingle();
      if (shop != null) {
          final status = (shop['verification_status'] as String).toUpperCase();
          if (status == 'PENDING') {
              if (state.uri.path != '/vendor-pending') return '/vendor-pending';
          } else if (status == 'VERIFIED') {
              if (state.uri.path != '/vendor-dashboard') return '/vendor-dashboard';
          }
      }
  }
  return null;
}

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
    
    // PANDIT ONBOARDING (NEW)
    GoRoute(
      path: '/pandit-onboarding',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login?redirectTo=/pandit-onboarding';
        return null;
      },
      builder: (context, state) => const PanditOnboardingPage(),
    ),
    
    // PANDIT PENDING APPROVAL (NEW)
    GoRoute(
      path: '/pandit-pending',
      builder: (context, state) => const PanditPendingApprovalPage(),
    ),

    GoRoute(
      path: '/pandit-dashboard',
      name: 'panditDashboard',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login';
        return null;
      },
      builder: (context, state) => const PanditDashboardPage(),
    ),
    
    GoRoute(
      path: '/vendor-dashboard',
      name: 'vendorDashboard',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login';
        return null;
      },
      builder: (context, state) => const VendorDashboardPage(),
    ),

    GoRoute(
      path: '/vendor-registration',
      name: 'vendorRegistration',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login?redirectTo=/vendor-registration';
        return null;
      },
      builder: (context, state) => const VendorRegistrationPage(),
    ),

    GoRoute(
      path: '/vendor-pending',
      name: 'vendorPending',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login';
        return null;
      },
      builder: (context, state) => const VendorPendingPage(),
    ),

    GoRoute(
      path: '/admin-portal',
      name: 'adminPortal',
      builder: (context, state) => const AdminVerificationPage(),
      redirect: (context, state) {
        final isAdmin = ref.read(isAdminProvider);
        if (!isAdmin) return '/home';
        return null;
      },
    ),

    GoRoute(
      path: '/personal-details',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login?redirectTo=/personal-details';
        return null;
      },
      builder: (context, state) => const PersonalDetailsPage(),
    ),

    GoRoute(
      path: '/saved-addresses',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login?redirectTo=/saved-addresses';
        return null;
      },
      builder: (context, state) => const SavedAddressesPage(),
    ),

    GoRoute(
      path: '/notifications',
      redirect: (context, state) {
        final user = supabase.auth.currentUser;
        if (user == null || user.isAnonymous) return '/login?redirectTo=/notifications';
        return null;
      },
      builder: (context, state) => const NotificationsSettingsPage(),
    ),

    GoRoute(
      path: '/support-help',
      builder: (context, state) => const SupportHelpPage(),
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
