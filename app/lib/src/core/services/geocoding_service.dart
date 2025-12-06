import 'dart:convert';
import 'package:http/http.dart' as http;

/// Represents a place returned by Nominatim API.
class NominatimPlace {
  final String displayName;
  final String lat;
  final String lon;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json["display_name"] ?? "",
      lat: json["lat"] ?? "0",
      lon: json["lon"] ?? "0",
    );
  }
}

class GeocodingService {
  static const String _baseUrl = "https://nominatim.openstreetmap.org";

  /// Search for Indian cities ONLY
  static Future<List<NominatimPlace>> searchCity(String query) async {
    final url = Uri.parse(
      "$_baseUrl/search?q=$query&format=json&addressdetails=1"
      "&countrycodes=in&limit=10",
    );

    final response = await http.get(
      url,
      headers: {
        "User-Agent": "PoojaHavanApp/1.0 (himanshu@example.com)",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      return decoded.map((e) => NominatimPlace.fromJson(e)).toList();
    }

    return [];
  }

  /// Reverse geocode coordinates → get the city name
  static Future<String> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      "$_baseUrl/reverse?lat=$lat&lon=$lon&format=json&zoom=10"
      "&addressdetails=1",
    );

    final response = await http.get(
      url,
      headers: {
        "User-Agent": "PoojaHavanApp/1.0 (himanshu@example.com)",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final address = json["address"];

      // Try to extract city/town/village
      return address["city"] ??
          address["town"] ??
          address["village"] ??
          "Unknown Location";
    }

    return "Unknown Location";
  }
}
