import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/booking/state/booking_session_notifier.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/core/services/location_service.dart';
import 'package:app/src/features/home_booking/presentation/address/state/address_provider.dart';
import 'dart:async';

import 'package:app/src/features/home_booking/presentation/address/domain/address.dart';

class HomeAddressPage extends ConsumerStatefulWidget {
  final String city;
  final void Function(Address address)? onAddressSaved;

  const HomeAddressPage({
    super.key,
    required this.city,
    this.onAddressSaved,
  });

  @override
  ConsumerState<HomeAddressPage> createState() => _HomeAddressPageState();
}

class _HomeAddressPageState extends ConsumerState<HomeAddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'Ghaziabad';
  bool _showManualForm = false;
  bool _isDetecting = false;
  bool _isSearching = false;
  UserLocation? _selectedLocation;
  List<UserLocation> _suggestions = [];
  Timer? _debounce;
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  List<String> _serviceCities = [
    'Ghaziabad',
    'Noida',
    'Delhi NCR',
    'Greater Noida',
  ];

  bool get _isFormValid =>
      _addressController.text.trim().isNotEmpty && _selectedCity.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.city.isNotEmpty ? widget.city : 'Ghaziabad';
    
    // Ensure the incoming city is in the dropdown list to prevent crash
    if (!_serviceCities.contains(_selectedCity)) {
      _serviceCities.add(_selectedCity);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pincodeController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _addressFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetecting = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      setState(() {
        _selectedLocation = loc;
        _selectedCity = loc.city ?? 'Ghaziabad';
        _addressController.text = loc.area ?? "";
        _showManualForm = true;
      });
    } catch (e) {
      final errorMsg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMsg'),
          action: errorMsg.contains('permanently denied') 
            ? SnackBarAction(
                label: 'Settings', 
                onPressed: LocationService.openSettings,
                textColor: AppColors.saffron,
              )
            : null,
        ),
      );
    } finally {
      setState(() => _isDetecting = false);
    }
  }

  void _onLocationSelected(UserLocation loc) {
    setState(() {
      _selectedLocation = loc;
      _selectedCity = loc.city ?? 'Ghaziabad';
      _addressController.text = loc.area ?? "";
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Confirm Ceremony Address',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where should we send\nthe Pandit?',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the exact address for the sacred ceremony.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
            ),
            const SizedBox(height: 32),

            // 🏠 SELECT FROM SAVED ADDRESSES
            if (!_showManualForm) ...[
              () {
                final savedAddresses = ref.watch(addressBookProvider);
                if (savedAddresses.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Select Saved Address'),
                    const SizedBox(height: 12),
                    ...savedAddresses.map((addr) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          final addressText = '${addr.line1}, ${addr.city}';
                          final current = ref.read(bookingSessionProvider).current;
                          if (current != null) {
                            final updated = current.copyWith(
                              address: addressText,
                              city: addr.city,
                              latitude: addr.latitude,
                              longitude: addr.longitude,
                              area: addr.line1,
                            );
                            ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
                          }
                          if (widget.onAddressSaved != null) {
                            widget.onAddressSaved!(addr);
                          } else {
                            context.push('/pandit-selection');
                          }
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: addr.isDefault 
                                ? AppColors.saffron.withOpacity(0.7) 
                                : AppColors.saffron.withOpacity(0.08),
                              width: addr.isDefault ? 1.5 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: addr.isDefault 
                                  ? AppColors.saffron.withOpacity(0.04) 
                                  : Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: addr.isDefault 
                                    ? AppColors.saffron.withOpacity(0.1) 
                                    : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on_rounded, 
                                  color: addr.isDefault ? AppColors.saffron : AppColors.softGrey, 
                                  size: 18
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          addr.city,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.darkCharcoal,
                                          ),
                                        ),
                                        if (addr.isDefault) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            'Default',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.saffron,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      addr.line1,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.softGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.saffron, size: 12),
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Or detect new location'),
                    const SizedBox(height: 12),
                  ],
                );
              }(),
            ],

            // 📍 USE CURRENT LOCATION
            if (!_showManualForm) ...[
              GestureDetector(
                onTap: _isDetecting ? null : _detectLocation,
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
                        child: _isDetecting 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.saffron))
                          : const Icon(Icons.my_location_rounded, color: AppColors.saffron, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use My Current Location',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Auto-detect your ceremony address',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.softGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.saffron, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✏️ ENTER MANUALLY BUTTON
              GestureDetector(
                onTap: () => setState(() => _showManualForm = true),
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
                        child: const Icon(Icons.edit_location_alt_rounded, color: AppColors.saffron, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Address Manually',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type your full address with city & pincode',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.softGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.saffron, size: 14),
                    ],
                  ),
                ),
              ),
            ],

            // 📝 MANUAL ENTRY FORM
            if (_showManualForm) ...[
              // City Dropdown
              const SectionHeader(title: 'City'),
              const SizedBox(height: 12),
              PrimaryCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.saffron),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                    items: _serviceCities.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCity = v!),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Address Field (Searchable)
              const SectionHeader(title: 'Search Landmark/Society'),
              const SizedBox(height: 12),
              PrimaryCard(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onTap: () {
                    // Ensure focus and prevent "select all" if it's being triggered externally
                    _searchFocus.requestFocus();
                  },
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () async {
                      if (value.length >= 3) {
                        setState(() => _isSearching = true);
                        final res = await LocationService.searchLocations(value, cityContext: _selectedCity);
                        setState(() {
                          _suggestions = res;
                          _isSearching = false;
                        });
                      } else {
                        setState(() => _suggestions = []);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for colony, building or area...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.saffron),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),

              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.saffron)),
                ),

              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final loc = _suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: AppColors.saffron, size: 20),
                        title: Text(loc.area ?? ""),
                        subtitle: Text("${loc.city}, ${loc.state}"),
                        onTap: () => _onLocationSelected(loc),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              const SectionHeader(title: 'Detailed Address'),
              if (_selectedLocation != null) ...[
                const SizedBox(height: 4),
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on, color: Colors.green, size: 14),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Pinned to: ${_selectedLocation?.area ?? ""}${_selectedLocation?.area != null ? ", " : ""}${_selectedLocation?.city ?? ""}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.green, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              PrimaryCard(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  maxLines: 2,
                  onTap: () => _addressFocus.requestFocus(),
                  decoration: InputDecoration(
                    hintText: 'House No, Flat No, Landmark details...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Pincode Field (Optional)
              const SectionHeader(title: 'Pincode (Optional)'),
              const SizedBox(height: 12),
              PrimaryCard(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'e.g. 201001',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.softGrey.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Back to options
              TextButton.icon(
                onPressed: () => setState(() => _showManualForm = false),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.saffron, size: 18),
                label: Text(
                  'Back to location options',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.saffron,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Continue button - inside scroll body so it's visible when keyboard is open
            if (_showManualForm)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: PrimaryButton(
                  label: 'Continue to Pandit Selection →',
                  onTap: _isFormValid
                      ? () {
                          // 🚨 CRITICAL: Ensure we have coordinates for matching
                          if (_selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please use "Auto-detect" or "Search" to pin your location first.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final addressText = '${_addressController.text.trim()}, $_selectedCity';
                          final newAddress = Address(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            phone: '', // Needs refinement
                            line1: _addressController.text.trim(),
                            city: _selectedCity,
                            state: _selectedLocation?.state ?? '',
                            pincode: _pincodeController.text,
                            latitude: _selectedLocation?.latitude,
                            longitude: _selectedLocation?.longitude,
                          );

                          if (widget.onAddressSaved != null) {
                            // 🚀 AUTO-SAVE TO DB
                            ref.read(addressBookProvider.notifier).addAddress(newAddress);
                            widget.onAddressSaved!(newAddress);
                            return;
                          }
                          
                          final current = ref.read(bookingSessionProvider).current;
                          if (current != null) {
                            // 🚀 AUTO-SAVE TO DB
                            ref.read(addressBookProvider.notifier).addAddress(newAddress);
                            
                            final updated = current.copyWith(
                              address: addressText,
                              city: _selectedCity,
                              latitude: _selectedLocation?.latitude,
                              longitude: _selectedLocation?.longitude,
                              area: _selectedLocation?.area,
                            );
                            ref.read(bookingSessionProvider.notifier).updateBookingDraft(updated);
                          }
                          
                          context.push('/pandit-selection');
                        }
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
