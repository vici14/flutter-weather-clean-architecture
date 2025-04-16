import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/core/services/loading_manager.dart';
import 'package:mockito/mockito.dart';
import '../../../mocks/mock_generators.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoadingManager loadingManager;
  late MockNavigatorState mockNavigatorState;
  late GlobalKey<NavigatorState> navigatorKey;
  late MockOverlayState mockOverlayState;
  late OverlayEntry mockOverlayEntry;

  setUp(() {
    // Initialize mocks
    mockNavigatorState = MockNavigatorState();
    mockOverlayState = MockOverlayState();
    navigatorKey = GlobalKey<NavigatorState>();
    mockOverlayEntry = OverlayEntry(builder: (_) => Container());

    // Setup the navigator key to access our mock navigator state
    when(navigatorKey.currentState).thenReturn(mockNavigatorState);
    when(mockNavigatorState.overlay).thenReturn(mockOverlayState);

    // Mock overlay.insert to avoid actual UI operations
    when(mockOverlayState.insert(any)).thenAnswer((_) {});

    loadingManager = LoadingManager(navigatorKey);
  });

  group('LoadingManager', () {
    test('isLoading returns false initially', () {
      expect(loadingManager.isLoading, isFalse);
    });

    test('isLoading returns true after showing loading', () {
      loadingManager.showLoading();
      expect(loadingManager.isLoading, isTrue);
    });

    test('isLoading returns false after hiding loading', () {
      loadingManager.showLoading();
      loadingManager.hideLoading();
      expect(loadingManager.isLoading, isFalse);
    });

    test('showLoading adds loading status to stream', () async {
      expectLater(
        loadingManager.loadingStream,
        emits(LoadingStatus.loading),
      );

      loadingManager.showLoading();
    });

    test('hideLoading adds success status to stream after loading', () async {
      expectLater(
        loadingManager.loadingStream,
        emitsInOrder([LoadingStatus.loading, LoadingStatus.success]),
      );

      loadingManager.showLoading();
      loadingManager.hideLoading();
    });

    test('multiple show calls increment counter correctly', () {
      loadingManager.showLoading();
      loadingManager.showLoading();
      loadingManager.showLoading();
      expect(loadingManager.isLoading, isTrue);

      loadingManager.hideLoading();
      expect(loadingManager.isLoading, isTrue);

      loadingManager.hideLoading();
      expect(loadingManager.isLoading, isTrue);

      loadingManager.hideLoading();
      expect(loadingManager.isLoading, isFalse);
    });

    test('forceHideLoading hides loading regardless of counter', () {
      loadingManager.showLoading();
      loadingManager.showLoading();
      loadingManager.showLoading();
      expect(loadingManager.isLoading, isTrue);

      loadingManager.forceHideLoading();
      expect(loadingManager.isLoading, isFalse);
    });

    test('forceHideLoading adds success status to stream', () async {
      expectLater(
        loadingManager.loadingStream,
        emitsInOrder([LoadingStatus.loading, LoadingStatus.success]),
      );

      loadingManager.showLoading();
      loadingManager.forceHideLoading();
    });

    test('showLoadingWithMessage shows loading with message', () {
      // Setup expectations for showing loading with message
      expectLater(
        loadingManager.loadingStream,
        emits(LoadingStatus.loading),
      );

      loadingManager.showLoadingWithMessage('Loading test data');
      expect(loadingManager.isLoading, isTrue);
    });

    test('showLoadingWithMessage replaces existing loading overlay', () {
      // First show normal loading
      loadingManager.showLoading();
      expect(loadingManager.isLoading, isTrue);

      // Then show loading with message
      loadingManager.showLoadingWithMessage('Loading test data');
      expect(loadingManager.isLoading, isTrue);

      // Should require two hide calls since we called show twice
      loadingManager.hideLoading();
      expect(loadingManager.isLoading, isTrue);

      loadingManager.hideLoading();
      expect(loadingManager.isLoading, isFalse);
    });

    test('dispose closes the stream controller', () {
      // Call dispose
      loadingManager.dispose();

      // Attempting to add to stream after disposal should throw
      expect(() => loadingManager.showLoading(), throwsStateError);
    });

    test('handles null overlay gracefully', () {
      // Make overlay return null
      when(mockNavigatorState.overlay).thenReturn(null);

      // Should not throw an exception when overlay is null
      expect(() => loadingManager.showLoading(), returnsNormally);
      expect(loadingManager.isLoading, isTrue);
    });
  });
}
