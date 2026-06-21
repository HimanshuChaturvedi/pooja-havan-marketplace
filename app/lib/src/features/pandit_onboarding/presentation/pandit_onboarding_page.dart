import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/design_system.dart';
import '../../../theme/components/app_colors.dart';
import '../../../theme/components/app_text_styles.dart';

import '../state/pandit_onboarding_provider.dart';
import '../../../core/supabase/supabase_client.dart'; // To get current user id
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../../services/domain/explore_service.dart';
import '../../../core/utils/ritual_category_mapper.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io';
import 'dart:math'; // [NEW] for OTP generation
import '../../../core/services/whatsapp_service.dart'; // [NEW]

class PanditOnboardingPage extends ConsumerStatefulWidget {
  const PanditOnboardingPage({super.key});

  @override
  ConsumerState<PanditOnboardingPage> createState() => _PanditOnboardingPageState();
}

class _PanditOnboardingPageState extends ConsumerState<PanditOnboardingPage> {
  int _currentStep = 0;
  
  // Step 0: Identity
  final _identityFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  bool _isAadharVerified = false; 
  String? _aadharFrontPath;
  String? _aadharBackPath;

  // Step 1: Personal
  final _personalFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController(); // For Phone Verification
  final _expController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressLine1Controller = TextEditingController(); // [NEW]
  final _addressLine2Controller = TextEditingController(); // [NEW]
  final _cityController = TextEditingController(); // [NEW]
  final _stateController = TextEditingController(); // [NEW]
  final _pinCodeController = TextEditingController(); // [NEW]
  String? _profileImagePath; // [NEW]
  
  bool _isPhoneOtpSent = false;
  bool _isPhoneVerified = false;

  final List<String> _availableCities = [
    'Ghaziabad',
    'Noida',
    'Greater Noida',
    'Delhi',
    'Gurugram',
    'Faridabad'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill email from auth if available
    final user = supabase.auth.currentUser;
    if (user?.email != null) {
      _emailController.text = user!.email!;
    }
    if (user?.phone != null && user!.phone!.isNotEmpty) {
      _phoneController.text = user.phone!;
      _isPhoneVerified = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _expController.dispose();
    _bioController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int type) async {
    // type: 0 = profile, 1 = aadhar front, 2 = aadhar back
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      setState(() {
        if (type == 1) {
          _aadharFrontPath = image.path;
        } else if (type == 2) {
          _aadharBackPath = image.path;
        } else {
          _profileImagePath = image.path;
        }
      });
    }
  }

