import 'package:flutter/material.dart';

import '../../../logs/transaction_log.dart';

class MyActivityPage extends StatelessWidget {
  const MyActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = TransactionLogService.all();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activity'),
        centerTitle: true,
      ),
      body: logs.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _ActivityCard(log: log);
              },
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// UI COMPONENTS (OLD UI PRESERVED – NOTHING TOUCHED)
// -----------------------------------------------------------------------------

class _ActivityCard extends StatelessWidget {
  final TransactionLogEntry log;

  const _ActivityCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              _titleFromLog(log),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // SUBTITLE
            Text(
              _subtitleFromLog(log),
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            // 🔑 TRANSACTION ID (FIXED – MATCHES WHATSAPP)
            Text(
              'Transaction ID: ${_transactionIdForDisplay(log)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 6),

            // AMOUNT
            Text(
              'Amount: ₹${log.amount}',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 6),

            // CREATED AT (OLD BEHAVIOR)
            Text(
              'Created At: ${_formatDateTime(log.createdAt)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPERS (LOGIC SAME, ONLY ID DISPLAY FIXED)
// -----------------------------------------------------------------------------

String _transactionIdForDisplay(TransactionLogEntry log) {
  if (log.type == TransactionType.booking) {
    return log.bookingId ?? '-';
  }
  if (log.type == TransactionType.samagri) {
    return log.samagriSessionId ?? log.id;
  }
  return log.id;
}

String _titleFromLog(TransactionLogEntry e) {
  switch (e.type) {
    case TransactionType.booking:
      return 'Pooja Booking';
    case TransactionType.samagri:
      return 'Samagri Order';
  }
}

String _subtitleFromLog(TransactionLogEntry e) {
  if (e.type == TransactionType.booking) {
    return e.title;
  }
  return 'Samagri Order Request';
}

String _formatDateTime(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

// -----------------------------------------------------------------------------
// EMPTY STATE (OLD – UNCHANGED)
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No activity yet',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
