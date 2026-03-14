import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/services/location_service.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/features/booking/domain/booking_draft.dart';
import 'package:app/src/core/widgets/design_system.dart';

class LocationSelectionPage extends ConsumerStatefulWidget {
  final String mode; // home | temple | tirth | other

  const LocationSelectionPage({super.key, required this.mode});

  @override
  ConsumerState<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends ConsumerState<LocationSelectionPage> {
  bool _isDetecting = false;
  UserLocation? _detectedLocation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detectLocation();
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
    if (_detectedLocation == null && widget.mode != 'temple') return;
    final city = _detectedLocation?.city ?? 'Ghaziabad';

    final draft = BookingDraft(
      bookingType: widget.mode == 'temple' ? BookingType.temple : BookingType.home,
      ritualName: '', 
      city: city,
      latitude: _detectedLocation?.latitude,
      longitude: _detectedLocation?.longitude,
      area: _detectedLocation?.area,
    );

    ref.read(bookingSessionProvider.notifier).updateBookingDraft(draft);

    if (widget.mode == 'temple') {
      context.push('/temples/${Uri.encodeComponent(city)}');
    } else {
      context.push('/services');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPilot = _detectedLocation?.isWithinPilot ?? false;
    final showRestriction = _detectedLocation != null && !isPilot && (widget.mode == 'home' || widget.mode == 'other');

    return AppScaffold(
      title: 'Location Service',
      body: Padding(
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
              "Detecting Sacred Space",
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 32),
            
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
                      onPressed: _detectLocation, 
                      child: Text(
                        "Try Again", 
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

            const Spacer(),
            PrimaryButton(
              label: "Confirm & Continue →",
              onTap: (_isDetecting || showRestriction) ? () {} : _confirmAndProceed,
              loading: false,
              color: (_isDetecting || showRestriction) ? AppColors.softGrey.withOpacity(0.3) : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
