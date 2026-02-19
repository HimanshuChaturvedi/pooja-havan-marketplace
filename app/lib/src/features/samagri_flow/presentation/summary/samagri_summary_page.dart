import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app/src/features/samagri_flow/application/samagri_session.dart';
import 'package:app/src/features/booking/application/booking_session.dart';
import 'package:app/src/theme/components/app_colors.dart';
import 'package:app/src/theme/components/app_text_styles.dart';
import 'package:app/src/core/widgets/divine_background.dart';
import 'package:app/src/core/widgets/divine_glass_card.dart';

class SamagriSummaryPage extends StatelessWidget {
  const SamagriSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final samagri = SamagriSession.current;
    final isBookingFlow = BookingSession.current != null;

    if (samagri == null) {
      return const Scaffold(
        body: DivineBackground(
          child: Center(
            child: Text('No samagri data', style: TextStyle(color: AppColors.maroon)),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Samagri Summary',
          style: AppTextStyles.title.copyWith(fontSize: 22, color: AppColors.maroon),
        ),
        iconTheme: const IconThemeData(color: AppColors.maroon),
      ),
      body: DivineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          child: Column(
            children: [
              DivineGlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ...samagri.items.map(
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${i.name} × ${i.quantity}',
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.maroon),
                            ),
                            Text(
                              '₹${i.lineTotal}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.maroon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 32, color: Colors.black12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.maroon),
                        ),
                        Text(
                          '₹${samagri.totalAmount}',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 20,
                            color: AppColors.maroon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.dawnOrange.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffron,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            onPressed: () {
              context.push(
                isBookingFlow ? '/samagri-success' : '/payment',
              );
            },
            child: Text(
              'Continue →',
              style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
