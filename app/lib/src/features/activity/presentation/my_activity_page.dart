import 'package:flutter/material.dart';
import 'package:app/src/logs/transaction_log.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class MyActivityPage extends StatefulWidget {
  const MyActivityPage({super.key});

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = TransactionLogService.all();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'My Activity',
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: logs.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 120, 16, 40),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _StaggeredFade(
                    controller: _animController,
                    delay: 100 + (index * 100),
                    child: _ActivityCard(log: log),
                  );
                },
              ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final TransactionLogEntry log;

  const _ActivityCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final isBooking = log.type == TransactionType.booking;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DivineGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isBooking ? AppColors.saffron : AppColors.deepSaffron).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (isBooking ? AppColors.saffron : AppColors.deepSaffron).withOpacity(0.3)),
                  ),
                  child: Text(
                    _titleFromLog(log).toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isBooking ? AppColors.deepSaffron : AppColors.maroon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Text(
                  '₹${log.amount}',
                  style: AppTextStyles.title.copyWith(color: AppColors.maroon, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _subtitleFromLog(log),
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            _InfoLine(label: 'ID', value: _transactionIdForDisplay(log)),
            const SizedBox(height: 6),
            _InfoLine(label: 'Date', value: _formatDateTime(log.createdAt)),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.deepSaffron.withOpacity(0.5))),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.maroon.withOpacity(0.7)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: AppColors.maroon.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text(
            'No activity yet',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

class _StaggeredFade extends StatelessWidget {
  final AnimationController controller;
  final int delay;
  final Widget child;

  const _StaggeredFade({required this.controller, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final start = (delay / 1500).clamp(0, 1.0).toDouble();
        final end = ((delay + 600) / 1500).clamp(0, 1.0).toDouble();
        
        final opacity = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ).value;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
    );
  }
}
