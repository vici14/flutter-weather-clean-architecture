import '../services/weather_service.dart';

abstract class IWeatherRepository {
  /// Get weather forecast for a location
  Future<WeatherResult<WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units,
  });
}
