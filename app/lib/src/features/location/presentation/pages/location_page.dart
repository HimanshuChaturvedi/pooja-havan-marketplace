import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/shared/widgets/primary_button.dart';
import 'package:app/src/features/location/presentation/widgets/city_search_field.dart';
import 'package:app/src/features/location/application/location_controller.dart';

class LocationPage extends ConsumerWidget {
  static const routeNameBase = '/location';
  final String serviceType; // e.g. 'pooja', 'samagri', 'temple', 'explore'

  LocationPage({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationControllerProvider);
    final controller = ref.read(locationControllerProvider.notifier);

    // dynamic heading
    String heading;
    switch (serviceType) {
      case 'samagri':
        heading = 'Where should we deliver the samagri?';
        break;
      case 'temple':
        heading = 'Where do you want to perform the Havan?';
        break;
      case 'explore':
        heading = 'Where do you need this service?';
        break;
      default:
        heading = 'Where do you want the pooja performed?';
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.saffronLight, AppColors.saffronDark.withOpacity(0.9)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(heading, style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 8),
              Text('We will show providers available for this service in the chosen location.', style: AppTextStyles.subtitle.copyWith(color: Colors.white70)),
              const SizedBox(height: 20),

              // Current location
              PrimaryButton(
                text: state.isLoading ? 'Detecting...' : 'Use Current Location',
                onPressed: state.isLoading
                    ? () {}
                    : () async {
                        await controller.useCurrentLocation();
                        if (ref.read(locationControllerProvider).status == LocationStatus.success) {
                          // if temple service → go to temples list for the detected city
                          final city = ref.read(locationControllerProvider).city ?? '';
                          if (serviceType == 'temple') {
                            GoRouter.of(context).go('/temples/${Uri.encodeComponent(city)}');
                          } else {
                            // for now go to home placeholder
                            GoRouter.of(context).go('/home');
                          }
                        }
                      },
              ),

              const SizedBox(height: 18),

              Center(child: Text('or', style: AppTextStyles.subtitle.copyWith(color: Colors.white70))),
              const SizedBox(height: 18),

              // Manual city input — city_search_field clears itself on selection
              CitySearchField(
                onCitySelected: (city, lat, lon) {
                  // update state
                  controller.setManualLocation(city: city, latitude: lat, longitude: lon);
                  // navigate based on serviceType
                  if (serviceType == 'temple') {
                    GoRouter.of(context).go('/temples/${Uri.encodeComponent(city)}');
                  } else {
                    GoRouter.of(context).go('/home');
                  }
                },
              ),

              const SizedBox(height: 20),

              if (state.error != null)
                Text(state.error!, style: AppTextStyles.subtitle.copyWith(color: Colors.redAccent)),

              if (state.status == LocationStatus.success && state.city != null) ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                  child: Text('Selected: ${state.city}', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
