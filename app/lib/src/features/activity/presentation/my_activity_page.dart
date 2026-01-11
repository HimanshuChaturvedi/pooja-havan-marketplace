import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No activity yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                final created = log.createdAt;

                final createdText =
                    '${created.day}/${created.month}/${created.year} '
                    '${created.hour}:${created.minute.toString().padLeft(2, '0')}';

                final bookedForText =
                    log.bookedForDate != null
                        ? '${log.bookedForDate!.day}/${log.bookedForDate!.month}/${log.bookedForDate!.year}'
                        : '-';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pooja Booking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('User: ${log.userLabel}'),
                      const SizedBox(height: 6),
                      Text('Ritual: ${log.title}'),
                      const SizedBox(height: 6),
                      Text(
                          'Booked For: $bookedForText ${log.bookedForTime ?? ''}'),
                      const SizedBox(height: 6),
                      Text('Amount: ₹${log.amount}'),
                      const SizedBox(height: 6),
                      Text(
                        'Created At: $createdText',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
