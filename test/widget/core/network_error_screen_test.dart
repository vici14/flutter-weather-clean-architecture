import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/widgets/network_error_screen.dart';
import 'package:weather_app_assignment/core/theme/app_text_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkErrorScreen Widget', () {
    testWidgets('renders with default values', (WidgetTester tester) async {
      bool retryPressed = false;

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: NetworkErrorScreen(
            onRetry: () {
              retryPressed = true;
            },
          ),
        ),
      );

      // Verify header text
      expect(find.text('Network Error'), findsOneWidget);

      // Verify default message is displayed
      expect(
        find.text(
          'No internet connection. Please check your network settings and try again.',
        ),
        findsOneWidget,
      );

      // Verify retry button exists
      expect(find.text('RETRY'), findsOneWidget);

      // Verify wifi off icon exists
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      // Verify callback when button is pressed
      await tester.tap(find.text('RETRY'));
      await tester.pump();
      expect(retryPressed, isTrue);
    });

    testWidgets('renders with custom message', (WidgetTester tester) async {
      const customMessage = 'Custom network error message';

      // Build widget with custom message
      await tester.pumpWidget(
        MaterialApp(
          home: NetworkErrorScreen(
            onRetry: () {
              // Empty callback for testing
            },
            message: customMessage,
          ),
        ),
      );

      // Verify custom message is displayed
      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('has proper styling', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: NetworkErrorScreen(
            onRetry: () {},
          ),
        ),
      );

      // Verify styling elements
      final iconFinder = find.byIcon(Icons.wifi_off_rounded);
      final Icon icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 80);

      // Find text widgets and verify styles
      final headerFinder = find.text('Network Error');
      final Text headerText = tester.widget<Text>(headerFinder);
      expect(headerText.style, AppTextStyles.headerStyle);
      expect(headerText.textAlign, TextAlign.center);

      // Find button
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
    });
  });
}
