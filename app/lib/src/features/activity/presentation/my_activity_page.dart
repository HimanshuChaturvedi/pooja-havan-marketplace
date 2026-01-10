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
        leading: BackButton(
          onPressed: () {
            // 🔑 FIX: go back explicitly to Landing
            context.go('/landing');
          },
        ),
      ),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No activity yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.type == TransactionType.booking
                            ? 'Pooja Booking'
                            : 'Samagri Order',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(log.title),
                      const SizedBox(height: 6),
                      Text('Amount: ₹${log.amount}'),
                      const SizedBox(height: 6),
                      Text(
                        'Date: ${log.createdAt.day}/${log.createdAt.month}/${log.createdAt.year}',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
