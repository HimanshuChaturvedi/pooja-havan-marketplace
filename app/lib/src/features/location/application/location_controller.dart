import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/src/core/services/geocoding_service.dart';

enum LocationStatus { initial, loading, success, error }

class LocationState {
  final LocationStatus status;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? error;
  final bool isLoading;

  LocationState({
    this.status = LocationStatus.initial,
    this.city,
    this.latitude,
    this.longitude,
    this.error,
    this.isLoading = false,
  });

  LocationState copyWith({
    LocationStatus? status,
    String? city,
    double? latitude,
    double? longitude,
    String? error,
    bool? isLoading,
  }) {
    return LocationState(
      status: status ?? this.status,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationController extends StateNotifier<LocationState> {
  LocationController() : super(LocationState());

  Future<void> useCurrentLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final city = await GeocodingService.reverseGeocode(pos.latitude, pos.longitude);

      state = state.copyWith(
        isLoading: false,
        status: LocationStatus.success,
        city: city,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: LocationStatus.error,
        error: "Failed to detect location",
      );
    }
  }

  Future<void> setManualLocation({
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(status: LocationStatus.loading, isLoading: true);

    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      isLoading: false,
      status: LocationStatus.success,
      city: city,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationState>((ref) {
  return LocationController();
});
