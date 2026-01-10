import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../logs/transaction_log.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../application/samagri_session.dart';

class SamagriSuccessPage extends StatelessWidget {
  const SamagriSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final samagri = SamagriSession.current;

    // 🔒 LOG SAMAGRI SUCCESS
    if (samagri != null) {
      TransactionLogService.append(
        TransactionLogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: TransactionType.samagri,
          title: 'Samagri Order',
          amount: samagri.totalAmount,
          status: TransactionStatus.completed,
          createdAt: DateTime.now(),
          samagriSessionId: samagri.sessionId,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 72,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your samagri order is confirmed',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // 📲 WHATSAPP BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Chat on WhatsApp'),
              onPressed: () {
                WhatsAppHelper.openChat(
                  message:
                      'Hi, my samagri order is confirmed.\n'
                      'Amount: ₹${samagri?.totalAmount}',
                );
              },
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                SamagriSession.clear();
                context.go('/landing');
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
