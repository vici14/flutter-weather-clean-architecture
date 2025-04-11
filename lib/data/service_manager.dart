import 'api_client.dart';
import 'interceptors/location_interceptor.dart';
import 'interceptors/weather_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

/// A singleton class that manages all services in the application
class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();

  factory ServiceManager() => _instance;

  ServiceManager._internal();

  LocationService? _locationService;
  WeatherService? _weatherService;

  /// Initialize all services with required configurations
  void initialize({
    required String locationApiKey,
    required String weatherApiKey,
  }) {
    final locationClient = ApiClient(
      interceptors: [
        LoggingInterceptor(),
        LocationInterceptor(),
      ],
    );

    final weatherClient = ApiClient(
      interceptors: [
        LoggingInterceptor(),
        WeatherInterceptor(),
      ],
    );

    _locationService = LocationService(
      apiKey: locationApiKey,
      client: locationClient,
    );

    _weatherService = WeatherService(
      apiKey: weatherApiKey,
      client: weatherClient,
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
    _locationService?.client.close();
    _weatherService?.client.close();
  }
}
