import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/services/location_service.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/features/location/state/location_provider.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'dart:async';

class LocationSelectionPage extends ConsumerStatefulWidget {
  final String mode; // home | temple | tirth | other

  const LocationSelectionPage({super.key, required this.mode});

  @override
  ConsumerState<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends ConsumerState<LocationSelectionPage> {
  bool _isDetecting = false;
  bool _isSearching = false;
  UserLocation? _detectedLocation;
  UserLocation? _selectedManualLocation;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  List<UserLocation> _filteredLocations = [];
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Removed automatic detection in favor of manual button
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isDetecting = true;
      _error = null;
    });

    try {
      final loc = await LocationService.getCurrentLocation();
      setState(() {
        _detectedLocation = loc;
        _isDetecting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isDetecting = false;
      });
    }
  }

  void _confirmAndProceed() {
    // Logic: Use selected manual location if present, otherwise detected
    final city = _selectedManualLocation?.city ?? _detectedLocation?.city ?? 'Ghaziabad';
    final lat = _selectedManualLocation?.latitude ?? _detectedLocation?.latitude;
    final lon = _selectedManualLocation?.longitude ?? _detectedLocation?.longitude;
    final area = _selectedManualLocation?.area ?? _detectedLocation?.area;

    final draft = BookingDraft(
      bookingType: widget.mode == 'temple' ? BookingType.temple : BookingType.home,
      ritualName: '', 
      city: city,
      latitude: lat,
      longitude: lon,
      area: area,
    );

    ref.read(bookingSessionProvider.notifier).updateBookingDraft(draft);
    
    // Sync with global location state
    ref.read(currentLocationProvider.notifier).state = LocationState(
      city: city,
      area: _detectedLocation?.area,
      latitude: _detectedLocation?.latitude,
      longitude: _detectedLocation?.longitude,
    );

    if (widget.mode == 'temple') {
      context.push('/temples/${Uri.encodeComponent(city)}');
    } else {
      context.push('/services');
    }
  }

  void _manuallySelectLocation(UserLocation loc) {
    setState(() {
      _selectedManualLocation = loc;
      _searchController.text = loc.city ?? loc.area ?? "";
      _filteredLocations = []; // Hide suggestions
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPilot = _detectedLocation?.isWithinPilot ?? false;
    final showRestriction = _detectedLocation != null && !isPilot && (widget.mode == 'home' || widget.mode == 'other');

    return AppScaffold(
      title: 'Location Service',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.mode == 'tirth' ? Icons.waves_rounded : Icons.location_on_rounded,
                size: 48,
                color: AppColors.saffron,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isDetecting ? "Detecting Sacred Space" : "Sacred Space Selection",
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 32),
            
            if (!_isDetecting && _detectedLocation == null && _error == null)
              GestureDetector(
                onTap: _detectLocation,
                child: PrimaryCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.my_location_rounded, color: AppColors.saffron, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Auto-Detect My Location',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.saffron, size: 14),
                    ],
                  ),
                ),
              ),
            
            if (_isDetecting)
              Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.saffron, strokeWidth: 3),
                  const SizedBox(height: 24),
                  Text(
                    "Finding your coordinates...", 
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.softGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else if (_error != null)
              PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      _error!, 
                      textAlign: TextAlign.center, 
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _error!.contains('permanently denied') 
                        ? LocationService.openSettings 
                        : _detectLocation,
                      child: Text(
                        _error!.contains('permanently denied') ? "Open App Settings" : "Try Again", 
                        style: AppTextStyles.button.copyWith(color: AppColors.saffron),
                      ),
                    )
                  ],
                ),
              )
            else if (_detectedLocation != null)
              PrimaryCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.softGreen, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          _detectedLocation!.city ?? "Location Found",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    if (_detectedLocation!.area != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _detectedLocation!.area!, 
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.softGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (showRestriction)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Pranaam! Abhi hum sirf Ghaziabad mein active hain. Jald hi aapke shehar bhi aayenge!",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.redAccent, 
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      )
                    else
                      Text(
                        "Aapka area pilot zone mein hai. Aap aage badh sakte hain.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.softGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 48),
            Text(
              "Or Type City Manually",
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter city name (e.g. Noida)',
                prefixIcon: const Icon(Icons.search, color: AppColors.saffron),
                filled: true,
                fillColor: AppColors.warmIvory,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.saffron.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.saffron.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.saffron, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () async {
                  if (value.length >= 3) {
                    setState(() => _isSearching = true);
                    final results = await LocationService.searchLocations(value);
                    setState(() {
                      _filteredLocations = results;
                      _isSearching = false;
                    });
                  } else {
                    setState(() {
                      _filteredLocations = [];
                      _isSearching = false;
                    });
                  }
                });
              },
            ),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator(color: AppColors.saffron, strokeWidth: 2)),
              ),

            if (_filteredLocations.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _filteredLocations[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.saffron),
                      title: Text(loc.area ?? loc.city ?? "Unknown Location"),
                      subtitle: Text("${loc.city ?? ""}${loc.state != null && loc.state!.isNotEmpty ? ", ${loc.state}" : ""}"),
                      onTap: () => _manuallySelectLocation(loc),
                    );
                  },
                ),
              ),
            const SizedBox(height: 48),
            Builder(
              builder: (ctx) {
                final canProceed = _isDetecting ? false : (_selectedManualLocation != null || (_detectedLocation != null && !showRestriction));

                return PrimaryButton(
                  label: "Confirm & Continue →",
                  onTap: canProceed ? _confirmAndProceed : null,
                  loading: false,
                  color: !canProceed ? AppColors.softGrey.withOpacity(0.3) : null,
                );
              }
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
}
