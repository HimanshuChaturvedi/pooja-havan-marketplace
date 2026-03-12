import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/src/core/widgets/design_system.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/supabase/supabase_client.dart';
import 'package:app/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? redirectTo;
  const LoginPage({super.key, this.redirectTo});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Static variable to persist cooldown across page reloads in the same session
  static DateTime? _lastOtpSentAt;

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _errorMessage;
  String? _rawServerResponse; // To capture full server error for diagnostics
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _isSyncing = false; // Strict guard to prevent duplicate calls

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    
    // Resume cooldown if a request was sent recently
    if (_lastOtpSentAt != null) {
      final elapsed = DateTime.now().difference(_lastOtpSentAt!).inSeconds;
      if (elapsed < 60) {
        _startCooldown(60 - elapsed);
      }
    }
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim().toLowerCase();
    if (RegExp(r'^[^@]+@[^@]+\.(com|org|net|edu|gov|in|io|co\.in|org\.in|net\.in)$').hasMatch(text) ||
        RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{3,}$').hasMatch(text)) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    setState(() => _resendCooldown = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        if (mounted) setState(() => _resendCooldown--);
      } else {
        if (mounted) {
          setState(() {
            _resendCooldown = 0;
            _errorMessage = null;
          });
        }
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendOtp() async {
    if (_isSyncing || _isLoading || _resendCooldown > 0) return;
    _isSyncing = true;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
        _isSyncing = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      
      _lastOtpSentAt = DateTime.now();
      _startCooldown(60);
      setState(() => _isOtpSent = true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent! 📧'),
            backgroundColor: AppColors.saffron,
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _rawServerResponse = 'Status: ${e.statusCode}\nMessage: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '320949488571-vsqbgdhqb47mteu7kne59p6l66u3o8fk.apps.googleusercontent.com',
        scopes: ['email'],
      );

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No ID Token found from Google.';

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (mounted) {
        if (widget.redirectTo != null) {
          context.go(widget.redirectTo!);
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter a valid verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.auth.verifyOTP(
        email: _emailController.text.trim(),
        token: otp,
        type: OtpType.email,
      );
      
      if (mounted) {
        if (widget.redirectTo != null) {
          context.go(widget.redirectTo!);
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Invalid or expired code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://himanshuchaturvedi.github.io/pooja-havan-marketplace/privacy-policy.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Privacy Policy link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.saffron.withOpacity(0.15),
                    AppColors.saffron.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // 🔙 ABSOLUTE POSITIONED BACK BUTTON (Pinned to top-left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 8,
            child: IconButton(
              onPressed: () {
                if (_isOtpSent) {
                  setState(() => _isOtpSent = false);
                } else {
                  context.pop();
                }
              },
              icon: Icon(
                _isOtpSent ? Icons.arrow_back : Icons.arrow_back_ios_new, 
                color: AppColors.darkCharcoal
              ),
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 70, // Start content below back button
              bottom: MediaQuery.of(context).viewInsets.bottom + 60,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOtpSent ? 'Verify your\nEmail ✉️' : 'Join the Sacred\nMarketplace 🙏',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 34, height: 1.2,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isOtpSent 
                      ? 'Enter the 6-digit code sent to ${_emailController.text}'
                      : 'Sign in to manage your ritual bookings and samagri orders seamlessly.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.softGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!_isOtpSent) ...[
                    // 🚀 GOOGLE BUTTON
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(Icons.login),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.darkCharcoal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 24),
                    
                    Text('Your Email Address',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.darkCharcoal, fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: designInputDecoration('name@example.com', prefix: Icons.email_outlined),
                    ),
                  ] else ...[
                    Text('Verification Code',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.darkCharcoal, fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w900),
                      decoration: designInputDecoration('000000'),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],

                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: _isOtpSent ? 'Verify & Login' : 'Send Code',
                    loading: _isLoading,
                    onTap: _isOtpSent ? _handleVerifyOtp : _handleSendOtp,
                  ),
                  
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      _isOtpSent 
                        ? "Didn't receive the code? Wait 60s to resend." 
                        : 'No password required. We will email you a secure login code.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey),
                    ),
                  ),
                  
                  if (_isOtpSent)
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isOtpSent = false),
                        child: const Text('Change Email', style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.bold)),
                      ),
                    ),

                  const SizedBox(height: 48),
                  // 📜 PRIVACY POLICY ONLY
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'By continuing, you agree to our',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGrey),
                        ),
                        TextButton(
                          onPressed: _launchPrivacyPolicy,
                          child: const Text('Privacy Policy', 
                            style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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