  void _verifyAadharMock() {
    if (_aadharController.text.trim().length != 12) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aadhar must be 12 digits')));
       return;
    }
    // Show a fake loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() => _isAadharVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Aadhar Verified Successfully via DigiLocker!'),
          backgroundColor: Colors.green,
        ));
      }
    });
  }

  void _saveIdentityDetails() {
    if (_identityFormKey.currentState!.validate() && _aadharFrontPath != null && _aadharBackPath != null) {
      ref.read(panditOnboardingProvider.notifier).updateIdentity(
        emailAddress: _emailController.text.trim(),
        aadharNumber: _aadharController.text.trim(),
        panNumber: _panController.text.trim(),
        aadharFrontPath: _aadharFrontPath,
        aadharBackPath: _aadharBackPath,
      );
      setState(() => _currentStep++);
    } else if (_aadharFrontPath == null || _aadharBackPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload both Front and Back sides of Aadhar card')));
    }
  }

  Future<void> _sendPhoneOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 10-digit number.')));
      return;
    }

    // Format phone number with country code
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    // Generate 6-digit OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    try {
      final success = await ref.read(whatsappServiceProvider).sendOtp(formattedPhone, otp);
      if (success) {
        setState(() => _isPhoneOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification code sent to your WhatsApp.')));
      } else {
        throw 'Failed to send WhatsApp message';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyPhoneOtp() async {
    final otp = _otpController.text.trim();
    final phone = _phoneController.text.trim();
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 6-digit OTP.')));
      return;
    }

    try {
      final isVerified = await ref.read(whatsappServiceProvider).verifyOtp(formattedPhone, otp);
      
      if (isVerified) {
        setState(() {
          _isPhoneVerified = true;
          _isPhoneOtpSent = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp number verified successfully!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid or expired OTP. Please try again.'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _savePersonalDetails() {
    if (_personalFormKey.currentState!.validate() && _isPhoneVerified) {
      ref.read(panditOnboardingProvider.notifier).updatePersonalDetails(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            experienceYears: int.tryParse(_expController.text.trim()) ?? 0,
            bio: _bioController.text.trim(),
            addressLine1: _addressLine1Controller.text.trim(),
            addressLine2: _addressLine2Controller.text.trim(),
            city: _cityController.text.trim(),
            addressState: _stateController.text.trim(),
            pinCode: _pinCodeController.text.trim(),
            profileImagePath: _profileImagePath,
          );
      setState(() => _currentStep++);
    } else if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please verify your phone number first.')));
    } else if (_profileImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload your profile photo.')));
    }
  }

  Future<void> _submitAll() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Not authenticated')));
      return;
    }

    final success = await ref.read(panditOnboardingProvider.notifier).submitProfile(user.id);
    
    if (success && mounted) {
      // Direct them to the Pending Approval screen
      context.go('/pandit-pending'); 
    } else if (mounted) {
      final error = ref.read(panditOnboardingProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Submission failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(panditOnboardingProvider);

    return AppScaffold(
      title: 'Pandit Registration',
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        onStepContinue: () {
          if (_currentStep == 0) {
             _saveIdentityDetails();
          } else if (_currentStep == 1) {
             _savePersonalDetails();
          } else if (_currentStep == 2) {
            if (state.draft.isAreasComplete) {
              setState(() => _currentStep++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one city')));
            }
          } else if (_currentStep == 3) {
            if (state.draft.isSpecializationsComplete) {
              setState(() => _currentStep++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one ritual')));
            }
          } else if (_currentStep == 4) {
            _submitAll();
          }
        },
        controlsBuilder: (context, details) {
          final isSubmitting = state.isSubmitting;
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                  flex: _currentStep > 0 ? 2 : 1,
                  child: PrimaryButton(
                    label: _currentStep == 4 ? 'Submit for Review' : 'Continue',
                    loading: isSubmitting && _currentStep == 4,
                    onTap: details.onStepContinue,
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Back',
                      onTap: details.onStepCancel!,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Identity Verification'),
            isActive: _currentStep >= 0,
            content: Form(
              key: _identityFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(child: Text("We verify your identity to ensure the safety of our customers.", style: TextStyle(fontSize: 13, color: Colors.black87))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: designInputDecoration('Email Address*', prefix: Icons.email_outlined),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    decoration: designInputDecoration('Aadhar Number*', prefix: Icons.badge_outlined),
                    validator: (v) => v!.length != 12 ? 'Must be 12 digits' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _panController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: designInputDecoration('PAN Number (Optional)', prefix: Icons.account_balance_wallet_outlined),
                  ),
                  const SizedBox(height: 24),
                  Text('Aadhar Card Copies*', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImagePicker(
                          path: _aadharFrontPath,
                          label: 'Front Side',
                          onTap: () => _pickImage(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildImagePicker(
                          path: _aadharBackPath,
                          label: 'Back Side',
                          onTap: () => _pickImage(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Personal Details'),
            isActive: _currentStep >= 1,
            content: Form(
              key: _personalFormKey,
              child: Column(
                children: [
                   _buildImagePicker(
                    path: _profileImagePath,
                    label: 'Profile Photo*',
                    isCircle: true,
                    onTap: () => _pickImage(0),
                  ),
                  const SizedBox(height: 24),
                  // Fixed Name Row Alignment
                  TextFormField(
                    controller: _firstNameController,
                    decoration: designInputDecoration('First Name*', prefix: Icons.person_outline),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: designInputDecoration('Last Name*', prefix: Icons.person_outline),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: designInputDecoration('WhatsApp Number*', prefix: Icons.phone_outlined),
                          validator: (v) => v!.length < 10 ? 'Enter valid number' : null,
                        ),
                      ),
                      if (!_isPhoneVerified) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: PrimaryButton(
                            label: _isPhoneOtpSent ? 'Resend OTP' : 'Send OTP',
                            onTap: _sendPhoneOtp,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_isPhoneOtpSent && !_isPhoneVerified) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: designInputDecoration('Enter OTP*', prefix: Icons.lock_outline),
                            validator: (v) => v!.length != 6 ? 'Enter 6-digit OTP' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: PrimaryButton(
                            label: 'Verify',
                            onTap: _verifyPhoneOtp,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_isPhoneVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text('Phone number verified!', style: AppTextStyles.bodySmall.copyWith(color: Colors.green)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expController,
                    keyboardType: TextInputType.number,
                    decoration: designInputDecoration('Years of Experience*', prefix: Icons.star_border),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 2,
                    decoration: designInputDecoration('Short Bio (Optional)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressLine1Controller,
                    decoration: designInputDecoration('Address Line 1 (House No, Building)*', prefix: Icons.home_outlined),
                    validator: (v) => v!.length < 3 ? 'Please enter valid address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressLine2Controller,
                    decoration: designInputDecoration('Address Line 2 (Area, Locality)', prefix: Icons.map_outlined),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: designInputDecoration('City*', prefix: Icons.location_city_outlined),
                          validator: (v) => v!.isEmpty ? 'City required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: designInputDecoration('State*', prefix: Icons.map_outlined),
                          validator: (v) => v!.isEmpty ? 'State required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: designInputDecoration('Pin Code (6 digits)*', prefix: Icons.pin_drop_outlined),
                    validator: (v) => v!.length != 6 ? 'Must be 6 digits' : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Service Areas'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Where can you perform rituals?', style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableCities.map((city) {
                    final isSelected = state.draft.serviceCities.contains(city);
                    return ChoiceChip(
                      label: Text(city),
                      selectedColor: AppColors.saffron.withOpacity(0.2),
                      selected: isSelected,
                      onSelected: (_) => ref.read(panditOnboardingProvider.notifier).toggleServiceCity(city),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Specializations'),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What rituals do you perform?', style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: RitualCategoryMapper.getCategories().map((category) {
                    final isSelected = state.draft.ritualSlugs.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selectedColor: AppColors.saffron.withOpacity(0.2),
                      selected: isSelected,
                      onSelected: (_) => ref.read(panditOnboardingProvider.notifier).toggleSpecialization(category),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Review'),
            isActive: _currentStep >= 4,
            content: PrimaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Identity', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.saffron)),
                  Text('Email: ${state.draft.emailAddress}'),
                  Text('Aadhar: ${state.draft.aadharNumber} (Uploaded ✓)', style: const TextStyle(color: Colors.green)),
                  const Divider(),
                  Text('Details', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.saffron)),
                  Text('First Name: ${state.draft.firstName}'),
                  Text('Last Name: ${state.draft.lastName}'),
                  Text('Phone: ${state.draft.phoneNumber}'),
                  Text('Address: ${state.draft.addressLine1}, ${state.draft.addressLine2}'),
                  Text('City/State: ${state.draft.city}, ${state.draft.state}'),
                  Text('Pin Code: ${state.draft.pinCode}'),
                  Text('Experience: ${state.draft.experienceYears} Years'),
                  const SizedBox(height: 8),
                   if (state.draft.profileImagePath != null) const Text('Profile Photo: Attached ✓', style: TextStyle(color: Colors.green)),
                  if (state.draft.aadharFrontPath != null) const Text('Aadhar Front: Attached ✓', style: TextStyle(color: Colors.green)),
                  if (state.draft.aadharBackPath != null) const Text('Aadhar Back: Attached ✓', style: TextStyle(color: Colors.green)),
                  const Divider(),
                  Text('Areas', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.saffron)),
                  Text(state.draft.serviceCities.join(', ')),
                  const Divider(),
                  Text('Rituals', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.saffron)),
                  Text(state.draft.ritualSlugs.join(', ')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker({required String? path, required String label, required VoidCallback onTap, bool isCircle = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: isCircle ? 120 : double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(isCircle ? 60 : 16),
          border: Border.all(color: AppColors.saffron.withOpacity(0.3), width: 2, style: BorderStyle.solid),
          image: path != null ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover) : null,
        ),
        child: path == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isCircle ? Icons.add_a_photo : Icons.add_photo_alternate, color: AppColors.saffron, size: isCircle ? 28 : 32),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label, 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: isCircle ? 10 : 12, color: AppColors.saffron, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 16, color: AppColors.saffron),
                ),
              ),
      ),
    );
  }

  InputDecoration designInputDecoration(String hint, {IconData? prefix}) {
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
