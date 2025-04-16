import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  // Constructor with optional storage parameter for testing
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Keys
  static const String locationApiKey = 'location_api_key';
  static const String weatherApiKey = 'weather_api_key';

  // Save values
  Future<void> saveLocationApiKey(String value) async {
    await _storage.write(key: locationApiKey, value: value);
  }

  Future<void> saveWeatherApiKey(String value) async {
    await _storage.write(key: weatherApiKey, value: value);
  }

  // Get values
  Future<String?> getLocationApiKey() async {
    return await _storage.read(key: locationApiKey);
  }

  Future<String?> getWeatherApiKey() async {
    return await _storage.read(key: weatherApiKey);
  }

  // Delete values
  Future<void> deleteLocationApiKey() async {
    await _storage.delete(key: locationApiKey);
  }

  Future<void> deleteWeatherApiKey() async {
    await _storage.delete(key: weatherApiKey);
  }

  // Delete all
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
