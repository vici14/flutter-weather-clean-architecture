import 'package:fpdart/fpdart.dart';
import '../models/weather_forecast.dart';
import '../exception/DataException.dart';

abstract class IWeatherRepository {
  /// Get weather forecast for a location
  Future<Either<DataException, WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units,
  });

  /// Get 4 days ahead forecast for a location
  Future<Either<DataException, List<DailyForecast>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units,
  });
}
