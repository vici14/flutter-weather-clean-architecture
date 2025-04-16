import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app_assignment/data/service_manager.dart';
import 'package:weather_app_assignment/data/services/location_service.dart';
import 'package:weather_app_assignment/data/services/weather_service.dart';

void main() {
  late ServiceManager serviceManager;

  setUp(() {
    // Reset singleton state by creating a new instance
    serviceManager = ServiceManager();
  });

  tearDown(() {
    // Clean up resources
    serviceManager.dispose();
  });

  group('ServiceManager', () {
    test('should be initialized after calling initialize', () {
      // Setup
      expect(serviceManager.isInitialized, isFalse);

      // Execute
      serviceManager.initialize(
        locationApiKey: 'test_location_key',
        weatherApiKey: 'test_weather_key',
      );

      // Verify
      expect(serviceManager.isInitialized, isTrue);
    });

    test('should return LocationService instance after initialization', () {
      // Setup
      serviceManager.initialize(
        locationApiKey: 'test_location_key',
        weatherApiKey: 'test_weather_key',
      );

      // Execute & Verify
      expect(serviceManager.locationService, isA<LocationService>());
    });

    test('should return WeatherService instance after initialization', () {
      // Setup
      serviceManager.initialize(
        locationApiKey: 'test_location_key',
        weatherApiKey: 'test_weather_key',
      );

      // Execute & Verify
      expect(serviceManager.weatherService, isA<WeatherService>());
    });

    test('should return fallback LocationService if not initialized', () {
      // Execute & Verify - should not throw exception
      expect(serviceManager.locationService, isA<LocationService>());
    });

    test('should return fallback WeatherService if not initialized', () {
      // Execute & Verify - should not throw exception
      expect(serviceManager.weatherService, isA<WeatherService>());
    });

    test('should create singleton instance', () {
      // Create multiple instances
      final manager1 = ServiceManager();
      final manager2 = ServiceManager();

      // Should be the same instance
      expect(identical(manager1, manager2), isTrue);
    });

    test('dispose should not throw exception', () {
      // Initialize
      serviceManager.initialize(
        locationApiKey: 'test_location_key',
        weatherApiKey: 'test_weather_key',
      );

      // Execute & Verify
      expect(() => serviceManager.dispose(), returnsNormally);
    });
  });
}
