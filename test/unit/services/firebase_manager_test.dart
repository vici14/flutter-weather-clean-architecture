import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app_assignment/core/services/firebase_manager.dart';
import 'package:weather_app_assignment/core/services/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseManager', () {
    late FirebaseManager firebaseManager;

    setUp(() {
      // Get the singleton instance
      firebaseManager = FirebaseManager();
      // Always start in test mode
      firebaseManager.setTestMode(true);
    });

    test('singleton works correctly', () {
      final instance1 = FirebaseManager();
      final instance2 = FirebaseManager();

      // Verify both instances are the same singleton object
      expect(identical(instance1, instance2), true);
    });

    test('initialize completes normally in test mode', () async {
      // In test mode, initialize should complete without error
      await expectLater(firebaseManager.initialize(), completes);
      expect(firebaseManager.isInitialized, true);
    });

    test('retry returns true in test mode', () async {
      final result = await firebaseManager.retry();
      expect(result, true);
    });
  });

  test('getLocationApiKey returns valid API key', () async {
    final mockStorage = MockSecureStorage();
    when(() => mockStorage.getLocationApiKey())
        .thenAnswer((_) async => 'test_location_api_key');

    final firebaseManager = FirebaseManager();
    firebaseManager.setTestMode(true);
    firebaseManager.setSecureStorage(mockStorage);

    final result = await firebaseManager.getLocationApiKey();
    expect(result, 'test_location_api_key');
  });

  test('getWeatherApiKey returns valid API key', () async {
    final mockStorage = MockSecureStorage();
    when(() => mockStorage.getWeatherApiKey())
        .thenAnswer((_) async => 'test_weather_api_key');

    final firebaseManager = FirebaseManager();
    firebaseManager.setTestMode(true);
    firebaseManager.setSecureStorage(mockStorage);

    final result = await firebaseManager.getWeatherApiKey();
    expect(result, 'test_weather_api_key');
  });

  test('getLocationApiKey returns empty string when storage returns null',
      () async {
    final mockStorage = MockSecureStorage();
    when(() => mockStorage.getLocationApiKey()).thenAnswer((_) async => null);

    final firebaseManager = FirebaseManager();
    firebaseManager.setTestMode(true);
    firebaseManager.setSecureStorage(mockStorage);

    final result = await firebaseManager.getLocationApiKey();
    expect(result, '');
  });

  test('getWeatherApiKey returns empty string when storage returns null',
      () async {
    final mockStorage = MockSecureStorage();
    when(() => mockStorage.getWeatherApiKey()).thenAnswer((_) async => null);

    final firebaseManager = FirebaseManager();
    firebaseManager.setTestMode(true);
    firebaseManager.setSecureStorage(mockStorage);

    final result = await firebaseManager.getWeatherApiKey();
    expect(result, '');
  });

  test('setSecureStorage only sets storage once', () async {
    final firstMockStorage = MockSecureStorage();
    when(() => firstMockStorage.getLocationApiKey())
        .thenAnswer((_) async => 'first_api_key');

    final secondMockStorage = MockSecureStorage();
    when(() => secondMockStorage.getLocationApiKey())
        .thenAnswer((_) async => 'second_api_key');

    final firebaseManager = FirebaseManager();
    firebaseManager.setTestMode(true);

    // Set first storage
    firebaseManager.setSecureStorage(firstMockStorage);
    // Try to set second storage (should be ignored)
    firebaseManager.setSecureStorage(secondMockStorage);

    // Should use the first storage
    final result = await firebaseManager.getLocationApiKey();
    expect(result, 'first_api_key');
  });
}
