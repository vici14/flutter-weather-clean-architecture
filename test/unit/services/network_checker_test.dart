import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app_assignment/core/services/network_checker.dart';

class MockInternetConnection extends Mock implements InternetConnection {
  final StreamController<InternetStatus> statusController =
      StreamController<InternetStatus>.broadcast();

  @override
  Stream<InternetStatus> get onStatusChange => statusController.stream;
}

void main() {
  late NetworkChecker networkChecker;
  late MockInternetConnection mockInternetConnection;

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    // Set up default behavior
    when(() => mockInternetConnection.hasInternetAccess)
        .thenAnswer((_) async => true);
    networkChecker = NetworkChecker(mockInternetConnection);
  });

  tearDown(() {
    networkChecker.dispose();
    mockInternetConnection.statusController.close();
  });

  group('NetworkChecker', () {
    test('initial state is set correctly', () {
      expect(networkChecker.hasConnection, true);
      expect(networkChecker.isInitialized, false);
    });

    test('checkConnection updates connection status', () async {
      // Override the default implementation
      when(() => mockInternetConnection.hasInternetAccess)
          .thenAnswer((_) async => false);

      // Execute
      final result = await networkChecker.checkConnection();

      // Verify
      expect(result, false);
      expect(networkChecker.hasConnection, false);
    });

    test('connectionStatus stream emits values on status change', () async {
      // Create a completer to wait for all values
      final completer = Completer<List<bool>>();
      final emittedValues = <bool>[];

      // Listen to the stream
      final subscription = networkChecker.connectionStatus.listen((value) {
        emittedValues.add(value);
        if (emittedValues.length == 3) {
          completer.complete(emittedValues);
        }
      });

      // Trigger the events with delays
      mockInternetConnection.statusController.add(InternetStatus.connected);
      await Future.delayed(Duration(milliseconds: 10));
      mockInternetConnection.statusController.add(InternetStatus.disconnected);
      await Future.delayed(Duration(milliseconds: 10));
      mockInternetConnection.statusController.add(InternetStatus.connected);

      // Wait for completer to complete or timeout
      final values =
          await completer.future.timeout(Duration(seconds: 1), onTimeout: () {
        subscription.cancel();
        return emittedValues;
      });

      // Cancel subscription
      subscription.cancel();

      // Verify the values
      expect(values.length, 3);
      expect(values, contains(true));
      expect(values, contains(false));
    });

    test('status listener updates isInitialized after first event', () async {
      expect(networkChecker.isInitialized, false);

      // Simulate a connection status change
      mockInternetConnection.statusController.add(InternetStatus.connected);

      // Allow the event to be processed
      await Future.delayed(Duration.zero);

      expect(networkChecker.isInitialized, true);
    });

    testWidgets('showConnectivityMessage shows snackbar when connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () =>
                      networkChecker.showConnectivityMessage(context, true),
                  child: const Text('Show Message'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Message'));
      await tester.pump();

      expect(find.text('Internet connection restored'), findsOneWidget);
    });

    testWidgets('showConnectivityMessage shows snackbar when disconnected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () =>
                      networkChecker.showConnectivityMessage(context, false),
                  child: const Text('Show Message'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Message'));
      await tester.pump();

      expect(find.text('No internet connection'), findsOneWidget);
    });

    test('dispose closes the stream controller', () {
      // We need to test that calling dispose doesn't throw an exception
      expect(() => networkChecker.dispose(), returnsNormally);
    });
  });
}
