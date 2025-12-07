// lib/src/features/location/presentation/pages/location_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';

class LocationPage extends StatefulWidget {
  final String ritualSlug;
  final String ritualName;

  const LocationPage({
    super.key,
    required this.ritualSlug,
    required this.ritualName,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedCity = "";

  List<String> suggestions = [
    "Haridwar",
    "Rishikesh",
    "Varanasi",
    "Ayodhya",
    "Prayagraj",
    "Mathura",
    "Ujjain",
  ];

  // -------------------------------------------------------------------
  // Fetch city name from coordinates using Nominatim
  // -------------------------------------------------------------------
  Future<String?> _getCityFromCoordinates(double lat, double lon) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json";

    final response = await http.get(Uri.parse(url), headers: {
      "User-Agent": "Flutter-App",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["address"]["city"] ??
          data["address"]["town"] ??
          data["address"]["village"];
    }

    return null;
  }

  // -------------------------------------------------------------------
  // Detect location
  // -------------------------------------------------------------------
  Future<void> _detectLocation() async {
  // Check if location service is ON
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enable Location Services")),
    );
    return;
  }

  // Check permissions
  LocationPermission perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }
  }

  if (perm == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enable location permission from settings")),
    );
    return;
  }

  // Get coordinates
  final position = await Geolocator.getCurrentPosition();

  // Convert to city
  final city =
      await _getCityFromCoordinates(position.latitude, position.longitude);

  if (!mounted) return;

  if (city == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not detect city")),
    );
    return;
  }

  // Update UI
  setState(() {
    selectedCity = city;
  });

  // ⭐ AUTO-NAVIGATE TO TEMPLE LIST PAGE
  final encodedCity = Uri.encodeComponent(city);
  context.push('/temples/$encodedCity');
}


  // -------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.saffron,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Select Location",
          style: AppTextStyles.title.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/landing'),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "For ${widget.ritualName}",
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            // MAIN WHITE CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DETECT LOCATION BUTTON
                  GestureDetector(
                    onTap: _detectLocation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Detect My Location",
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (selectedCity.isNotEmpty)
                    Text(
                      "Detected: $selectedCity",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),

                  const SizedBox(height: 22),

                  // SEARCH FIELD
                  TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Enter city name...",
                      hintStyle: AppTextStyles.subtitle.copyWith(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CITY SUGGESTIONS
                  Column(
                    children: suggestions
                        .where((c) => c
                            .toLowerCase()
                            .contains(_controller.text.toLowerCase()))
                        .map(
                          (city) => GestureDetector(
                            onTap: () {
                              final encoded = Uri.encodeComponent(city);
                              context.push('/temples/$encoded');
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                city,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
