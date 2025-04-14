import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:weather_app_assignment/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete location search and selection flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Locations'), findsOneWidget);

      // Wait for locations to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Search for a location
      await tester.enterText(find.byType(TextField), 'London');
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.widgetWithText(Card, 'London'), findsOneWidget);

      // Select a location
      await tester.tap(find.widgetWithText(Card, 'London'));
      await tester.pumpAndSettle();

      // Verify location details are shown
      expect(find.text('London Details'), findsOneWidget);
    });

    testWidgets('handles error scenarios and retry', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Force error state (this depends on your implementation)
      // You might need to mock network failures or use test flags

      // Verify error message
      expect(find.textContaining('error'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Verify recovery
      expect(find.text('Locations'), findsOneWidget);
    });
  });
}
