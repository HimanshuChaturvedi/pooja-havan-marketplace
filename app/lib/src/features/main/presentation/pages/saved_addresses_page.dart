import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/core/services/location_service.dart';
import 'package:app/src/features/home_booking/presentation/address/domain/address.dart';
import 'package:app/src/features/home_booking/presentation/address/state/address_provider.dart';

class SavedAddressesPage extends ConsumerStatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  ConsumerState<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends ConsumerState<SavedAddressesPage> {
  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressBookProvider);

    return AppScaffold(
      title: 'Saved Addresses',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Address', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_off_rounded,
                        size: 64,
                        color: AppColors.saffron,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Addresses Saved',
                      style: AppTextStyles.title.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save your home, society, or local temple address for faster future ceremony bookings.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _showAddAddressSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => ref.read(addressBookProvider.notifier).setDefault(addr.id),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: addr.isDefault 
                            ? AppColors.saffron.withOpacity(0.7) 
                            : AppColors.saffron.withOpacity(0.08),
                          width: addr.isDefault ? 1.8 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: addr.isDefault 
                              ? AppColors.saffron.withOpacity(0.04) 
                              : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: addr.isDefault 
                                ? AppColors.saffron.withOpacity(0.1) 
                                : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded, 
                              color: addr.isDefault ? AppColors.saffron : AppColors.softGrey, 
                              size: 20
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  addr.city,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  addr.line1,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.darkCharcoal,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                                if (addr.pincode.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pincode: ${addr.pincode}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      addr.isDefault 
                                        ? Icons.check_circle_rounded 
                                        : Icons.radio_button_unchecked_rounded,
                                      size: 15,
                                      color: addr.isDefault ? AppColors.saffron : AppColors.softGrey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      addr.isDefault ? 'Default Address' : 'Tap to use as default',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: addr.isDefault ? AppColors.saffron : AppColors.softGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                            onPressed: () {
                              // Show a simple confirmation dialog or dismissible snackbar
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Delete Address?', style: TextStyle(fontWeight: FontWeight.bold)),
                                  content: const Text('Are you sure you want to remove this saved address?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel', style: TextStyle(color: AppColors.softGrey, fontWeight: FontWeight.bold)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(addressBookProvider.notifier).deleteAddress(addr.id);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Address deleted successfully'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AddAddressSheet extends ConsumerStatefulWidget {
  const _AddAddressSheet();

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _searchController = TextEditingController();
  String _selectedCity = 'Ghaziabad';
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isDetecting = false;
  UserLocation? _selectedLocation;
  List<UserLocation> _suggestions = [];
  Timer? _debounce;
  final _searchFocus = FocusNode();
  final _addressFocus = FocusNode();

  final List<String> _serviceCities = [
    'Ghaziabad',
    'Noida',
    'Delhi NCR',
    'Greater Noida',
  ];

  bool get _isFormValid => _addressController.text.trim().isNotEmpty;

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
        _addressController.text = loc.area ?? '';
        if (!_serviceCities.contains(_selectedCity) && _selectedCity.isNotEmpty) {
          _serviceCities.add(_selectedCity);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not auto-detect: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  void _onLocationSelected(UserLocation loc) {
    setState(() {
      _selectedLocation = loc;
      _selectedCity = loc.city ?? 'Ghaziabad';
      _addressController.text = loc.area ?? '';
      _suggestions = [];
      _searchController.clear();
      if (!_serviceCities.contains(_selectedCity) && _selectedCity.isNotEmpty) {
        _serviceCities.add(_selectedCity);
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final newAddress = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phone: '', 
        line1: _addressController.text.trim(),
        city: _selectedCity,
        state: _selectedLocation?.state ?? 'UP',
        pincode: _pincodeController.text.trim(),
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        isDefault: false,
      );

      await ref.read(addressBookProvider.notifier).addAddress(newAddress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New address saved successfully! 🏠'),
            backgroundColor: AppColors.softGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.warmIvory,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New Address 🏠',
              style: AppTextStyles.title.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide details for your ritual or delivery location.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),

            // 📍 AUTO DETECT LOCATION
            OutlinedButton.icon(
              onPressed: _isDetecting ? null : _detectLocation,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.saffron, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 0),
              ),
              icon: _isDetecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.saffron),
                    )
                  : const Icon(Icons.my_location_rounded, color: AppColors.saffron, size: 20),
              label: Text(
                _isDetecting ? 'Detecting Location...' : 'Use Current Location',
                style: const TextStyle(color: AppColors.saffron, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // 🔍 SEARCH LANDMARKS
            Text(
              'Search Society or Landmark',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            PrimaryCard(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
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
                decoration: const InputDecoration(
                  hintText: 'Search apartment, society, or temple name...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.saffron),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.saffron.withOpacity(0.12)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final loc = _suggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.saffron, size: 20),
                      title: Text(loc.area ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${loc.city}, ${loc.state}'),
                      onTap: () => _onLocationSelected(loc),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // CITY DROPDOWN
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      PrimaryCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.saffron),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
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
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pincode (Optional)',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      PrimaryCard(
                        padding: const EdgeInsets.all(4),
                        child: TextField(
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 201001',
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // DETAILED ADDRESS
            Text(
              'Detailed Address / Pinned Landmark',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (_selectedLocation != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded, color: AppColors.softGreen, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Selected: ${_selectedLocation?.area ?? ''}',
                        style: const TextStyle(color: AppColors.softGreen, fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            PrimaryCard(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: _addressController,
                focusNode: _addressFocus,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'House No, Building name, Landmark details...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              label: 'Save Address 🏠',
              loading: _isLoading,
              onTap: _isFormValid ? _handleSave : null,
            ),
          ],
        ),
      ),
    );
  }
}
