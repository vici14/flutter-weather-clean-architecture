import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weather_app_assignment/core/services/secure_storage.dart';

// Manual mock for FlutterSecureStorage
class MockFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String?> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SecureStorage secureStorage;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(storage: mockStorage);
  });

  group('SecureStorage', () {
    test('saveLocationApiKey stores value in secure storage', () async {
      // Arrange
      const apiKey = 'test_location_api_key';

      // Act
      await secureStorage.saveLocationApiKey(apiKey);

      // Assert
      final storedValue =
          await mockStorage.read(key: SecureStorage.locationApiKey);
      expect(storedValue, equals(apiKey));
    });

    test('saveWeatherApiKey stores value in secure storage', () async {
      // Arrange
      const apiKey = 'test_weather_api_key';

      // Act
      await secureStorage.saveWeatherApiKey(apiKey);

      // Assert
      final storedValue =
          await mockStorage.read(key: SecureStorage.weatherApiKey);
      expect(storedValue, equals(apiKey));
    });

    test('getLocationApiKey returns a value from secure storage', () async {
      // Arrange
      const apiKey = 'test_location_api_key';
      await mockStorage.write(key: SecureStorage.locationApiKey, value: apiKey);

      // Act
      final result = await secureStorage.getLocationApiKey();

      // Assert
      expect(result, equals(apiKey));
    });

    test('getWeatherApiKey returns a value from secure storage', () async {
      // Arrange
      const apiKey = 'test_weather_api_key';
      await mockStorage.write(key: SecureStorage.weatherApiKey, value: apiKey);

      // Act
      final result = await secureStorage.getWeatherApiKey();

      // Assert
      expect(result, equals(apiKey));
    });

    test('deleteLocationApiKey removes location API key', () async {
      // Arrange
      const apiKey = 'test_location_api_key';
      await mockStorage.write(key: SecureStorage.locationApiKey, value: apiKey);

      // Act
      await secureStorage.deleteLocationApiKey();

      // Assert
      final storedValue =
          await mockStorage.read(key: SecureStorage.locationApiKey);
      expect(storedValue, isNull);
    });

    test('deleteWeatherApiKey removes weather API key', () async {
      // Arrange
      const apiKey = 'test_weather_api_key';
      await mockStorage.write(key: SecureStorage.weatherApiKey, value: apiKey);

      // Act
      await secureStorage.deleteWeatherApiKey();

      // Assert
      final storedValue =
          await mockStorage.read(key: SecureStorage.weatherApiKey);
      expect(storedValue, isNull);
    });

    test('deleteAll removes all stored values', () async {
      // Arrange
      await mockStorage.write(
          key: SecureStorage.locationApiKey, value: 'location_key');
      await mockStorage.write(
          key: SecureStorage.weatherApiKey, value: 'weather_key');

      // Act
      await secureStorage.deleteAll();

      // Assert
      final locationKey =
          await mockStorage.read(key: SecureStorage.locationApiKey);
      final weatherKey =
          await mockStorage.read(key: SecureStorage.weatherApiKey);
      expect(locationKey, isNull);
      expect(weatherKey, isNull);
    });
  });
}
