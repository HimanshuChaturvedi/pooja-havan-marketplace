import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? area;
  final String? state; // Added state field
  final bool isWithinPilot;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.area,
    this.state,
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
        final state = address['state'] ?? ""; // Extract state
        
        final isWithinPilot = city.toString().toLowerCase().contains(pilotCity.toLowerCase());

        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
          area: area,
          state: state,
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

  static Future<List<UserLocation>> searchLocations(String query, {String? cityContext}) async {
    if (query.length < 3) return [];
    
    // If cityContext is provided, append it to the query for better accuracy
    final fullQuery = cityContext != null ? "$query, $cityContext" : query;
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(fullQuery)}&format=json&addressdetails=1&limit=5&countrycodes=in');
    
    try {
      final response = await http.get(url, headers: {'User-Agent': 'BharatPoojaSetuApp'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final Map<String, UserLocation> uniqueResults = {};

        for (var item in data) {
          final address = item['address'];
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['state_district'] ?? "Unknown";
          final state = address['state'] ?? "";
          final area = item['display_name'].split(',')[0];
          
          final key = "${area}_${city}_${state}".toLowerCase().trim();
          
          if (!uniqueResults.containsKey(key)) {
            final isWithinPilot = city.toString().toLowerCase().contains(pilotCity.toLowerCase());
            uniqueResults[key] = UserLocation(
              latitude: double.parse(item['lat']),
              longitude: double.parse(item['lon']),
              city: city,
              area: area,
              state: state,
              isWithinPilot: isWithinPilot,
            );
          }
        }
        return uniqueResults.values.toList();
      }
    } catch (e) {
      // Return empty list on failure
    }
    return [];
  }

  static Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }
}
