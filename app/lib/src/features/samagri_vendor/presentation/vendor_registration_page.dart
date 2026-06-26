import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';
import '../data/vendor_repository.dart';
import 'dart:async';
import 'package:app/src/core/services/whatsapp_service.dart';

class VendorRegistrationPage extends ConsumerStatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  ConsumerState<VendorRegistrationPage> createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends ConsumerState<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _otpController = TextEditingController();
  
  double? _lat;
  double? _lon;
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  bool _isPhoneOtpSent = false;
  bool _isOtpLoading = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownSeconds = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        _cooldownTimer?.cancel();
      }
    });
  }

  Future<void> _sendPhoneOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 10-digit number.')));
      return;
    }

    if (_cooldownSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please wait $_cooldownSeconds seconds before requesting another code.')));
      return;
    }

    setState(() => _isOtpLoading = true);
    try {
      final res = await ref.read(whatsappServiceProvider).sendOtp(phone, 'VENDOR_ONBOARDING');
      if (res.success) {
        setState(() => _isPhoneOtpSent = true);
        _startCooldownTimer();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification code sent to your WhatsApp.'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage ?? 'Failed to send WhatsApp message'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isOtpLoading = false);
    }
  }

  Future<void> _verifyPhoneOtp() async {
    final otp = _otpController.text.trim();
    final phone = _phoneController.text.trim();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 6-digit OTP.')));
      return;
    }

    setState(() => _isOtpLoading = true);
    try {
      final res = await ref.read(whatsappServiceProvider).verifyOtp(phone, otp, 'VENDOR_ONBOARDING');
      if (res.success) {
        setState(() {
          _isPhoneVerified = true;
          _isPhoneOtpSent = false;
        });
        _cooldownTimer?.cancel();
        setState(() {
          _cooldownSeconds = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number verified successfully!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage ?? 'Invalid OTP. Please try again.'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isOtpLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    // Navigate to location selection/map
    // For now, simpler: we'll use a mocked location picker or existing one
    // Let's use GoRouter to go to a location selection screen and wait for result
    final result = await context.push('/location-selection?type=vendor');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _lat = result['latitude'];
        _lon = result['longitude'];
        _addressController.text = result['address'] ?? '';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please verify your phone number first')));
      return;
    }
    if (_lat == null || _lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your shop location on map')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(samagriVendorRepositoryProvider).registerVendor(
        shopName: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text, // New field for manual tweak
        latitude: _lat!,
        longitude: _lon!,
        radius: 3.0, // Standard 3km as requested
      );
      if (mounted) context.go('/vendor-pending');
    } catch (e) {
      if (mounted) {
        String errMsg = 'Registration failed. Please try again.';
        if (e is PostgrestException) {
          errMsg = e.message;
        } else if (e is Exception) {
          errMsg = e.toString().replaceFirst('Exception: ', '');
        } else {
          errMsg = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register Your Shop',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join our sacred marketplace',
                style: AppTextStyles.title.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Grow your business by fulfilling ritual samagri orders in your local area.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
              const SizedBox(height: 32),
              
              Text('Shop Name', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _designInputDecoration('e.g. Laxmi Samagri Bhandar'),
              ),
              const SizedBox(height: 24),

              Text('Contact Number', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: _isPhoneVerified,
                      decoration: _designInputDecoration('10-digit mobile number').copyWith(
                        prefixIcon: const Icon(Icons.phone, color: AppColors.saffron),
                      ),
                      onChanged: (val) {
                        if (_isPhoneVerified) setState(() => _isPhoneVerified = false);
                      },
                    ),
                  ),
                  if (!_isPhoneVerified) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (_isOtpLoading || _cooldownSeconds > 0) ? null : _sendPhoneOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isOtpLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _cooldownSeconds > 0
                                  ? 'Resend ${_cooldownSeconds}s'
                                  : (_isPhoneOtpSent ? 'Resend OTP' : 'Send OTP'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ] else ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  ],
                ],
              ),
              if (_isPhoneOtpSent && !_isPhoneVerified) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: _designInputDecoration('Enter 6-digit OTP').copyWith(counterText: ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isOtpLoading ? null : _verifyPhoneOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isOtpLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),

              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.saffron),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search for your specific shop/landmark. Orders are matched within 3km of this point.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Editable Address Field with Picker Icon
              Text('Shop Address / Detailed Location', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: _designInputDecoration('E.g. House 45, Gali 2, Indirapuram').copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location_rounded, color: AppColors.saffron),
                    onPressed: _pickLocation,
                    tooltip: 'Auto-detect Location',
                  ),
                ),
              ),
              if (_lat != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Precise GPS coordinates captured. You can manually tweak the house/gali number above.', 
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Submit for Verification',
                loading: _isLoading,
                onTap: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'After submission, our team will verify your shop within 24-48 hours.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _designInputDecoration(String hint, {IconData? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix != null ? Icon(prefix, color: AppColors.saffron) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
