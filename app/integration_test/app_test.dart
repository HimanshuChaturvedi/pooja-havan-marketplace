import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Regression Suite', () {
    testWidgets('Full Regression Pass', (tester) async {
      // Load the app
      await app.main();
      await tester.pumpAndSettle();

      // 1. Verify Home Page Load
      expect(find.text('Pooja Havan'), findsOneWidget);
      
      // 2. Sample Flow: Navigation to Bookings
      final bookingsTab = find.byIcon(Icons.calendar_month);
      if (bookingsTab.evaluate().isNotEmpty) {
        await tester.tap(bookingsTab);
        await tester.pumpAndSettle();
        expect(find.text('My Bookings'), findsOneWidget);
      }

      print('✅ Basic regression flow passed');
    });
  });
}
