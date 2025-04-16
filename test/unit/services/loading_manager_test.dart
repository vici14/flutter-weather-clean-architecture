import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';

void main() {
  late LoadingManager loadingManager;
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() {
    navigatorKey = GlobalKey<NavigatorState>();
    loadingManager = LoadingManager(navigatorKey);
  });

  group('LoadingManager', () {
    test('initially is not loading', () {
      expect(loadingManager.isLoading, false);
    });

    testWidgets('showLoading increments counter', (WidgetTester tester) async {
      // Setup the test widget
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(),
        ),
      );

      // Execute
      expect(loadingManager.isLoading, false);
      loadingManager.showLoading();

      // Verify
      expect(loadingManager.isLoading, true);
    });

    testWidgets('hideLoading decrements counter when count is zero',
        (WidgetTester tester) async {
      // Setup the test widget
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(),
        ),
      );

      // Show loading first
      loadingManager.showLoading();
      expect(loadingManager.isLoading, true);

      // Execute
      loadingManager.hideLoading();

      // Verify
      expect(loadingManager.isLoading, false);
    });

    testWidgets('hideLoading keeps isLoading true if counter is still positive',
        (WidgetTester tester) async {
      // Setup the test widget
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(),
        ),
      );

      // Show loading twice
      loadingManager.showLoading();
      loadingManager.showLoading();
      expect(loadingManager.isLoading, true);

      // Execute - hide once
      loadingManager.hideLoading();

      // Verify - still loading
      expect(loadingManager.isLoading, true);
    });

    testWidgets('forceHideLoading resets counter', (WidgetTester tester) async {
      // Setup the test widget
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(),
        ),
      );

      // Show loading multiple times
      loadingManager.showLoading();
      loadingManager.showLoading();
      loadingManager.showLoading();
      expect(loadingManager.isLoading, true);

      // Execute
      loadingManager.forceHideLoading();

      // Verify
      expect(loadingManager.isLoading, false);
    });

    testWidgets('loadingStream emits events when loading state changes',
        (WidgetTester tester) async {
      // Setup the test widget
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(),
        ),
      );

      // Create a list to collect events
      final events = <LoadingStatus>[];

      // Listen to the stream
      final subscription = loadingManager.loadingStream.listen((status) {
        events.add(status);
      });

      // Trigger loading and unloading
      loadingManager.showLoading();
      await tester.pump();
      loadingManager.hideLoading();
      await tester.pump();

      // Cancel subscription
      subscription.cancel();

      // Verify events were emitted
      expect(events.length, 2);
      expect(events[0], LoadingStatus.loading);
      expect(events[1], LoadingStatus.success);
    });
  });
}
