import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/core/widgets/design_system.dart';

class SamagriDeliveryAddressPage extends StatefulWidget {
  const SamagriDeliveryAddressPage({super.key});

  @override
  State<SamagriDeliveryAddressPage> createState() => _SamagriDeliveryAddressPageState();
}

class _SamagriDeliveryAddressPageState extends State<SamagriDeliveryAddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String _selectedCity = 'Ghaziabad';
  bool _showManualForm = false;

  static const List<String> _serviceCities = [
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
    _addressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Delivery Address',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where should we deliver\nyour samagri?',
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the delivery address for your order.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
            ),
            const SizedBox(height: 32),

            // 📍 USE CURRENT LOCATION
            if (!_showManualForm) ...[
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location feature coming soon')),
                  );
                },
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
                              'Auto-detect your delivery address',
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
              const SectionHeader(title: 'Full Address'),
              const SizedBox(height: 12),
              PrimaryCard(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'House No, Area, Society, Landmark...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.softGrey.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
          ],
        ),
      ),
      bottomNavigationBar: _showManualForm
          ? Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: PrimaryButton(
                label: 'Continue to Payment →',
                onTap: _isFormValid
                    ? () {
                        final address = '${_addressController.text.trim()}, $_selectedCity';
                        final pincode = _pincodeController.text.trim();
                        final fullAddress = pincode.isNotEmpty ? '$address - $pincode' : address;
                        SamagriSession.attachAddress(fullAddress);
                        context.push('/payment');
                      }
                    : null,
              ),
            )
          : null,
    );
  }
}
