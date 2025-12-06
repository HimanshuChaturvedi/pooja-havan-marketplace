import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/services/geocoding_service.dart';

typedef CitySelected = void Function(
  String city,
  double latitude,
  double longitude,
);

class CitySearchField extends StatefulWidget {
  final CitySelected onCitySelected;

  const CitySearchField({super.key, required this.onCitySelected});

  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  final TextEditingController _controller = TextEditingController();
  List<NominatimPlace> results = [];
  bool loading = false;

  Timer? _debounce; // for 400ms debounce

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Debounced search — runs only after user stops typing for 400ms
  void _onTextChanged(String text) {
    // cancel old timer
    _debounce?.cancel();

    // If empty — clear list instantly
    if (text.trim().isEmpty) {
      setState(() => results = []);
      return;
    }

    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(text);
    });
  }

  /// Actual API call (runs after debounce)
  Future<void> _search(String text) async {
    setState(() => loading = true);

    final response = await GeocodingService.searchCity(text);

    setState(() {
      results = response;
      loading = false;
    });
  }

  /// Handle city selection
  void _selectCity(NominatimPlace place) {
    widget.onCitySelected(
      place.displayName,
      double.parse(place.lat),
      double.parse(place.lon),
    );

    // Close dropdown + clear UI
    setState(() {
      results = [];
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onTextChanged, // <-- debounce applied here
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter city name",
            hintStyle: AppTextStyles.subtitle.copyWith(color: Colors.grey),
            suffixIcon: loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        if (results.isNotEmpty) const SizedBox(height: 8),

        if (results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 230),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final r = results[i];
                return ListTile(
                  title: Text(
                    r.displayName,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                  ),
                  onTap: () => _selectCity(r),
                );
              },
            ),
          ),
      ],
    );
  }
}
