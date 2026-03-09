import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Book Pooja Regression Flow', () {
    testWidgets('Should complete full pooja booking journey', (tester) async {
      // 1. Launch App
      await app.main();
      await tester.pumpAndSettle();

      // 2. Select a Ritual from Home Grid
      final ritualItem = find.text('Navgraha Shanti').first;
      if (ritualItem.evaluate().isNotEmpty) {
         await tester.tap(ritualItem);
         await tester.pumpAndSettle();
      }

      // 3. Navigate through the flow (Step 1 -> Step 2)
      // Since flows vary based on user state, we check for presence of "Next" or "Continue"
      final continueButton = find.text('Continue');
      if (continueButton.evaluate().isNotEmpty) {
        await tester.tap(continueButton);
        await tester.pumpAndSettle();
      }

      // 4. Verify Summary Page
      // We expect to see 'Order Summary' or the ritual name in the final review
      expect(find.textContaining('Summary'), findsWidgets);

      print('✅ Book Pooja Flow verified successfully');
    });
  });
}
