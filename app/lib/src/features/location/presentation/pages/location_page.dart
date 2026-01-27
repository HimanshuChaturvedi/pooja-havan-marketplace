import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/components/app_colors.dart';
import '../../../../theme/components/app_text_styles.dart';
import '../../../booking/application/booking_session.dart';
import '../../../booking/domain/booking_draft.dart';

class LocationPage extends StatelessWidget {
  final String ritualSlug;
  final String ritualName;

  const LocationPage({
    super.key,
    required this.ritualSlug,
    required this.ritualName,
  });

  static const String _pilotCity = 'Ghaziabad';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.saffron,
        centerTitle: true,
        title: Text(
          "Service Location",
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/landing'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "For $ritualName",
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 16),

            // 🔒 PILOT NOTICE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Pilot Notice',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Bharat Pooja Setu services are currently being piloted exclusively in Ghaziabad.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📍 FIXED CITY CARD
            Text(
              'Service City',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _pilotCity,
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ✅ CONTINUE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // 🔑 CREATE BOOKING SESSION WITH FIXED CITY
                  BookingSession.current = BookingDraft(
                    bookingType: BookingType.home,
                    ritualName: ritualName,
                    city: _pilotCity,
                  );

                  context.push('/at-home-or-temple');
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
