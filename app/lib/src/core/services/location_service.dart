import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? area;
  final bool isWithinPilot;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.area,
    this.isWithinPilot = false,
  });
}

class LocationService {
  /// ❄️ PILOT AREA FREEZE
  static const String pilotCity = "Ghaziabad";
  
  static Future<UserLocation> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    } 

    Position position = await Geolocator.getCurrentPosition();
    
    // Reverse Geocoding via Nominatim (Free)
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10&addressdetails=1');
    
    try {
      final response = await http.get(url, headers: {'User-Agent': 'BharatPoojaSetuApp'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final city = address['city'] ?? address['town'] ?? address['village'] ?? address['state_district'] ?? "Unknown City";
        final area = address['suburb'] ?? address['neighbourhood'] ?? address['residential'] ?? "";
        
        final isWithinPilot = city.toString().toLowerCase().contains(pilotCity.toLowerCase());

        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
          area: area,
          isWithinPilot: isWithinPilot,
        );
      }
    } catch (e) {
      // Fallback if network fails
    }

    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
