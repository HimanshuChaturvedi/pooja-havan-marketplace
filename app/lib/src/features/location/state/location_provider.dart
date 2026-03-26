import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationState {
  final String city;
  final String? area;
  final double? latitude;
  final double? longitude;

  LocationState({
    required this.city,
    this.area,
    this.latitude,
    this.longitude,
  });

  factory LocationState.defaultLocation() {
    return LocationState(city: 'Ghaziabad');
  }
}

final currentLocationProvider = StateProvider<LocationState>((ref) => LocationState.defaultLocation());
