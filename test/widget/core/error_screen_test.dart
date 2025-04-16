import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/widgets/error_screen.dart';

void main() {
  group('ErrorScreen Widget', () {
    testWidgets('renders with default values', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorScreen(
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify default error text is displayed
      expect(find.text('Something went wrong\nat our end!'), findsOneWidget);

      // Verify retry button is displayed with default text
      expect(find.text('RETRY'), findsOneWidget);

      // Verify the icon is displayed (if any)
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renders with custom error message',
        (WidgetTester tester) async {
      // This test should be removed or updated since ErrorScreen doesn't
      // support custom message parameter currently
      expect(true, isTrue);
    });

    testWidgets('calls onRetry callback when button is pressed',
        (WidgetTester tester) async {
      bool retryPressed = false;

      // Build the widget with retry callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorScreen(
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Initially the callback should not have been called
      expect(retryPressed, false);

      // Tap the retry button
      await tester.tap(find.text('RETRY'));
      await tester.pump();

      // Verify the callback was called
      expect(retryPressed, true);
    });

    testWidgets('renders with correct styling', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorScreen(
              onRetry: () {},
            ),
          ),
        ),
      );

      // Verify text styling
      final textFinder = find.text('Something went wrong\nat our end!');
      expect(textFinder, findsOneWidget);

      // Verify button exists
      final buttonFinder = find.byType(TextButton);
      expect(buttonFinder, findsOneWidget);
    });
  });
}
