import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../logs/transaction_log.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../../core/utils/app_identity.dart';
import '../../application/samagri_session.dart';
import '../../../booking/application/booking_session.dart';

class SamagriSuccessPage extends StatelessWidget {
  const SamagriSuccessPage({super.key});

  String _shortUserId(String rawId) {
    final tail =
        rawId.length >= 4 ? rawId.substring(rawId.length - 4) : rawId;
    return 'SP-USER-$tail';
  }

  @override
  Widget build(BuildContext context) {
    final samagri = SamagriSession.current;
    final isBookingFlow = BookingSession.current != null;

    return FutureBuilder<String>(
      future: AppIdentity.userId,
      builder: (context, snapshot) {
        final rawUserId =
            snapshot.hasData ? snapshot.data! : '0000';
        final displayUserId = _shortUserId(rawUserId);

        // 🔒 LOG (REQUEST, NOT PAYMENT)
        if (samagri != null &&
            snapshot.connectionState == ConnectionState.done) {
          TransactionLogService.append(
            TransactionLogEntry(
              id: samagri.sessionId,
              type: TransactionType.samagri,
              title: 'Samagri Order Request',
              amount: samagri.totalAmount,
              status: TransactionStatus.completed,
              createdAt: DateTime.now(),
              userLabel: displayUserId,
              samagriSessionId: samagri.sessionId,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Samagri Request Submitted'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 72,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Samagri request submitted successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 24),

                // 📲 WHATSAPP → SAMAGRI VENDOR (WITH USER ID)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text(
                      'Send order details to Vendor on WhatsApp',
                    ),
                    onPressed: () {
                      WhatsAppHelper.openChat(
                        message:
                            'Namaste,\n\n'
                            'A samagri order has been placed via Shubh Pooja App.\n\n'
                            'User ID: $displayUserId\n'
                            'Transaction ID: ${samagri?.sessionId}\n\n'
                            'Items:\n'
                            '${samagri?.items.map((e) => '- ${e.name} × ${e.quantity}').join('\n')}\n\n'
                            'Delivery Address:\n'
                            '${samagri?.addressText ?? 'Same as booking'}\n\n'
                            'Please confirm availability.\n\n'
                            '— Shubh Pooja App',
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (isBookingFlow) {
                        context.go('/home-summary');
                      } else {
                        SamagriSession.clear();
                        context.go('/landing');
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
