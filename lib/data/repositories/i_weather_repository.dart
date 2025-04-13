import '../models/weather_forecast.dart';
import '../models/weather_result.dart';
import '../services/weather_service.dart';

abstract class IWeatherRepository {
  /// Get weather forecast for a location
  Future<WeatherResult<WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units,
  });

  /// Get 4 days ahead forecast for a location
  Future<WeatherResult<List<DailyForecast>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units,
  });
}
