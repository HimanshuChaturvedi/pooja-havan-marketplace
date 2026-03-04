import 'package:flutter/material.dart';
import 'package:app/src/logs/transaction_log.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/design_system.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
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

    return AppScaffold(
      title: 'My Bookings',
      body: logs.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _StaggeredFade(
                  controller: _animController,
                  delay: 100 + (index * 100),
                  child: _BookingCard(log: log),
                );
              },
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final TransactionLogEntry log;

  const _BookingCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PrimaryCard(
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
                    color: AppColors.saffron.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _titleFromLog(log).toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.saffron,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  '₹${log.amount}',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.darkCharcoal, 
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _subtitleFromLog(log),
              style: AppTextStyles.title.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 12),
            _InfoLine(label: 'Booking ID', value: _transactionIdForDisplay(log)),
            const SizedBox(height: 6),
            _InfoLine(label: 'Date', value: _formatDateTime(log.createdAt)),
            if (log.bookedForDate != null) ...[
              const SizedBox(height: 6),
              _InfoLine(
                label: 'Scheduled',
                value: '${log.bookedForDate!.day.toString().padLeft(2, '0')}/${log.bookedForDate!.month.toString().padLeft(2, '0')}/${log.bookedForDate!.year} at ${log.bookedForTime ?? '--'}',
              ),
            ],
            const SizedBox(height: 6),
            _InfoLine(
              label: 'Status',
              value: log.status == TransactionStatus.completed ? 'Confirmed' : 'Pending',
            ),
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
        Text(
          '$label: ', 
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.softGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.darkCharcoal,
              fontWeight: FontWeight.w600,
            ),
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
          Icon(Icons.history, color: AppColors.softGrey.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.softGrey),
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
