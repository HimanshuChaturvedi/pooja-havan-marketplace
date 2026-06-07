import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/features/auth/presentation/state/auth_provider_impl.dart';

class PersonalDetailsPage extends ConsumerStatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  ConsumerState<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends ConsumerState<PersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _whatsappController;
  late final String _email;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    
    _nameController = TextEditingController(text: metadata['full_name'] ?? '');
    _whatsappController = TextEditingController(text: metadata['whatsapp_number'] ?? '');
    _email = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final whatsapp = _whatsappController.text.trim();

      // Format WhatsApp number cleanly (ensure prefix +91 if 10 digits)
      var formattedWhatsapp = whatsapp;
      if (whatsapp.length == 10 && RegExp(r'^[0-9]+$').hasMatch(whatsapp)) {
        formattedWhatsapp = '+91$whatsapp';
      }

      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'whatsapp_number': formattedWhatsapp,
          },
        ),
      );

      // Invalidate the provider to sync metadata changes app-wide immediately
      ref.invalidate(supabaseUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! 🙏'),
            backgroundColor: AppColors.softGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Personal Details',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sacred Identity 🙏',
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep your identity details updated for seamless bookings and communications.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGrey),
              ),
              const SizedBox(height: 32),

              // FULL NAME
              Text(
                'Full Name',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkCharcoal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ramesh Kumar',
                    prefixIcon: Icon(Icons.person_rounded, color: AppColors.saffron),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              // WHATSAPP NUMBER
              Text(
                'WhatsApp Number',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkCharcoal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 9871966676',
                    prefixIcon: Icon(Icons.phone_rounded, color: AppColors.saffron),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your WhatsApp number';
                    }
                    final cleanNum = value.replaceAll(RegExp(r'[^0-9+]'), '');
                    if (cleanNum.length < 10) {
                      return 'Please enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),

              // EMAIL (READ ONLY)
              Text(
                'Email Address (Linked Identity)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkCharcoal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryCard(
                color: Colors.grey.shade100,
                showShadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.email_rounded, color: AppColors.softGrey, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.softGrey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.lock_outline_rounded, color: AppColors.softGrey, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Email is fixed as your unique sacred credentials.',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 12, color: AppColors.softGrey),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 48),

              PrimaryButton(
                label: 'Save Changes 🙏',
                loading: _isLoading,
                onTap: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
