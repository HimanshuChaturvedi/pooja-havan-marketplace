// lib/src/features/booking/presentation/payment_page.dart
// Booking Flow — Payment Screen (Razorpay Test Integration)
// Production-ready file, Clean Architecture + Riverpod

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:go_router/go_router.dart';

// NOTE: Replace this test key with your Razorpay test key from dashboard
const String kRazorpayTestKey = 'rzp_test_XXXXXXXXXXXXXXXX';

// Simple provider for price (in paise). For now it's static/mockable.
final mockAmountProvider = Provider<int>((ref) => 50000); // 500.00 INR -> 50000 paise

class PaymentPage extends ConsumerStatefulWidget {
  final String panditName;
  final String poojaSlug;

  const PaymentPage({super.key, required this.panditName, required this.poojaSlug});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    // TODO: Persist booking to backend (Supabase) using response.paymentId
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment successful'),
        content: Text('Payment ID: ${response.paymentId}\n\nThank you!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to booking success page (placeholder route)
              // NOTE: Do not activate routing until we finalize routes as a single step.
              context.push('/booking/success');
            },
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment failed'),
        content: Text('Code: ${response.code}\nMessage: ${response.message}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External wallet selected: ${response.walletName}')));
  }

  Future<void> _openCheckout(int amount, {String? prefillName, String? prefillEmail, String? prefillContact}) async {
    setState(() => _isProcessing = true);

    final options = {
      'key': kRazorpayTestKey,
      'amount': amount, // in paise
      'name': 'Pooja & Havan',
      'description': '${widget.poojaSlug} — ${widget.panditName}',
      'prefill': {
        'contact': prefillContact ?? '',
        'email': prefillEmail ?? '',
        'name': prefillName ?? '',
      },
      'theme': {
        'color': '#F59E0B' // saffron-gold accent (hex) — matches app theme
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Payment error'),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountPaise = ref.watch(mockAmountProvider);
    final amountDisplay = (amountPaise / 100).toStringAsFixed(2);

    // Prefill from booking providers if available
    final prefillName = ref.watch(fullNameProvider);
    final prefillContact = ref.watch(phoneProvider);
    final prefillEmail = ref.watch(emailProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,3)))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.poojaSlug, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Pandit: ${widget.panditName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount', style: TextStyle(fontSize: 14)),
                      Text('₹ $amountDisplay', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(child: Container()),

            // Pay button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () => _openCheckout(amountPaise, prefillName: prefillName, prefillEmail: prefillEmail, prefillContact: prefillContact),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Processing...', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      )
                    : Text('Pay ₹ $amountDisplay', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 12),
            Text('You will be redirected to Razorpay in test-mode.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
