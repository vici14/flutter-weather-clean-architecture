import 'package:fpdart/fpdart.dart';
import '../models/weather_forecast.dart';
import '../service_manager.dart';
import '../services/weather_service.dart';
import '../exception/DataException.dart';
import 'i_weather_repository.dart';

class WeatherRepository implements IWeatherRepository {
  final ServiceManager _serviceManager;

  WeatherRepository(ServiceManager serviceManager)
      : _serviceManager = serviceManager;

  @override
  Future<Either<DataException, WeatherForecast>> getWeatherForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) {
    return _serviceManager.weatherService.getWeatherForecast(
      lat: lat,
      lon: lon,
      units: units,
    );
  }

  @override
  Future<Either<DataException, List<DailyForecast>>> getFourDaysForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) {
    return _serviceManager.weatherService.getFourDaysForecast(
      lat: lat,
      lon: lon,
      units: units,
    );
  }
}
