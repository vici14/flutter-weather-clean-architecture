import 'package:http/http.dart' as http;

import '../data/services/location_service.dart';
import '../data/services/weather_service.dart';

/// A singleton class that manages all services in the application
class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();

  factory ServiceManager() => _instance;

  ServiceManager._internal();

  /// HTTP client shared across all services
  final http.Client _client = http.Client();

  /// Lazy-initialized location service
  LocationService? _locationService;

  /// Lazy-initialized weather service
  WeatherService? _weatherService;

  /// Initialize all services with required configurations
  void initialize({
    required String locationApiKey,
    required String weatherApiKey,
  }) {
    _locationService = LocationService(
      apiKey: locationApiKey,
      client: _client,
    );

    _weatherService = WeatherService(
      apiKey: weatherApiKey,
      client: _client,
    );
  }

  /// Get the location service
  LocationService get locationService {
    if (_locationService == null) {
      throw StateError(
          'LocationService not initialized. Call initialize() first.');
    }
    return _locationService!;
  }

  /// Get the weather service
  WeatherService get weatherService {
    if (_weatherService == null) {
      throw StateError(
          'WeatherService not initialized. Call initialize() first.');
    }
    return _weatherService!;
  }

  /// Dispose all resources
  void dispose() {
    _client.close();
  }
}
